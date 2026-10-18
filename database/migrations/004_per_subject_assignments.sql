-- =============================================================
-- Spirit v2.2 - Per-subject assignments
-- Wipe old assignments (cascade xóa files, submissions, grades)
-- Add CSD201, SWR302 subjects
-- Re-seed 3 classes (1 lớp / môn: PRJ301, CSD201, SWR302)
-- 3 bài / lớp, mỗi bài 3 file đề (multi-file)
-- Run with: sqlcmd -S localhost -E -b -i migrations/004_per_subject_assignments.sql
-- =============================================================
USE Spirit_GitAnalytics;
GO

PRINT '>> Wiping old assignments + dependent rows...';
GO

-- Cascade xóa theo thứ tự
DELETE FROM dbo.SubmissionFile;
DELETE FROM dbo.AssignmentFile;
DELETE FROM dbo.Grade;
DELETE FROM dbo.Submission;

-- Xóa các class không thuộc PRJ301 (giữ class_id=1 PRJ301_G5_S2026)
DELETE FROM dbo.Enrollment WHERE class_id <> 1;
DELETE FROM dbo.Assignment WHERE class_id <> 1;
DELETE FROM dbo.ClassRoom WHERE class_id <> 1;

-- Xóa các lớp test cũ của PRJ301 (id=4 là TEST_G2_F26)
DELETE FROM dbo.Enrollment WHERE class_id = 4;
DELETE FROM dbo.Assignment WHERE class_id = 4;
DELETE FROM dbo.ClassRoom WHERE class_id = 4;

-- Xóa các assignment cũ của class 1
DELETE FROM dbo.SubmissionFile WHERE submission_id IN (SELECT submission_id FROM dbo.Submission WHERE assignment_id IN (SELECT assignment_id FROM dbo.Assignment WHERE class_id = 1));
DELETE FROM dbo.AssignmentFile WHERE assignment_id IN (SELECT assignment_id FROM dbo.Assignment WHERE class_id = 1);
DELETE FROM dbo.Grade WHERE submission_id IN (SELECT submission_id FROM dbo.Submission WHERE assignment_id IN (SELECT assignment_id FROM dbo.Assignment WHERE class_id = 1));
DELETE FROM dbo.Submission WHERE assignment_id IN (SELECT assignment_id FROM dbo.Assignment WHERE class_id = 1);
DELETE FROM dbo.Assignment WHERE class_id = 1;

-- Reset identity của Assignment (để id bắt đầu từ 1 cho sạch)
DBCC CHECKIDENT('dbo.Assignment', RESEED, 0);
DBCC CHECKIDENT('dbo.AssignmentFile', RESEED, 0);
DBCC CHECKIDENT('dbo.Submission', RESEED, 0);
DBCC CHECKIDENT('dbo.SubmissionFile', RESEED, 0);
DBCC CHECKIDENT('dbo.Grade', RESEED, 0);
-- ClassRoom + Enrollment: giữ id tiếp tục (ClassRoom.id=1 vẫn còn dùng)
DBCC CHECKIDENT('dbo.ClassRoom', RESEED, 4);
DBCC CHECKIDENT('dbo.Enrollment', RESEED, 8);
GO

-- =============================================================
-- 1) SUBJECTS - thêm CSD201, SWR302 (PRJ301 đã có sẵn)
-- =============================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Subject WHERE subject_code = 'CSD201')
INSERT INTO dbo.Subject (subject_code, subject_name, semester, description)
VALUES ('CSD201', N'Data Structures and Algorithms', N'Fall2026', N'CSD201 - Cấu trúc dữ liệu & Giải thuật');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Subject WHERE subject_code = 'SWR302')
INSERT INTO dbo.Subject (subject_code, subject_name, semester, description)
VALUES ('SWR302', N'Software Requirements', N'Fall2026', N'SWR302 - Phân tích yêu cầu phần mềm');
GO

PRINT '>> Subjects:';
SELECT subject_id, subject_code, subject_name FROM dbo.Subject WHERE subject_code IN ('PRJ301','CSD201','SWR302') ORDER BY subject_id;
GO

-- =============================================================
-- 2) CLASSES - tạo lại lớp CSD201, SWR302 (PRJ301_G5_S2026 id=1 giữ nguyên)
-- =============================================================
-- Lấy subject_id tương ứng (PRJ301=1, CSD201=?, SWR302=?)
DECLARE @prj301 INT = (SELECT subject_id FROM dbo.Subject WHERE subject_code = 'PRJ301');
DECLARE @csd201 INT = (SELECT subject_id FROM dbo.Subject WHERE subject_code = 'CSD201');
DECLARE @swr302 INT = (SELECT subject_id FROM dbo.Subject WHERE subject_code = 'SWR302');
DECLARE @teacher1 INT = (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1');
DECLARE @teacher2 INT = (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher2');
PRINT 'Subject IDs: PRJ301=' + CAST(@prj301 AS VARCHAR) + ' CSD201=' + CAST(@csd201 AS VARCHAR) + ' SWR302=' + CAST(@swr302 AS VARCHAR);
PRINT 'Teacher IDs: teacher1=' + CAST(@teacher1 AS VARCHAR) + ' teacher2=' + CAST(@teacher2 AS VARCHAR);
GO

-- CSD201 class
IF NOT EXISTS (SELECT 1 FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026')
INSERT INTO dbo.ClassRoom (subject_id, teacher_id, class_code, class_name, semester, description, join_enabled)
VALUES (
    (SELECT subject_id FROM dbo.Subject WHERE subject_code = 'CSD201'),
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher2'),
    'CSD201_G1_S2026', N'CSD201 - Group 1 - Fall2026', N'Fall2026',
    N'Lớp Cấu trúc dữ liệu & Giải thuật', 1);
GO

-- SWR302 class
IF NOT EXISTS (SELECT 1 FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026')
INSERT INTO dbo.ClassRoom (subject_id, teacher_id, class_code, class_name, semester, description, join_enabled)
VALUES (
    (SELECT subject_id FROM dbo.Subject WHERE subject_code = 'SWR302'),
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1'),
    'SWR302_G1_S2026', N'SWR302 - Group 1 - Fall2026', N'Fall2026',
    N'Lớp Phân tích yêu cầu phần mềm', 1);
GO

PRINT '>> Classes:';
SELECT c.class_id, c.class_code, c.class_name, s.subject_code, u.full_name AS teacher_name, c.join_enabled
FROM dbo.ClassRoom c
JOIN dbo.Subject s ON c.subject_id = s.subject_id
JOIN dbo.AppUser u ON c.teacher_id = u.user_id
ORDER BY c.class_id;
GO

-- =============================================================
-- 3) ASSIGNMENTS - 3 bài / lớp, mỗi bài 3 file đề
-- Tổng: 3 lớp × 3 bài = 9 bài tập, 27 file đề
-- (Tên file + nội dung placeholder do Java tạo sau trong bước upload)
-- =============================================================

-- ============= PRJ301 (3 bài) =============
IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026') AND title = N'Lab 1: Servlet Lifecycle')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026'),
    N'Lab 1: Servlet Lifecycle',
    N'Tạo 1 Servlet in ra các sự kiện vòng đời (init, service, destroy) sử dụng log4j. Upload code + screenshot console.',
    DATEADD(day, 7, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1')
);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026') AND title = N'Lab 2: JSP + JSTL')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026'),
    N'Lab 2: JSP + JSTL',
    N'Tạo trang JSP sử dụng JSTL core + fmt để hiển thị danh sách 10 sản phẩm. Phân trang bằng c:foreach + fmt:formatNumber.',
    DATEADD(day, 14, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1')
);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026') AND title = N'Assignment 1: CRUD with JDBC')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026'),
    N'Assignment 1: CRUD with JDBC',
    N'Xây dựng ứng dụng CRUD cho bảng Product (id, name, price, qty) dùng Servlet + JDBC + SQL Server. Validation đầy đủ, có login.',
    DATEADD(day, 21, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1')
);
GO

-- ============= CSD201 (3 bài) =============
IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026') AND title = N'Lab 1: ArrayList vs LinkedList')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026'),
    N'Lab 1: ArrayList vs LinkedList',
    N'Đo thời gian thêm/xoá/tìm kiếm trên ArrayList vs LinkedList với 1 triệu phần tử. Vẽ biểu đồ so sánh. Upload code + báo cáo PDF.',
    DATEADD(day, 7, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher2')
);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026') AND title = N'Lab 2: Stack & Queue')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026'),
    N'Lab 2: Stack & Queue',
    N'Cài đặt Stack và Queue dùng mảng + linked list. Viết chương trình kiểm tra dấu ngoặc cân bằng và mô phỏng hàng đợi in.',
    DATEADD(day, 14, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher2')
);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026') AND title = N'Assignment 1: Binary Search Tree')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026'),
    N'Assignment 1: Binary Search Tree',
    N'Cài đặt BST với insert, delete, inorder/preorder/postorder, tìm max/min. Có ảnh chụp kết quả test với 1000 node ngẫu nhiên.',
    DATEADD(day, 21, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher2')
);
GO

-- ============= SWR302 (3 bài) =============
IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026') AND title = N'Lab 1: Use Case Diagram')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026'),
    N'Lab 1: Use Case Diagram',
    N'Vẽ Use Case Diagram cho hệ thống quản lý thư viện (15 actors + use cases). Upload file .drawio + báo cáo PDF 3 trang.',
    DATEADD(day, 7, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1')
);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026') AND title = N'Lab 2: SRS Document')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026'),
    N'Lab 2: SRS Document',
    N'Viết SRS cho ứng dụng mobile banking (15 chức năng). Bao gồm: giới thiệu, yêu cầu chức năng, phi chức năng, phụ lục.',
    DATEADD(day, 14, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1')
);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026') AND title = N'Assignment 1: Class Diagram + Sequence')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (
    (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026'),
    N'Assignment 1: Class Diagram + Sequence',
    N'Thiết kế Class Diagram (15 classes) + 2 Sequence Diagram cho 2 use case chính. Áp dụng pattern MVC.',
    DATEADD(day, 21, GETDATE()), 10.0,
    (SELECT user_id FROM dbo.AppUser WHERE username = 'teacher1')
);
GO

PRINT '>> Assignments:';
SELECT a.assignment_id, a.class_id, c.class_code, a.title, a.max_score, a.due_date
FROM dbo.Assignment a
JOIN dbo.ClassRoom c ON a.class_id = c.class_id
ORDER BY c.class_id, a.assignment_id;
GO

-- =============================================================
-- 4) ENROLLMENTS - cho sinh viên vào CSD201, SWR302
-- =============================================================
-- CSD201: students 1, 2, 3
IF NOT EXISTS (SELECT 1 FROM dbo.Enrollment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026') AND student_id = (SELECT user_id FROM dbo.AppUser WHERE username = 'student1'))
INSERT INTO dbo.Enrollment (class_id, student_id)
SELECT (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'CSD201_G1_S2026'),
       user_id
FROM dbo.AppUser
WHERE username IN ('student1','student2','student3');
GO

-- SWR302: students 4, 5, 6
IF NOT EXISTS (SELECT 1 FROM dbo.Enrollment WHERE class_id = (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026') AND student_id = (SELECT user_id FROM dbo.AppUser WHERE username = 'student4'))
INSERT INTO dbo.Enrollment (class_id, student_id)
SELECT (SELECT class_id FROM dbo.ClassRoom WHERE class_code = 'SWR302_G1_S2026'),
       user_id
FROM dbo.AppUser
WHERE username IN ('student4','student5','student6');
GO

PRINT '>> Final stats:';
SELECT 'Subject' AS Tbl, COUNT(*) AS N FROM Subject
UNION ALL SELECT 'ClassRoom', COUNT(*) FROM ClassRoom
UNION ALL SELECT 'Enrollment', COUNT(*) FROM Enrollment
UNION ALL SELECT 'Assignment', COUNT(*) FROM Assignment
UNION ALL SELECT 'AssignmentFile', COUNT(*) FROM AssignmentFile
UNION ALL SELECT 'Submission', COUNT(*) FROM Submission
UNION ALL SELECT 'SubmissionFile', COUNT(*) FROM SubmissionFile
UNION ALL SELECT 'Grade', COUNT(*) FROM Grade;
GO

PRINT '>> Migration 004 applied. Next: run Java seeder to attach 3 prompt files per assignment.';
GO
