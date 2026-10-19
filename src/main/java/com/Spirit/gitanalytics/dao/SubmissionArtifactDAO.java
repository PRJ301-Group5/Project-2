package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.SubmissionArtifact;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class SubmissionArtifactDAO {

    /** Insert artifact mới (UPSERT theo submission_id). */
    public int upsert(SubmissionArtifact a) throws SQLException, ClassNotFoundException {
        // Nếu đã có -> UPDATE, ngược lại INSERT
        SubmissionArtifact existing = findBySubmission(a.getSubmissionId());
        if (existing == null) {
            String sql = "INSERT INTO SubmissionArtifact(submission_id, zip_stored_name, zip_path, "
                       + "zip_size, sha256, file_count, verification_status) "
                       + "VALUES(?,?,?,?,?,?,?)";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, a.getSubmissionId());
                ps.setString(2, a.getZipStoredName());
                ps.setString(3, a.getZipPath());
                ps.setLong(4, a.getZipSize());
                ps.setString(5, a.getSha256());
                ps.setInt(6, a.getFileCount());
                ps.setString(7, a.getVerificationStatus() == null ? "PENDING" : a.getVerificationStatus());
                int n = ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) a.setArtifactId(keys.getInt(1));
                }
                return n;
            }
        } else {
            String sql = "UPDATE SubmissionArtifact SET zip_stored_name=?, zip_path=?, zip_size=?, "
                       + "sha256=?, file_count=?, verification_status=?, verified_at=NULL "
                       + "WHERE submission_id=?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, a.getZipStoredName());
                ps.setString(2, a.getZipPath());
                ps.setLong(3, a.getZipSize());
                ps.setString(4, a.getSha256());
                ps.setInt(5, a.getFileCount());
                ps.setString(6, a.getVerificationStatus() == null ? "PENDING" : a.getVerificationStatus());
                ps.setInt(7, a.getSubmissionId());
                return ps.executeUpdate();
            }
        }
    }

    public SubmissionArtifact findBySubmission(int submissionId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT artifact_id, submission_id, zip_stored_name, zip_path, zip_size, "
                   + "sha256, file_count, verification_status, created_at, verified_at "
                   + "FROM SubmissionArtifact WHERE submission_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, submissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public int markVerified(int submissionId, String status) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE SubmissionArtifact SET verification_status = ?, verified_at = GETDATE() "
                   + "WHERE submission_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, submissionId);
            return ps.executeUpdate();
        }
    }

    private SubmissionArtifact map(ResultSet rs) throws SQLException {
        SubmissionArtifact a = new SubmissionArtifact();
        a.setArtifactId(rs.getInt("artifact_id"));
        a.setSubmissionId(rs.getInt("submission_id"));
        a.setZipStoredName(rs.getString("zip_stored_name"));
        a.setZipPath(rs.getString("zip_path"));
        a.setZipSize(rs.getLong("zip_size"));
        a.setSha256(rs.getString("sha256"));
        a.setFileCount(rs.getInt("file_count"));
        a.setVerificationStatus(rs.getString("verification_status"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setVerifiedAt(rs.getTimestamp("verified_at"));
        return a;
    }
}
