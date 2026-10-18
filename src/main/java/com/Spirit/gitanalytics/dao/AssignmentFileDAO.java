package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.AssignmentFile;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AssignmentFileDAO {

    public int insert(AssignmentFile f) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO AssignmentFile(assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by) "
                   + "VALUES(?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, f.getAssignmentId());
            ps.setString(2, f.getFileName());
            ps.setString(3, f.getStoredName());
            ps.setString(4, f.getFilePath());
            ps.setLong(5, f.getFileSize());
            ps.setString(6, f.getContentType());
            ps.setInt(7, f.getUploadedBy());
            int n = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) f.setFileId(keys.getInt(1));
            }
            return n;
        }
    }

    public List<AssignmentFile> findByAssignment(int assignmentId) throws SQLException, ClassNotFoundException {
        List<AssignmentFile> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT file_id, assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at "
              + "FROM AssignmentFile WHERE assignment_id = ? ORDER BY uploaded_at ASC")) {
            ps.setInt(1, assignmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public AssignmentFile findById(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT file_id, assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at "
              + "FROM AssignmentFile WHERE file_id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public int delete(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM AssignmentFile WHERE file_id = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        }
    }

    private AssignmentFile map(ResultSet rs) throws SQLException {
        AssignmentFile f = new AssignmentFile();
        f.setFileId(rs.getInt("file_id"));
        f.setAssignmentId(rs.getInt("assignment_id"));
        f.setFileName(rs.getString("file_name"));
        f.setStoredName(rs.getString("stored_name"));
        f.setFilePath(rs.getString("file_path"));
        f.setFileSize(rs.getLong("file_size"));
        f.setContentType(rs.getString("content_type"));
        f.setUploadedBy(rs.getInt("uploaded_by"));
        f.setUploadedAt(rs.getTimestamp("uploaded_at"));
        return f;
    }
}
