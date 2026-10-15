package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.CommitRecord;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * CommitRecordDAO - Lưu và truy vấn các commit đã analyze.
 * Sử dụng batch insert để tăng tốc khi insert hàng trăm commits.
 */
public class CommitRecordDAO {

    private static final int BATCH_SIZE = 100;

    public int saveBatch(int projectId, List<CommitRecord> commits)
            throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO CommitRecord(project_id, team_member_id, commit_hash, author_name, "
                   + "author_email, commit_date, message, files_changed, lines_added, lines_deleted) "
                   + "VALUES(?,?,?,?,?,?,?,?,?,?)";
        int inserted = 0;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            con.setAutoCommit(false);
            int batch = 0;
            for (CommitRecord c : commits) {
                ps.setInt(1, projectId);
                if (c.getTeamMemberId() != null) ps.setInt(2, c.getTeamMemberId());
                else ps.setNull(2, java.sql.Types.INTEGER);
                ps.setString(3, c.getCommitHash());
                ps.setString(4, c.getAuthorName());
                ps.setString(5, c.getAuthorEmail());
                ps.setTimestamp(6, c.getCommitDate());
                ps.setString(7, c.getMessage());
                ps.setInt(8, c.getFilesChanged());
                ps.setInt(9, c.getLinesAdded());
                ps.setInt(10, c.getLinesDeleted());
                ps.addBatch();
                batch++;
                if (batch % BATCH_SIZE == 0) {
                    int[] res = ps.executeBatch();
                    for (int r : res) if (r > 0) inserted += r;
                }
            }
            int[] res = ps.executeBatch();
            for (int r : res) if (r > 0) inserted += r;
            con.commit();
        } catch (SQLException ex) {
            throw ex;
        }
        return inserted;
    }

    /**
     * Map lại team_member_id cho các commit dựa trên author_email.
     * Sau khi map, ta có thể aggregate theo member.
     */
    public List<CommitRecord> findByProject(int projectId)
            throws SQLException, ClassNotFoundException {
        List<CommitRecord> list = new ArrayList<>();
        String sql = "SELECT commit_id, project_id, team_member_id, commit_hash, author_name, "
                   + "author_email, commit_date, message, files_changed, lines_added, lines_deleted "
                   + "FROM CommitRecord WHERE project_id = ? ORDER BY commit_date";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CommitRecord c = new CommitRecord();
                    c.setCommitId(rs.getInt("commit_id"));
                    c.setProjectId(rs.getInt("project_id"));
                    int tmid = rs.getInt("team_member_id");
                    c.setTeamMemberId(rs.wasNull() ? null : tmid);
                    c.setCommitHash(rs.getString("commit_hash"));
                    c.setAuthorName(rs.getString("author_name"));
                    c.setAuthorEmail(rs.getString("author_email"));
                    c.setCommitDate(rs.getTimestamp("commit_date"));
                    c.setMessage(rs.getString("message"));
                    c.setFilesChanged(rs.getInt("files_changed"));
                    c.setLinesAdded(rs.getInt("lines_added"));
                    c.setLinesDeleted(rs.getInt("lines_deleted"));
                    list.add(c);
                }
            }
        }
        return list;
    }
}
