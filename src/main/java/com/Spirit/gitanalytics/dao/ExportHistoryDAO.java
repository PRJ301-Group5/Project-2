package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.ExportHistory;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * ExportHistoryDAO - Persist lịch sử export CSV + audit.
 */
public class ExportHistoryDAO {

    public int insert(ExportHistory h) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO ExportHistory (project_id, exported_by, file_name, file_path, file_bytes, row_count, exported_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, GETDATE()); "
                   + "SELECT SCOPE_IDENTITY() AS id;";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, h.getProjectId());
            ps.setString(2, h.getExportedBy());
            ps.setString(3, h.getFileName());
            ps.setString(4, h.getFilePath());
            if (h.getFileBytes() == null) ps.setNull(5, java.sql.Types.INTEGER);
            else ps.setInt(5, h.getFileBytes());
            if (h.getRowCount() == null) ps.setNull(6, java.sql.Types.INTEGER);
            else ps.setInt(6, h.getRowCount());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    public List<ExportHistory> listRecent(int limit) throws SQLException, ClassNotFoundException {
        List<ExportHistory> list = new ArrayList<>();
        String sql = "SELECT history_id, project_id, exported_by, file_name, file_path, file_bytes, row_count, exported_at "
                   + "FROM ExportHistory ORDER BY exported_at DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ExportHistory h = new ExportHistory();
                    h.setHistoryId(rs.getInt("history_id"));
                    h.setProjectId(rs.getInt("project_id"));
                    h.setExportedBy(rs.getString("exported_by"));
                    h.setFileName(rs.getString("file_name"));
                    h.setFilePath(rs.getString("file_path"));
                    h.setFileBytes((Integer) rs.getObject("file_bytes"));
                    h.setRowCount((Integer) rs.getObject("row_count"));
                    h.setExportedAt(rs.getTimestamp("exported_at"));
                    list.add(h);
                }
            }
        }
        return list;
    }

    public List<ExportHistory> findByProject(int projectId) throws SQLException, ClassNotFoundException {
        List<ExportHistory> list = new ArrayList<>();
        String sql = "SELECT history_id, project_id, exported_by, file_name, file_path, file_bytes, row_count, exported_at "
                   + "FROM ExportHistory WHERE project_id = ? ORDER BY exported_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ExportHistory h = new ExportHistory();
                    h.setHistoryId(rs.getInt("history_id"));
                    h.setProjectId(rs.getInt("project_id"));
                    h.setExportedBy(rs.getString("exported_by"));
                    h.setFileName(rs.getString("file_name"));
                    h.setFilePath(rs.getString("file_path"));
                    h.setFileBytes((Integer) rs.getObject("file_bytes"));
                    h.setRowCount((Integer) rs.getObject("row_count"));
                    h.setExportedAt(rs.getTimestamp("exported_at"));
                    list.add(h);
                }
            }
        }
        return list;
    }
}
