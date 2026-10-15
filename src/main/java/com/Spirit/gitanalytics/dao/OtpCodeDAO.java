package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.OtpCode;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class OtpCodeDAO {

    public int insert(OtpCode o) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO OtpCode(target, purpose, code, expires_at) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, o.getTarget());
            ps.setString(2, o.getPurpose());
            ps.setString(3, o.getCode());
            ps.setTimestamp(4, o.getExpiresAt());
            int n = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) o.setOtpId(keys.getInt(1));
            }
            return n;
        }
    }

    /** Tìm OTP mới nhất còn hiệu lực (chưa dùng, chưa hết hạn). */
    public OtpCode findValid(String target, String purpose, String code)
            throws SQLException, ClassNotFoundException {
        String sql = "SELECT TOP 1 otp_id, target, purpose, code, expires_at, is_used, created_at "
                   + "FROM OtpCode "
                   + "WHERE target = ? AND purpose = ? AND code = ? AND is_used = 0 AND expires_at > GETDATE() "
                   + "ORDER BY created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, target);
            ps.setString(2, purpose);
            ps.setString(3, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    OtpCode o = new OtpCode();
                    o.setOtpId(rs.getInt("otp_id"));
                    o.setTarget(rs.getString("target"));
                    o.setPurpose(rs.getString("purpose"));
                    o.setCode(rs.getString("code"));
                    o.setExpiresAt(rs.getTimestamp("expires_at"));
                    o.setUsed(rs.getBoolean("is_used"));
                    o.setCreatedAt(rs.getTimestamp("created_at"));
                    return o;
                }
            }
        }
        return null;
    }

    public int markUsed(int otpId) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE OtpCode SET is_used = 1 WHERE otp_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, otpId);
            return ps.executeUpdate();
        }
    }
}
