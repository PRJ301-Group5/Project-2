package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.Notification;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public List<Notification> findByUser(int userId, int limit) throws SQLException, ClassNotFoundException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT TOP (?) notification_id, user_id, title, body, link, is_read, created_at "
                   + "FROM Notification WHERE user_id = ? ORDER BY created_at DESC";
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

    public int countUnread(int userId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM Notification WHERE user_id = ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int insert(Notification n) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO Notification(user_id, title, body, link) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, n.getUserId());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getBody());
            ps.setString(4, n.getLink());
            int rows = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) n.setNotificationId(keys.getInt(1));
            }
            return rows;
        }
    }

    public int markRead(int notificationId, int userId) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Notification SET is_read = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate();
        }
    }

    public int markAllRead(int userId) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Notification SET is_read = 1 WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate();
        }
    }

    public int delete(int notificationId, int userId) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM Notification WHERE notification_id = ? AND user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate();
        }
    }

    private Notification map(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setUserId(rs.getInt("user_id"));
        n.setTitle(rs.getString("title"));
        n.setBody(rs.getString("body"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
