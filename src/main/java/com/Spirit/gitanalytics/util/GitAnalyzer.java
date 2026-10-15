package com.Spirit.gitanalytics.util;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.diff.DiffEntry;
import org.eclipse.jgit.diff.DiffFormatter;
import org.eclipse.jgit.lib.ObjectReader;
import org.eclipse.jgit.lib.Repository;
import org.eclipse.jgit.revwalk.RevCommit;
import org.eclipse.jgit.revwalk.RevTree;
import org.eclipse.jgit.revwalk.RevWalk;
import org.eclipse.jgit.storage.file.FileRepositoryBuilder;
import org.eclipse.jgit.treewalk.CanonicalTreeParser;
import org.eclipse.jgit.util.io.NullOutputStream;

import com.Spirit.gitanalytics.model.CommitRecord;

import java.io.File;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.jgit.api.errors.GitAPIException;

/**
 * GitAnalyzer - Wrapper cho JGit API.
 * Cung cấp:
 *   - openRepository(path)           : mở repo local
 *   - fetchCommits(repository)       : trích xuất tất cả commits
 *
 * Lưu ý Java 8: KHÔNG dùng var, KHÔNG dùng List.of(), dùng diamond <> và ArrayList<>().
 */
public class GitAnalyzer {

    /**
     * Mở một Git repository từ đường dẫn local.
     */
    public Repository openRepository(String localPath) throws IOException {
        File repoDir = new File(localPath, ".git");
        if (!repoDir.exists()) {
            throw new IOException("Không tìm thấy .git tại: " + localPath);
        }
        return new FileRepositoryBuilder()
                .setGitDir(repoDir)
                .readEnvironment()
                .findGitDir()
                .build();
    }

    /**
     * Lấy tất cả commits trong repo, kèm số liệu lines added/deleted.
     *
     * @param repo  Repository đã mở
     * @return List các CommitRecord (chưa map team_member_id)
     */
    public List<CommitRecord> fetchCommits(Repository repo) throws IOException, GitAPIException {
        List<CommitRecord> records = new ArrayList<>();
        try (Git git = new Git(repo);
             RevWalk revWalk = new RevWalk(repo);
             ObjectReader reader = repo.newObjectReader()) {

            for (RevCommit commit : git.log().call()) {
                CommitRecord rec = new CommitRecord();
                rec.setCommitHash(commit.getName());
                rec.setAuthorName(commit.getAuthorIdent().getName());
                rec.setAuthorEmail(commit.getAuthorIdent().getEmailAddress());
                rec.setCommitDate(new Timestamp(commit.getCommitTime() * 1000L));
                rec.setMessage(commit.getShortMessage());

                int[] lineStats = computeLineStats(repo, revWalk, commit, reader);
                rec.setFilesChanged(lineStats[0]);
                rec.setLinesAdded(lineStats[1]);
                rec.setLinesDeleted(lineStats[2]);

                records.add(rec);
            }
        }
        return records;
    }

    /**
     * Tính filesChanged, linesAdded, linesDeleted bằng cách so sánh với parent.
     * Nếu là commit đầu tiên (không có parent) thì đếm toàn bộ blob của tree.
     */
    private int[] computeLineStats(Repository repo, RevWalk revWalk,
                                   RevCommit commit, ObjectReader reader) throws IOException {
        int files = 0, added = 0, deleted = 0;

        if (commit.getParentCount() == 0) {
            // Initial commit: đếm toàn bộ file
            RevTree tree = commit.getTree();
            try (org.eclipse.jgit.treewalk.TreeWalk tw = new org.eclipse.jgit.treewalk.TreeWalk(reader)) {
                tw.reset(tree);
                while (tw.next()) {
                    if (tw.isSubtree()) {
                        tw.enterSubtree();
                        continue;
                    }
                    byte[] content = tw.getObjectReader().open(tw.getObjectId(0)).getBytes();
                    added += countLines(content);
                    files++;
                }
            }
            return new int[] { files, added, 0 };
        }

        RevCommit parent = commit.getParent(0);
        RevTree oldTree = parent.getTree();
        RevTree newTree = commit.getTree();

        CanonicalTreeParser oldParser = new CanonicalTreeParser();
        oldParser.reset(reader, oldTree);
        CanonicalTreeParser newParser = new CanonicalTreeParser();
        newParser.reset(reader, newTree);

        try (DiffFormatter df = new DiffFormatter(NullOutputStream.INSTANCE)) {
            df.setRepository(repo);
            List<DiffEntry> diffs = df.scan(oldParser, newParser);
            files = diffs.size();

            for (DiffEntry diff : diffs) {
                if (diff.getChangeType() == DiffEntry.ChangeType.ADD
                 || diff.getChangeType() == DiffEntry.ChangeType.COPY) {
                    added += getInsertedLines(repo, diff.getNewId().toObjectId());
                } else if (diff.getChangeType() == DiffEntry.ChangeType.DELETE) {
                    deleted += getInsertedLines(repo, diff.getOldId().toObjectId());
                } else {
                    added   += getInsertedLines(repo, diff.getNewId().toObjectId());
                    deleted += getInsertedLines(repo, diff.getOldId().toObjectId());
                }
            }
        }
        return new int[] { files, added, deleted };
    }

    private int getInsertedLines(Repository repo, org.eclipse.jgit.lib.AnyObjectId id) throws IOException {
        if (id == null) return 0;
        byte[] data = repo.open(id).getBytes();
        return countLines(data);
    }

    private int countLines(byte[] data) {
        if (data == null || data.length == 0) return 0;
        int count = 1;
        for (byte b : data) {
            if (b == '\n') count++;
        }
        return count;
    }

    /**
     * Lấy tên branch hiện tại (best-effort).
     */
    public String getCurrentBranch(Repository repo) {
        try {
            return repo.getBranch();
        } catch (IOException e) {
            return "unknown";
        }
    }
}
