-- =============================================================
-- Spirit - Rename AITA database to Spirit (live rename)
-- =============================================================
-- CHẠY CẨN THẬN: Script này sẽ đổi tên database đang chạy trên SQL Server.
-- Đảm bảo:
--   1. Không có app nào đang kết nối tới AITA_GitAnalytics
--   2. Đã backup database trước khi chạy
--   3. Có quyền sysadmin hoặc db_owner
--
-- Cách chạy (PowerShell):
--   sqlcmd -S localhost -E -b -i database\rename_aita_to_spirit.sql
-- =============================================================

USE [master];
GO

-- 1. Đóng tất cả kết nối hiện tại tới AITA_GitAnalytics
IF DB_ID('AITA_GitAnalytics') IS NOT NULL
BEGIN
    DECLARE @kill varchar(8000) = '';
    SELECT @kill = @kill + 'KILL ' + CONVERT(varchar(5), session_id) + ';'
    FROM sys.dm_exec_sessions
    WHERE database_id = DB_ID('AITA_GitAnalytics');
    EXEC(@kill);
END
GO

-- 2. Đổi tên database AITA_GitAnalytics -> Spirit_GitAnalytics
IF DB_ID('AITA_GitAnalytics') IS NOT NULL
BEGIN
    ALTER DATABASE [AITA_GitAnalytics] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    ALTER DATABASE [AITA_GitAnalytics] MODIFY NAME = [Spirit_GitAnalytics];
    ALTER DATABASE [Spirit_GitAnalytics] SET MULTI_USER;
    PRINT '>> Database renamed: AITA_GitAnalytics -> Spirit_GitAnalytics';
END
ELSE IF DB_ID('Spirit_GitAnalytics') IS NOT NULL
BEGIN
    PRINT '>> Spirit_GitAnalytics already exists - skip rename.';
END
ELSE
BEGIN
    PRINT '>> Neither AITA_GitAnalytics nor Spirit_GitAnalytics exists.';
END
GO

-- 3. Đổi tên SQL login aita_user -> spirit_user (nếu tồn tại)
IF SUSER_ID('aita_user') IS NOT NULL
BEGIN
    ALTER LOGIN [aita_user] WITH NAME = [spirit_user];
    PRINT '>> Login renamed: aita_user -> spirit_user';
END
ELSE IF SUSER_ID('spirit_user') IS NOT NULL
BEGIN
    PRINT '>> spirit_user already exists - skip rename.';
END
GO

-- 4. Verify
SELECT name FROM sys.databases WHERE name IN ('AITA_GitAnalytics', 'Spirit_GitAnalytics');
SELECT name FROM sys.server_principals WHERE name IN ('aita_user', 'spirit_user');
GO

PRINT '>> Done. Update connection.properties to use Spirit_GitAnalytics + spirit_user.';
GO