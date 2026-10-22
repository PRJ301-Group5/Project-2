-- =============================================================
-- Spirit v2.3 - LoginHistory (lịch sử đăng nhập) + AppUser.last_login
-- Ghi lại mỗi lần đăng nhập (thành công / thất bại) kèm IP + user agent.
-- Run: sqlcmd -S localhost -E -b -i migrations/006_login_history.sql
-- =============================================================
USE Spirit_GitAnalytics;
GO

-- 1) Thêm cột last_login vào AppUser (NULL = chưa đăng nhập lần nào)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.AppUser') AND name = 'last_login')
    ALTER TABLE dbo.AppUser ADD last_login DATETIME NULL;
GO

-- 2) Bảng lịch sử đăng nhập
--    Lưu ý: dùng NVARCHAR cho các cột chứa tiếng Việt (username, failure_reason)
--    vì DB collation là Vietnamese_CI_AS (VARCHAR sẽ mất dấu thành ký tự '?').
IF OBJECT_ID('dbo.LoginHistory', 'U') IS NULL
CREATE TABLE dbo.LoginHistory (
    login_id       INT IDENTITY(1,1) PRIMARY KEY,
    user_id        INT NULL,                       -- NULL nếu username không tồn tại
    username      NVARCHAR(50) NOT NULL,           -- luôn lưu username đã nhập
    login_at      DATETIME NOT NULL DEFAULT GETDATE(),
    ip_address    VARCHAR(45) NULL,                -- hỗ trợ cả IPv6
    user_agent    VARCHAR(500) NULL,
    login_status  VARCHAR(10) NOT NULL DEFAULT 'SUCCESS'
                    CHECK (login_status IN ('SUCCESS','FAILED')),
    failure_reason NVARCHAR(200) NULL,
    CONSTRAINT FK_LoginHistory_User FOREIGN KEY (user_id)
        REFERENCES dbo.AppUser(user_id) ON DELETE SET NULL
);
GO

-- 3) Index: tra cứu nhanh theo user + thời gian
CREATE INDEX IX_LoginHistory_User ON dbo.LoginHistory(user_id, login_at DESC);
CREATE INDEX IX_LoginHistory_Time ON dbo.LoginHistory(login_at DESC);
CREATE INDEX IX_LoginHistory_Username ON dbo.LoginHistory(username, login_at DESC);
GO

PRINT '>> Migration 006 applied: LoginHistory table + AppUser.last_login.';
GO
