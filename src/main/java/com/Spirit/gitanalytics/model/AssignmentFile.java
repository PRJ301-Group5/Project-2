package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * AssignmentFile - file đính kèm do teacher upload lên assignment.
 * Map tới bảng dbo.AssignmentFile.
 */
public class AssignmentFile {
    private int fileId;
    private int assignmentId;
    private String fileName;     // original name user uploaded
    private String storedName;   // server-side stored name (uuid-prefixed)
    private String filePath;     // relative path inside /uploads
    private long fileSize;
    private String contentType;
    private int uploadedBy;
    private Timestamp uploadedAt;

    public AssignmentFile() {}

    public int getFileId() { return fileId; }
    public void setFileId(int fileId) { this.fileId = fileId; }

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getStoredName() { return storedName; }
    public void setStoredName(String storedName) { this.storedName = storedName; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }

    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }

    public int getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(int uploadedBy) { this.uploadedBy = uploadedBy; }

    public Timestamp getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(Timestamp uploadedAt) { this.uploadedAt = uploadedAt; }

    /** Human readable file size (e.g. "1.2 MB"). */
    public String getHumanSize() {
        if (fileSize < 1024) return fileSize + " B";
        if (fileSize < 1024 * 1024) return String.format("%.1f KB", fileSize / 1024.0);
        if (fileSize < 1024L * 1024 * 1024) return String.format("%.1f MB", fileSize / (1024.0 * 1024));
        return String.format("%.2f GB", fileSize / (1024.0 * 1024 * 1024));
    }
}
