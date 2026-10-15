package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.Grade;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class GradeDAO {

    public Grade findBySubmission(int submissionId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT grade_id, submission_id, grader_id, score, feedback, graded_at "
                   + "FROM Grade WHERE submission_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Grade g = new Grade();
                    g.setGradeId(rs.getInt("grade_id"));
                    g.setSubmissionId(rs.getInt("submission_id"));
                    g.setGraderId(rs.getInt("grader_id"));
                    g.setScore(rs.getDouble("score"));
                    g.setFeedback(rs.getString("feedback"));
                    g.setGradedAt(rs.getTimestamp("graded_at"));
                    return g;
                }
            }
        }
        return null;
    }

    /** Upsert - tạo mới hoặc cập nhật nếu đã có. */
    public int upsert(Grade g) throws SQLException, ClassNotFoundException {
        Grade existing = findBySubmission(g.getSubmissionId());
        if (existing == null) {
            String sql = "INSERT INTO Grade(submission_id, grader_id, score, feedback) VALUES(?,?,?,?)";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, g.getSubmissionId());
                ps.setInt(2, g.getGraderId());
                ps.setDouble(3, g.getScore());
                ps.setString(4, g.getFeedback());
                return ps.executeUpdate();
            }
        } else {
            String sql = "UPDATE Grade SET grader_id=?, score=?, feedback=?, graded_at=GETDATE() WHERE grade_id=?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, g.getGraderId());
                ps.setDouble(2, g.getScore());
                ps.setString(3, g.getFeedback());
                ps.setInt(4, existing.getGradeId());
                return ps.executeUpdate();
            }
        }
    }

    public int delete(int gradeId) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM Grade WHERE grade_id = ?")) {
            ps.setInt(1, gradeId);
            return ps.executeUpdate();
        }
    }
}
