-- =============================================================
-- Spirit - Demo seed: Submission có file đính kèm + 1 grade mẫu
-- File này INSERT thêm (không reset) DB hiện tại.
-- Mục đích: để test chức năng "Chấm điểm" thấy được file SV upload.
-- =============================================================
USE Spirit_GitAnalytics;
GO

-- -------------------------------------------------------------
-- 0) Đảm bảo đã có ít nhất 1 Assignment + 1 Student.
--    (Nếu DB trống, chạy migrations/003_full_seed.sql trước.)
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Assignment)
BEGIN
    PRINT '!! DB chưa có Assignment. Hãy chạy migrations/003_full_seed.sql trước.';
    RETURN;
END

-- Lấy assignment + student đầu tiên để demo
DECLARE @asmId   INT = (SELECT TOP 1 assignment_id FROM dbo.Assignment ORDER BY assignment_id);
DECLARE @classId INT = (SELECT class_id FROM dbo.Assignment WHERE assignment_id = @asmId);
DECLARE @stuId   INT = (SELECT TOP 1 student_id FROM dbo.Enrollment
                         WHERE class_id = @classId ORDER BY student_id);

PRINT '>> Using assignment_id = ' + CAST(@asmId AS VARCHAR) +
      ', class_id = ' + CAST(@classId AS VARCHAR) +
      ', student_id = ' + CAST(@stuId AS VARCHAR);

-- -------------------------------------------------------------
-- 1) Tạo submission mẫu (nếu chưa có)
-- -------------------------------------------------------------
DECLARE @subId INT;
IF NOT EXISTS (SELECT 1 FROM dbo.Submission WHERE assignment_id = @asmId AND student_id = @stuId)
BEGIN
    INSERT INTO dbo.Submission (assignment_id, student_id, content)
    VALUES (@asmId, @stuId,
            N'Em chào thầy,

Em nộp bài Lab 1 - Servlet Hello World.
Em có đính kèm 2 file:
  - HelloServlet.java (source code)
  - README.md (hướng dẫn chạy)

Em đã test trên Tomcat 9.0.50 và Jetty 9.4, đều chạy OK.
Mong thầy chấm giúp em ạ.

Em cảm ơn!');
    SET @subId = SCOPE_IDENTITY();
    PRINT '>> Created submission_id = ' + CAST(@subId AS VARCHAR);
END
ELSE
BEGIN
    SET @subId = (SELECT submission_id FROM dbo.Submission
                  WHERE assignment_id = @asmId AND student_id = @stuId);
    PRINT '>> Using existing submission_id = ' + CAST(@subId AS VARCHAR);
END

-- -------------------------------------------------------------
-- 2) Tạo 2 file mẫu cho submission (KHÔNG cần file thật trên disk
--    vì ta chỉ demo UI; download sẽ 404 nhưng list vẫn hiển thị).
-- -------------------------------------------------------------
DECLARE @f1 BIGINT = 0, @f2 BIGINT = 0;
DECLARE @p1 NVARCHAR(MAX) = N'submissions/demo_helloservlet.java';
DECLARE @p2 NVARCHAR(MAX) = N'submissions/demo_readme.md';
-- Đo size thật nếu file có trên disk (idempotent nhiều lần chạy)
DECLARE @rootDir NVARCHAR(500) = COALESCE(
    CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(500)),
    N'C:\Users\Acer\Documents\PRJ-Project\Group5_GitAnalytics\uploads\');
-- Không đo bằng xp_cmdshell ở đây; dùng giá trị mặc định đã biết
SET @f1 = 1024; SET @f2 = 512;

IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = @subId AND file_name = 'HelloServlet.java')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type)
VALUES
(@subId, 'HelloServlet.java', 'demo_helloservlet.java', @p1, @f1, 'text/x-java-source'),
(@subId, 'README.md',         'demo_readme.md',         @p2, @f2, 'text/markdown');
-- Đảm bảo path luôn đúng cho cả 2 file (fix nếu đã insert sai trước đó)
UPDATE dbo.SubmissionFile SET file_path = @p1, file_size = @f1, content_type = 'text/x-java-source'
 WHERE file_name = 'HelloServlet.java' AND file_id IN (SELECT file_id FROM dbo.SubmissionFile WHERE file_name = 'HelloServlet.java');
UPDATE dbo.SubmissionFile SET file_path = @p2, file_size = @f2, content_type = 'text/markdown'
 WHERE file_name = 'README.md' AND file_id IN (SELECT file_id FROM dbo.SubmissionFile WHERE file_name = 'README.md');
PRINT '>> Inserted/checked 2 demo submission files';

-- -------------------------------------------------------------
-- 3) Tạo 1 grade mẫu (nếu chưa có) để test hiển thị "đã chấm"
-- -------------------------------------------------------------
DECLARE @teacherId INT = (SELECT TOP 1 teacher_id FROM dbo.ClassRoom WHERE class_id = @classId);
IF @teacherId IS NULL SET @teacherId = 1;

IF NOT EXISTS (SELECT 1 FROM dbo.Grade WHERE submission_id = @subId)
BEGIN
    INSERT INTO dbo.Grade (submission_id, grader_id, score, feedback)
    VALUES (@subId, @teacherId, 9.0,
            N'Bài làm tốt! 
- Cấu trúc code sạch, dễ đọc.
- Có README hướng dẫn chạy.
Gợi ý: thêm comment cho mỗi method để code dễ bảo trì hơn.');
    PRINT '>> Created demo grade';
END
ELSE
    PRINT '>> Demo grade already exists';

-- -------------------------------------------------------------
-- 4) Tạo 1 notification mẫu cho notification test
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Notification WHERE user_id = @stuId AND title LIKE N'%Lab 1%')
INSERT INTO dbo.Notification (user_id, title, body, link)
VALUES (@stuId,
        N'Đã có điểm: Lab 1: Servlet Basics',
        N'Bạn được 9.0/10. Xem chi tiết bài chấm.',
        '/app/assignments/detail?id=' + CAST(@asmId AS VARCHAR));
PRINT '>> Inserted/checked demo notification';

-- -------------------------------------------------------------
-- 5) Báo cáo kết quả
-- -------------------------------------------------------------
SELECT 'Submission'     AS [Table], COUNT(*) AS [Rows] FROM dbo.Submission
UNION ALL SELECT 'SubmissionFile', COUNT(*) FROM dbo.SubmissionFile
UNION ALL SELECT 'Grade',          COUNT(*) FROM dbo.Grade
UNION ALL SELECT 'Notification',   COUNT(*) FROM dbo.Notification;
GO

PRINT '>> Demo seed done. Bây giờ vào /app/teacher/grading?submissionId=N để xem danh sách file.';
GO
