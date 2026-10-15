package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * ExportHistory - Lịch sử export CSV, vừa audit vừa giữ đường dẫn file.
 */
public class ExportHistory {
    private int historyId;
    private int projectId;
    private String exportedBy;
    private String fileName;
    private String filePath;
    private Integer fileBytes;
    private Integer rowCount;
    private Timestamp exportedAt;

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getProjectId() { return projectId; }
    public void setProjectId(int projectId) { this.projectId = projectId; }

    public String getExportedBy() { return exportedBy; }
    public void setExportedBy(String exportedBy) { this.exportedBy = exportedBy; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public Integer getFileBytes() { return fileBytes; }
    public void setFileBytes(Integer fileBytes) { this.fileBytes = fileBytes; }

    public Integer getRowCount() { return rowCount; }
    public void setRowCount(Integer rowCount) { this.rowCount = rowCount; }

    public Timestamp getExportedAt() { return exportedAt; }
    public void setExportedAt(Timestamp exportedAt) { this.exportedAt = exportedAt; }
}
