-- =============================================================
-- Spirit v2.4 - AppUser.user_code (MSSV cho sinh viên / Mã thẻ cho GV)
-- Yêu cầu: mỗi tài khoản phải có mã định danh riêng theo vai trò.
--   - STUDENT : MSSV            (VD: SE123456)
--   - TEACHER : Mã thẻ GV      (VD: GV0001)
--   - ADMIN   : Mã quản trị    (VD: AD0001)
--
-- Run: sqlcmd -S localhost -E -b -i migrations/008_user_code.sql
-- =============================================================
USE Spirit_GitAnalytics;
GO

-- -------------------------------------------------------------
-- 1) Thêm cột user_code
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.AppUser') AND name = 'user_code')
    ALTER TABLE dbo.AppUser ADD user_code VARCHAR(20) NULL;
GO

-- -------------------------------------------------------------
-- 2) Unique index (chỉ áp dụng cho giá trị khác NULL)
--    -> hai tài khoản khác role không được dùng chung 1 mã.
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_AppUser_UserCode' AND object_id = OBJECT_ID('dbo.AppUser'))
    CREATE UNIQUE INDEX UX_AppUser_UserCode
        ON dbo.AppUser(user_code)
        WHERE user_code IS NOT NULL;
GO

-- -------------------------------------------------------------
-- 3) Gán mã cho các tài khoản demo đã tồn tại
--    Quy tắc: TEACHER -> GV000n, STUDENT -> SEnnnnnn, ADMIN -> AD000n
--    (chạy lại nhiều lần vẫn an toàn: chỉ gán cho row chưa có mã)
-- -------------------------------------------------------------
DECLARE @i INT = 0;
DECLARE @uid INT, @role VARCHAR(20);

DECLARE c CURSOR FOR
    SELECT user_id, role FROM dbo.AppUser
    WHERE user_code IS NULL AND role IN ('TEACHER','STUDENT','ADMIN')
    ORDER BY user_id;

OPEN c;
FETCH NEXT FROM c INTO @uid, @role;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @i = @i + 1;
    DECLARE @code VARCHAR(20);

    IF @role = 'TEACHER'
        SET @code = 'GV' + RIGHT('0000' + CAST(@i AS VARCHAR(10)), 4);
    ELSE IF @role = 'ADMIN'
        SET @code = 'AD' + RIGHT('0000' + CAST(@i AS VARCHAR(10)), 4);
    ELSE
        -- Sinh viên: MSSV dạng SEnnnnnn, tránh trùng với user_id hiện có
        SET @code = 'SE' + RIGHT('000000' + CAST((@uid * 1000 + @i) AS VARCHAR(10)), 6);

    -- Chỉ gán nếu mã này chưa tồn tại
    IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE user_code = @code)
        UPDATE dbo.AppUser SET user_code = @code WHERE user_id = @uid;

    FETCH NEXT FROM c INTO @uid, @role;
END
CLOSE c;
DEALLOCATE c;
GO

PRINT '>> Migration 008 applied: AppUser.user_code + du lieu demo.';
GO

SELECT user_id, username, full_name, role, user_code
FROM dbo.AppUser
ORDER BY user_id;
GO
