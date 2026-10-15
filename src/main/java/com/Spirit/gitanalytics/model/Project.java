package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * Project - POJO đại diện cho một dự án cần phân tích Git.
 */
public class Project {
    private int projectId;
    private String projectCode;
    private String projectName;
    private String repoUrl;
    private String localPath;
    private Timestamp startDate;
    private Timestamp endDate;
    private Timestamp createdAt;

    public Project() {}

    public Project(int projectId, String projectCode, String projectName,
                   String repoUrl, String localPath) {
        this.projectId = projectId;
        this.projectCode = projectCode;
        this.projectName = projectName;
        this.repoUrl = repoUrl;
        this.localPath = localPath;
    }

    public int getProjectId() { return projectId; }
    public void setProjectId(int projectId) { this.projectId = projectId; }

    public String getProjectCode() { return projectCode; }
    public void setProjectCode(String projectCode) { this.projectCode = projectCode; }

    public String getProjectName() { return projectName; }
    public void setProjectName(String projectName) { this.projectName = projectName; }

    public String getRepoUrl() { return repoUrl; }
    public void setRepoUrl(String repoUrl) { this.repoUrl = repoUrl; }

    public String getLocalPath() { return localPath; }
    public void setLocalPath(String localPath) { this.localPath = localPath; }

    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }

    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Project{code=" + projectCode + ", name=" + projectName + "}";
    }
}
