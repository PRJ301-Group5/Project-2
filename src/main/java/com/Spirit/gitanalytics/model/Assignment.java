package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * Assignment - Bài tập do giảng viên tạo.
 */
public class Assignment {
    private int assignmentId;
    private int classId;
    private String title;
    private String description;
    private String promptFile;
    private Timestamp dueDate;
    private double maxScore;
    private int createdBy;
    private Timestamp createdAt;

    // joined
    private String classCode;
    private String className;
    private int submissionCount;

    public Assignment() {}

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public int getClassId() { return classId; }
    public void setClassId(int classId) { this.classId = classId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getPromptFile() { return promptFile; }
    public void setPromptFile(String promptFile) { this.promptFile = promptFile; }

    public Timestamp getDueDate() { return dueDate; }
    public void setDueDate(Timestamp dueDate) { this.dueDate = dueDate; }

    public double getMaxScore() { return maxScore; }
    public void setMaxScore(double maxScore) { this.maxScore = maxScore; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getClassCode() { return classCode; }
    public void setClassCode(String classCode) { this.classCode = classCode; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public int getSubmissionCount() { return submissionCount; }
    public void setSubmissionCount(int submissionCount) { this.submissionCount = submissionCount; }
}
