package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.Submission;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class SubmissionDAO {

    private static final String SELECT_BASE =
        "SELECT s.submission_id, s.assignment_id, s.student_id, s.content, s.file_path, s.submitted_at, "
      + "u.full_name AS student_name, a.title AS assignment_title, "
      + "g.score, g.feedback "
      + "FROM Submission s "
      + "JOIN AppUser u ON s.student_id = u.user_id "
      + "JOIN Assignment a ON s.assignment_id = a.assignment_id "
      + "LEFT JOIN Grade g ON s.submission_id = g.submission_id ";

    public Submission findById(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BASE + "WHERE s.submission_id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public Submission findByAssignmentAndStudent(int assignmentId, int studentId)
            throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BASE
                     + "WHERE s.assignment_id = ? AND s.student_id = ?")) {
            ps.setInt(1, assignmentId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public List<Submission> findByAssignment(int assignmentId) throws SQLException, ClassNotFoundException {
        List<Submission> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BASE
                     + "WHERE s.assignment_id = ? ORDER BY s.submitted_at DESC")) {
            ps.setInt(1, assignmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Submission> findByStudent(int studentId) throws SQLException, ClassNotFoundException {
        List<Submission> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BASE
                     + "WHERE s.student_id = ? ORDER BY s.submitted_at DESC")) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public int insert(Submission s) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO Submission(assignment_id, student_id, content, file_path) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, s.getAssignmentId());
            ps.setInt(2, s.getStudentId());
            ps.setString(3, s.getContent());
            if (s.getFilePath() == null) ps.setNull(4, Types.VARCHAR); else ps.setString(4, s.getFilePath());
            int n = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) s.setSubmissionId(keys.getInt(1));
            }
            return n;
        }
    }

    public int update(Submission s) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Submission SET content=?, file_path=? WHERE submission_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getContent());
            if (s.getFilePath() == null) ps.setNull(2, Types.VARCHAR); else ps.setString(2, s.getFilePath());
            ps.setInt(3, s.getSubmissionId());
            return ps.executeUpdate();
        }
    }

    public int delete(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM Submission WHERE submission_id = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        }
    }

    private Submission map(ResultSet rs) throws SQLException {
        Submission s = new Submission();
        s.setSubmissionId(rs.getInt("submission_id"));
        s.setAssignmentId(rs.getInt("assignment_id"));
        s.setStudentId(rs.getInt("student_id"));
        s.setContent(rs.getString("content"));
        s.setFilePath(rs.getString("file_path"));
        s.setSubmittedAt(rs.getTimestamp("submitted_at"));
        s.setStudentName(rs.getString("student_name"));
        s.setAssignmentTitle(rs.getString("assignment_title"));
        double sc = rs.getDouble("score");
        s.setScore(rs.wasNull() ? null : sc);
        s.setFeedback(rs.getString("feedback"));
        return s;
    }
}
