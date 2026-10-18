package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.SubmissionFile;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SubmissionFileDAO {

    public int insert(SubmissionFile f) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO SubmissionFile(submission_id, file_name, stored_name, file_path, file_size, content_type) "
                   + "VALUES(?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, f.getSubmissionId());
            ps.setString(2, f.getFileName());
            ps.setString(3, f.getStoredName());
            ps.setString(4, f.getFilePath());
            ps.setLong(5, f.getFileSize());
            ps.setString(6, f.getContentType());
            int n = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) f.setFileId(keys.getInt(1));
            }
            return n;
        }
    }

    public List<SubmissionFile> findBySubmission(int submissionId) throws SQLException, ClassNotFoundException {
        List<SubmissionFile> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT file_id, submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at "
              + "FROM SubmissionFile WHERE submission_id = ? ORDER BY uploaded_at ASC")) {
            ps.setInt(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public SubmissionFile findById(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT file_id, submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at "
              + "FROM SubmissionFile WHERE file_id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public int delete(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM SubmissionFile WHERE file_id = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        }
    }

    private SubmissionFile map(ResultSet rs) throws SQLException {
        SubmissionFile f = new SubmissionFile();
        f.setFileId(rs.getInt("file_id"));
        f.setSubmissionId(rs.getInt("submission_id"));
        f.setFileName(rs.getString("file_name"));
        f.setStoredName(rs.getString("stored_name"));
        f.setFilePath(rs.getString("file_path"));
        f.setFileSize(rs.getLong("file_size"));
        f.setContentType(rs.getString("content_type"));
        f.setUploadedAt(rs.getTimestamp("uploaded_at"));
        return f;
    }
}
