package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * TeamMember - Quan hệ giữa Project và Student, kèm git email để map commits.
 */
public class TeamMember {
    private int teamMemberId;
    private int projectId;
    private int studentId;
    private String gitEmail;
    private String role;

    // Helper - không lưu DB
    private String fullName;
    private String studentCode;

    public int getTeamMemberId() { return teamMemberId; }
    public void setTeamMemberId(int teamMemberId) { this.teamMemberId = teamMemberId; }

    public int getProjectId() { return projectId; }
    public void setProjectId(int projectId) { this.projectId = projectId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getGitEmail() { return gitEmail; }
    public void setGitEmail(String gitEmail) { this.gitEmail = gitEmail; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }
}
