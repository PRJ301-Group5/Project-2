package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * CommitRecord - Lưu thông tin 1 commit trong quá trình analyze.
 */
public class CommitRecord {
    private int commitId;
    private int projectId;
    private Integer teamMemberId;        // nullable - chưa map được thì null
    private String commitHash;
    private String authorName;
    private String authorEmail;
    private Timestamp commitDate;
    private String message;
    private int filesChanged;
    private int linesAdded;
    private int linesDeleted;

    public int getCommitId() { return commitId; }
    public void setCommitId(int commitId) { this.commitId = commitId; }

    public int getProjectId() { return projectId; }
    public void setProjectId(int projectId) { this.projectId = projectId; }

    public Integer getTeamMemberId() { return teamMemberId; }
    public void setTeamMemberId(Integer teamMemberId) { this.teamMemberId = teamMemberId; }

    public String getCommitHash() { return commitHash; }
    public void setCommitHash(String commitHash) { this.commitHash = commitHash; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public String getAuthorEmail() { return authorEmail; }
    public void setAuthorEmail(String authorEmail) { this.authorEmail = authorEmail; }

    public Timestamp getCommitDate() { return commitDate; }
    public void setCommitDate(Timestamp commitDate) { this.commitDate = commitDate; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public int getFilesChanged() { return filesChanged; }
    public void setFilesChanged(int filesChanged) { this.filesChanged = filesChanged; }

    public int getLinesAdded() { return linesAdded; }
    public void setLinesAdded(int linesAdded) { this.linesAdded = linesAdded; }

    public int getLinesDeleted() { return linesDeleted; }
    public void setLinesDeleted(int linesDeleted) { this.linesDeleted = linesDeleted; }
}
