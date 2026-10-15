package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * Grade - Điểm + feedback do giảng viên chấm.
 */
public class Grade {
    private int gradeId;
    private int submissionId;
    private int graderId;
    private double score;
    private String feedback;
    private Timestamp gradedAt;

    public Grade() {}

    public int getGradeId() { return gradeId; }
    public void setGradeId(int gradeId) { this.gradeId = gradeId; }

    public int getSubmissionId() { return submissionId; }
    public void setSubmissionId(int submissionId) { this.submissionId = submissionId; }

    public int getGraderId() { return graderId; }
    public void setGraderId(int graderId) { this.graderId = graderId; }

    public double getScore() { return score; }
    public void setScore(double score) { this.score = score; }

    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }

    public Timestamp getGradedAt() { return gradedAt; }
    public void setGradedAt(Timestamp gradedAt) { this.gradedAt = gradedAt; }
}
