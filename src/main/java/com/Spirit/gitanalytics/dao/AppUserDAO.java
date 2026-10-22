package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * AppUserDAO - Data Access Object cho bảng AppUser.
 * Dùng PreparedStatement để chống SQL injection.
 */
public class AppUserDAO {

    public AppUser findByUsername(String username) throws SQLException, ClassNotFoundException {
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role, user_code, is_active, created_at, last_login "
                   + "FROM AppUser WHERE username = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public AppUser findByEmail(String email) throws SQLException, ClassNotFoundException {
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role, user_code, is_active, created_at, last_login "
                   + "FROM AppUser WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /** Tìm tài khoản theo mã định danh (MSSV / mã thẻ GV). */
    public AppUser findByUserCode(String userCode) throws SQLException, ClassNotFoundException {
        if (userCode == null || userCode.isEmpty()) return null;
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role, user_code, is_active, created_at, last_login "
                   + "FROM AppUser WHERE user_code = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public AppUser findById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role, user_code, is_active, created_at, last_login "
                   + "FROM AppUser WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public List<AppUser> findByRole(String role) throws SQLException, ClassNotFoundException {
        List<AppUser> list = new ArrayList<>();
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role, user_code, is_active, created_at, last_login "
                   + "FROM AppUser WHERE role = ? ORDER BY full_name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /** Student đã enroll vào class. Dùng cho trang manage. */
    public List<AppUser> findStudentsInClass(int classId) throws SQLException, ClassNotFoundException {
        List<AppUser> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.username, u.password_hash, u.full_name, u.email, u.phone, u.role, u.user_code, u.is_active, u.created_at, u.last_login "
                   + "FROM AppUser u JOIN Enrollment e ON u.user_id = e.student_id "
                   + "WHERE e.class_id = ? AND u.role = 'STUDENT' ORDER BY u.full_name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public int insert(AppUser u) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO AppUser(username, password_hash, full_name, email, phone, role, user_code) "
                   + "VALUES(?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPasswordHash());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getPhone());
            ps.setString(6, u.getRole());
            if (u.getUserCode() == null) ps.setNull(7, Types.VARCHAR); else ps.setString(7, u.getUserCode());
            int affected = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) u.setUserId(keys.getInt(1));
            }
            return affected;
        }
    }

    public int updatePassword(int userId, String newHash) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE AppUser SET password_hash = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            return ps.executeUpdate();
        }
    }

    public int updateInfo(AppUser u) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE AppUser SET full_name = ?, phone = ? WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getPhone());
            ps.setInt(3, u.getUserId());
            return ps.executeUpdate();
        }
    }

    public int delete(int id) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM AppUser WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        }
    }

    private AppUser map(ResultSet rs) throws SQLException {
        AppUser u = new AppUser();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        u.setUserCode(rs.getString("user_code"));
        u.setActive(rs.getBoolean("is_active"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        try { u.setLastLogin(rs.getTimestamp("last_login")); } catch (SQLException ignore) {}
        return u;
    }
}
