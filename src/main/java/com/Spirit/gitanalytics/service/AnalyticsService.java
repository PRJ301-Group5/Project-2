package com.Spirit.gitanalytics.service;

import com.Spirit.gitanalytics.dao.CommitRecordDAO;
import com.Spirit.gitanalytics.dao.ContributionScoreDAO;
import com.Spirit.gitanalytics.dao.ProjectDAO;
import com.Spirit.gitanalytics.dao.TeamMemberDAO;
import com.Spirit.gitanalytics.model.CommitRecord;
import com.Spirit.gitanalytics.model.ContributionScore;
import com.Spirit.gitanalytics.model.Project;
import com.Spirit.gitanalytics.model.TeamMember;
import com.Spirit.gitanalytics.util.GitAnalyzer;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.lib.Repository;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * AnalyticsService - Service tổng hợp:
 *   1. Mở Git repo bằng JGit
 *   2. Map commit author_email -> TeamMember (bằng git_email)
 *   3. Save raw commits vào DB (batch insert)
 *   4. Tính contribution_pct, fairness_score, status cho từng member
 *   5. Persist score vào ContributionScore
 *
 * Thuật toán tính điểm:
 *   - Đếm commits & lines_added cho từng member (normalized)
 *   - contribution_pct = (lines_added_member / total_lines_added) * 100
 *   - fairness_score = clamp(contribution_pct - EXPECTED, threshold) theo công thức
 *   - status:
 *       LOW  : contribution_pct < 10% (có dấu hiệu free-riding)
 *       HIGH : contribution_pct > (2 * 100/N) — gánh team
 *       NORMAL: còn lại
 */
public class AnalyticsService {

    private static final double EXPECTED_PER_MEMBER = 100.0;   // Nếu đều thì mỗi người ~100/N%
    private static final double LOW_THRESHOLD       = 10.0;   // < 10% là LOW
    private static final double HIGH_MULTIPLIER     = 2.0;    // > 2 * 100/N là HIGH

    private final ProjectDAO          projectDAO = new ProjectDAO();
    private final TeamMemberDAO       memberDAO   = new TeamMemberDAO();
    private final CommitRecordDAO     commitDAO   = new CommitRecordDAO();
    private final ContributionScoreDAO scoreDAO   = new ContributionScoreDAO();
    private final GitAnalyzer         gitAnalyzer = new GitAnalyzer();

    /**
     * Chạy phân tích end-to-end cho 1 project.
     *
     * @return số commits đã save.
     */
    public int analyzeProject(int projectId) throws IOException, GitAPIException, SQLException, ClassNotFoundException {
        long start = System.currentTimeMillis();

        Project project = projectDAO.findById(projectId);
        if (project == null) {
            throw new IllegalArgumentException("Project not found: " + projectId);
        }
        if (project.getLocalPath() == null || project.getLocalPath().isEmpty()) {
            throw new IllegalArgumentException("Project local_path chưa được cấu hình.");
        }

        // 1) Open repo + fetch commits
        Repository repo = gitAnalyzer.openRepository(project.getLocalPath());
        List<CommitRecord> commits;
        try {
            commits = gitAnalyzer.fetchCommits(repo);
        } finally {
            repo.close();
        }

        // 2) Map email -> member
        List<TeamMember> members = memberDAO.findByProject(projectId);
        Map<String, TeamMember> emailMap = new HashMap<>();
        for (TeamMember m : members) {
            if (m.getGitEmail() != null) {
                emailMap.put(m.getGitEmail().toLowerCase(), m);
            }
        }
        for (CommitRecord c : commits) {
            if (c.getAuthorEmail() != null) {
                TeamMember m = emailMap.get(c.getAuthorEmail().toLowerCase());
                if (m != null) c.setTeamMemberId(m.getTeamMemberId());
            }
        }

        // 3) Persist commits
        commitDAO.saveBatch(projectId, commits);

        // 4) Tính score
        Map<Integer, Integer>  linesByMember  = new HashMap<>();
        Map<Integer, Integer>  commitsByMember = new HashMap<>();
        Map<Integer, Set<String>> activeDaysByMember = new HashMap<>();
        int totalLines = 0;
        for (CommitRecord c : commits) {
            if (c.getTeamMemberId() == null) continue;
            int tmid = c.getTeamMemberId();
            linesByMember.merge(tmid, c.getLinesAdded(), Integer::sum);
            commitsByMember.merge(tmid, 1, Integer::sum);
            totalLines += c.getLinesAdded();
            Set<String> days = activeDaysByMember.computeIfAbsent(tmid, k -> new HashSet<>());
            days.add(c.getCommitDate().toString().substring(0, 10));
        }

        int n = members.size();
        double fairShare = n > 0 ? 100.0 / n : 0.0;

        for (TeamMember m : members) {
            ContributionScore s = new ContributionScore();
            s.setProjectId(projectId);
            s.setTeamMemberId(m.getTeamMemberId());
            s.setTotalCommits(commitsByMember.getOrDefault(m.getTeamMemberId(), 0));
            s.setTotalLinesAdded(linesByMember.getOrDefault(m.getTeamMemberId(), 0));
            s.setActiveDays(activeDaysByMember.getOrDefault(m.getTeamMemberId(), new HashSet<>()).size());

            double pct = (totalLines == 0) ? 0 : ((double) s.getTotalLinesAdded() / totalLines) * 100.0;
            s.setContributionPct(Math.round(pct * 100.0) / 100.0);

            // Fairness: tính khoảng cách với fair share và chuẩn hoá về 0-100
            //   fairness_score = 100 - |pct - fairShare|*k  (k để phạt lệch nhiều)
            double diff = Math.abs(pct - fairShare);
            double fairness = Math.max(0.0, 100.0 - diff * 1.5);
            s.setFairnessScore(Math.round(fairness * 100.0) / 100.0);

            // Status
            if (pct < LOW_THRESHOLD) {
                s.setStatus("LOW");
            } else if (n > 0 && pct > HIGH_MULTIPLIER * fairShare) {
                s.setStatus("HIGH");
            } else {
                s.setStatus("NORMAL");
            }

            scoreDAO.upsert(s);
        }

        long duration = System.currentTimeMillis() - start;
        System.out.println(String.format(
            "[AnalyticsService] project=%d commits=%d duration=%dms totalLines=%d",
            projectId, commits.size(), duration, totalLines
        ));

        return commits.size();
    }

    /**
     * Lấy danh sách điểm của 1 project (cho Dashboard).
     */
    public List<ContributionScore> getScores(int projectId)
            throws SQLException, ClassNotFoundException {
        return scoreDAO.findByProject(projectId);
    }
}
