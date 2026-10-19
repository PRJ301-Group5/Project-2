package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * SubmissionArtifact - Mỗi submission có thể được nén thành 1 ZIP
 * và tính SHA-256 hash để xác thực tính toàn vẹn.
 *
 * Map tới bảng dbo.SubmissionArtifact.
 */
public class SubmissionArtifact {
    private int artifactId;
    private int submissionId;
    private String zipStoredName;        // tên file ZIP trên disk (vd: sub_3_<uuid>.zip)
    private String zipPath;              // đường dẫn tương đối trong /uploads
    private long zipSize;                // bytes
    private String sha256;               // hex string 64 ký tự
    private int fileCount;               // số file gốc được nén
    private String verificationStatus;   // PENDING / VERIFIED / TAMPERED / MISSING
    private Timestamp createdAt;
    private Timestamp verifiedAt;

    public SubmissionArtifact() {}

    public int getArtifactId() { return artifactId; }
    public void setArtifactId(int artifactId) { this.artifactId = artifactId; }

    public int getSubmissionId() { return submissionId; }
    public void setSubmissionId(int submissionId) { this.submissionId = submissionId; }

    public String getZipStoredName() { return zipStoredName; }
    public void setZipStoredName(String zipStoredName) { this.zipStoredName = zipStoredName; }

    public String getZipPath() { return zipPath; }
    public void setZipPath(String zipPath) { this.zipPath = zipPath; }

    public long getZipSize() { return zipSize; }
    public void setZipSize(long zipSize) { this.zipSize = zipSize; }

    public String getSha256() { return sha256; }
    public void setSha256(String sha256) { this.sha256 = sha256; }

    public int getFileCount() { return fileCount; }
    public void setFileCount(int fileCount) { this.fileCount = fileCount; }

    public String getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(String verificationStatus) { this.verificationStatus = verificationStatus; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getVerifiedAt() { return verifiedAt; }
    public void setVerifiedAt(Timestamp verifiedAt) { this.verifiedAt = verifiedAt; }

    public String getHumanSize() {
        long b = zipSize;
        if (b < 1024) return b + " B";
        if (b < 1024 * 1024) return String.format("%.1f KB", b / 1024.0);
        if (b < 1024L * 1024 * 1024) return String.format("%.1f MB", b / (1024.0 * 1024));
        return String.format("%.2f GB", b / (1024.0 * 1024 * 1024));
    }
}
