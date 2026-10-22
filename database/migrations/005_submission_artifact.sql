-- =============================================================
-- Spirit v2.2 - SubmissionArtifact (ZIP + SHA-256)
-- Mỗi submission có thể được nén thành 1 ZIP, hash SHA-256
-- để xác thực tính toàn vẹn khi teacher tải về.
-- Run: sqlcmd -S localhost -E -b -i migrations/005_submission_artifact.sql
-- =============================================================
USE Spirit_GitAnalytics;
GO

IF OBJECT_ID('dbo.SubmissionArtifact', 'U') IS NULL
CREATE TABLE dbo.SubmissionArtifact (
    artifact_id          INT IDENTITY(1,1) PRIMARY KEY,
    submission_id        INT NOT NULL UNIQUE,                -- 1 submission <=> 1 artifact
    zip_stored_name      VARCHAR(255) NOT NULL,
    zip_path             VARCHAR(500) NOT NULL,
    zip_size             BIGINT DEFAULT 0,
    sha256               CHAR(64) NOT NULL,                  -- hex 64 ký tự
    file_count           INT DEFAULT 0,                      -- số file gốc được nén
    verification_status  VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                          CHECK (verification_status IN ('PENDING','VERIFIED','TAMPERED','MISSING')),
    created_at           DATETIME DEFAULT GETDATE(),
    verified_at          DATETIME NULL,
    CONSTRAINT FK_Artifact_Sub FOREIGN KEY (submission_id)
        REFERENCES dbo.Submission(submission_id) ON DELETE CASCADE
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_Artifact_Sub' AND object_id = OBJECT_ID('dbo.SubmissionArtifact'))
    CREATE INDEX IX_Artifact_Sub ON dbo.SubmissionArtifact(submission_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_Artifact_Sha' AND object_id = OBJECT_ID('dbo.SubmissionArtifact'))
    CREATE INDEX IX_Artifact_Sha ON dbo.SubmissionArtifact(sha256);
GO

PRINT '>> Migration 005 applied: SubmissionArtifact table + indexes.';
GO
