-- =============================================================
-- Spirit v2.1 - File upload + Class management migration
-- Apply to existing Spirit_GitAnalytics database.
-- Run with: sqlcmd -S localhost -E -b -i migrations/002_file_upload_and_classes.sql
-- =============================================================
USE Spirit_GitAnalytics;
GO

-- -------------------------------------------------------------
-- 1. AssignmentFile - file đề bài do teacher đính kèm (nhiều file)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.AssignmentFile', 'U') IS NULL
CREATE TABLE dbo.AssignmentFile (
    file_id         INT IDENTITY(1,1) PRIMARY KEY,
    assignment_id   INT NOT NULL,
    file_name       NVARCHAR(255) NOT NULL,        -- tên file gốc user upload
    stored_name     VARCHAR(255) NOT NULL,         -- tên file trên disk (UUID-prefixed)
    file_path       VARCHAR(500) NOT NULL,         -- đường dẫn tương đối trong /uploads
    file_size       BIGINT DEFAULT 0,
    content_type    VARCHAR(100),
    uploaded_by     INT NOT NULL,
    uploaded_at     DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AF_Asm FOREIGN KEY (assignment_id) REFERENCES dbo.Assignment(assignment_id) ON DELETE CASCADE,
    CONSTRAINT FK_AF_Uploader FOREIGN KEY (uploaded_by) REFERENCES dbo.AppUser(user_id)
);
GO

-- -------------------------------------------------------------
-- 2. SubmissionFile - file sinh viên nộp (nhiều file mỗi submission)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.SubmissionFile', 'U') IS NULL
CREATE TABLE dbo.SubmissionFile (
    file_id         INT IDENTITY(1,1) PRIMARY KEY,
    submission_id   INT NOT NULL,
    file_name       NVARCHAR(255) NOT NULL,
    stored_name     VARCHAR(255) NOT NULL,
    file_path       VARCHAR(500) NOT NULL,
    file_size       BIGINT DEFAULT 0,
    content_type    VARCHAR(100),
    uploaded_at     DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_SF_Sub FOREIGN KEY (submission_id) REFERENCES dbo.Submission(submission_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 3. Class invite code - mã code dễ nhớ (unique friendly)
--     ClassRoom.class_code hiện tại đã UNIQUE, dùng làm invite code luôn.
--     Thêm 2 cột tiện ích:
--       - description   : mô tả ngắn cho lớp
--       - join_enabled  : cho phép student tự join bằng class_code hay không
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ClassRoom') AND name = 'description')
ALTER TABLE dbo.ClassRoom ADD description NVARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ClassRoom') AND name = 'join_enabled')
ALTER TABLE dbo.ClassRoom ADD join_enabled BIT DEFAULT 1;
GO

-- -------------------------------------------------------------
-- 4. Index để tăng tốc các truy vấn thường gặp
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AF_Asm')
CREATE INDEX IX_AF_Asm ON dbo.AssignmentFile(assignment_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SF_Sub')
CREATE INDEX IX_SF_Sub ON dbo.SubmissionFile(submission_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ClassCode_Join')
CREATE INDEX IX_ClassCode_Join ON dbo.ClassRoom(class_code) WHERE join_enabled = 1;
GO

PRINT '>> Migration 002 applied: AssignmentFile, SubmissionFile, ClassRoom extensions.';
GO
