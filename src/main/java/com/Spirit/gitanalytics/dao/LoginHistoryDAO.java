package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.LoginHistory;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * LoginHistoryDAO - Truy vấn & ghi lịch sử đăng nhập.
 */
public class LoginHistoryDAO {

    /** Ghi 1 lần đăng nhập (thành công hoặc thất bại). */
    public int insert(LoginHistory h) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO LoginHistory(user_id, username, ip_address, user_agent, "
                   + "login_status, failure_reason) VALUES(?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            if (h.getUserId() == null) ps.setNull(1, Types.INTEGER);
            else ps.setInt(1, h.getUserId());
            ps.setString(2, h.getUsername());
            ps.setString(3, h.getIpAddress());
            ps.setString(4, h.getUserAgent());
            ps.setString(5, h.getLoginStatus() == null ? "SUCCESS" : h.getLoginStatus());
            ps.setString(6, h.getFailureReason());
            int rows = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) h.setLoginId(keys.getInt(1));
            }
            return rows;
        }
    }

    /** Lịch sử đăng nhập của 1 user (mới nhất trước). */
    public List<LoginHistory> findByUser(int userId, int limit) throws SQLException, ClassNotFoundException {
        List<LoginHistory> list = new ArrayList<>();
        String sql = "SELECT TOP (?) login_id, user_id, username, login_at, ip_address, "
                   + "user_agent, login_status, failure_reason "
                   + "FROM LoginHistory WHERE user_id = ? ORDER BY login_at DESC, login_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /** Lịch sử đăng nhập gần đây của toàn hệ thống (dành cho ADMIN). */
    public List<LoginHistory> listRecent(int limit) throws SQLException, ClassNotFoundException {
        List<LoginHistory> list = new ArrayList<>();
        String sql = "SELECT TOP (?) login_id, user_id, username, login_at, ip_address, "
                   + "user_agent, login_status, failure_reason "
                   + "FROM LoginHistory ORDER BY login_at DESC, login_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /** Đếm số lần đăng nhập thất bại gần đây của 1 user (phát hiện brute-force). */
    public int countRecentFailures(int userId, int minutes) throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM LoginHistory "
                   + "WHERE user_id = ? AND login_status = 'FAILED' "
                   + "AND login_at >= DATEADD(MINUTE, -?, GETDATE())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, minutes);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /** Lần đăng nhập thành công gần nhất của user (null nếu chưa có). */
    public LoginHistory findLastSuccess(int userId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT TOP 1 login_id, user_id, username, login_at, ip_address, "
                   + "user_agent, login_status, failure_reason "
                   + "FROM LoginHistory WHERE user_id = ? AND login_status = 'SUCCESS' "
                   + "ORDER BY login_at DESC, login_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /** Cập nhật AppUser.last_login sau khi đăng nhập thành công. */
    public int updateLastLogin(int userId) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE AppUser SET last_login = GETDATE() WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate();
        }
    }

    /** Xoá lịch sử đăng nhập cũ hơn N ngày (dọn dẹp). */
    public int purgeOlderThan(int days) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM LoginHistory WHERE login_at < DATEADD(DAY, -?, GETDATE())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            return ps.executeUpdate();
        }
    }

    private LoginHistory map(ResultSet rs) throws SQLException {
        LoginHistory h = new LoginHistory();
        h.setLoginId(rs.getInt("login_id"));
        int uid = rs.getInt("user_id");
        h.setUserId(rs.wasNull() ? null : uid);
        h.setUsername(rs.getString("username"));
        h.setLoginAt(rs.getTimestamp("login_at"));
        h.setIpAddress(rs.getString("ip_address"));
        h.setUserAgent(rs.getString("user_agent"));
        h.setLoginStatus(rs.getString("login_status"));
        h.setFailureReason(rs.getString("failure_reason"));
        return h;
    }
}
