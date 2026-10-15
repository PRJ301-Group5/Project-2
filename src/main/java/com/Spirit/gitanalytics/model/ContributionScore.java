package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * ContributionScore - Điểm đóng góp đã được tính toán và normalize.
 */
public class ContributionScore {
    private int scoreId;
    private int projectId;
    private int teamMemberId;
    private int totalCommits;
    private int totalLinesAdded;
    private int totalLinesDeleted;
    private int activeDays;
    private double contributionPct;   // % so với tổng nhóm
    private double fairnessScore;     // 0-100
    private String status;            // NORMAL/LOW/HIGH
    private Timestamp lastAnalyzed;

    // Helper cho view
    private String fullName;
    private String studentCode;
    private String role;

    public int getScoreId() { return scoreId; }
    public void setScoreId(int scoreId) { this.scoreId = scoreId; }

    public int getProjectId() { return projectId; }
    public void setProjectId(int projectId) { this.projectId = projectId; }

    public int getTeamMemberId() { return teamMemberId; }
    public void setTeamMemberId(int teamMemberId) { this.teamMemberId = teamMemberId; }

    public int getTotalCommits() { return totalCommits; }
    public void setTotalCommits(int totalCommits) { this.totalCommits = totalCommits; }

    public int getTotalLinesAdded() { return totalLinesAdded; }
    public void setTotalLinesAdded(int totalLinesAdded) { this.totalLinesAdded = totalLinesAdded; }

    public int getTotalLinesDeleted() { return totalLinesDeleted; }
    public void setTotalLinesDeleted(int totalLinesDeleted) { this.totalLinesDeleted = totalLinesDeleted; }

    public int getActiveDays() { return activeDays; }
    public void setActiveDays(int activeDays) { this.activeDays = activeDays; }

    public double getContributionPct() { return contributionPct; }
    public void setContributionPct(double contributionPct) { this.contributionPct = contributionPct; }

    public double getFairnessScore() { return fairnessScore; }
    public void setFairnessScore(double fairnessScore) { this.fairnessScore = fairnessScore; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getLastAnalyzed() { return lastAnalyzed; }
    public void setLastAnalyzed(Timestamp lastAnalyzed) { this.lastAnalyzed = lastAnalyzed; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
