-- =============================================================
-- Spirit v2.1 - Full demo seed
-- Run after bootstrap.sql + grading_schema.sql + 002_file_upload_and_classes.sql
-- =============================================================
USE Spirit_GitAnalytics;
GO

PRINT '>> Refreshing demo seed...';
GO

-- =============================================================
-- 1) USERS - 1 admin, 2 teachers, 6 students
-- Password: Password@123  (BCrypt hashed)
-- =============================================================
DECLARE @pwd VARCHAR(255) = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

-- Admin
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE username = 'admin')
INSERT INTO dbo.AppUser (username, password_hash, full_name, email, phone, role)
VALUES ('admin', @pwd, N'Quản trị viên', 'admin@fpt.edu.vn', '0900000000', 'ADMIN');
GO

-- Teacher 2
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE username = 'teacher2')
INSERT INTO dbo.AppUser (username, password_hash, full_name, email, role)
VALUES ('teacher2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
        N'Trần Văn Hùng', 'teacher2@fpt.edu.vn', 'TEACHER');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE username = 'teacher1')
INSERT INTO dbo.AppUser (username, password_hash, full_name, email, role)
VALUES ('teacher1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
        N'Nguyễn Thị Lan', 'teacher1@fpt.edu.vn', 'TEACHER');
GO

-- Students (4..9, students 1..3 đã có sẵn)
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE username = 'student4')
INSERT INTO dbo.AppUser (username, password_hash, full_name, email, role) VALUES
('student4', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', N'Đỗ Văn Khang', 'student4@fpt.edu.vn', 'STUDENT'),
('student5', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', N'Vũ Thị Lan',  'student5@fpt.edu.vn', 'STUDENT'),
('student6', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', N'Phan Minh Quân','student6@fpt.edu.vn', 'STUDENT');
GO

-- =============================================================
-- 2) SUBJECTS - thêm 1 môn nữa
-- =============================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Subject WHERE subject_code = 'LAB211')
INSERT INTO dbo.Subject (subject_code, subject_name, semester, description)
VALUES ('LAB211', N'Lab OOP with Java', N'Fall2026', N'LAB211 - Lập trình OOP');
GO

-- =============================================================
-- 3) CLASSES - 3 lớp (1 đã có sẵn, tạo thêm 2)
-- =============================================================
IF NOT EXISTS (SELECT 1 FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026')
INSERT INTO dbo.ClassRoom (subject_id, teacher_id, class_code, class_name, semester, description, join_enabled)
VALUES (1, 1, 'PRJ301_G5_S2026', N'PRJ301 - Group 5 - Fall2026', N'Fall2026',
        N'Lớp Java Web Application cho nhóm 5', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ClassRoom WHERE class_code = 'ANC111_G2_S2026')
INSERT INTO dbo.ClassRoom (subject_id, teacher_id, class_code, class_name, semester, description, join_enabled)
VALUES (2, 1, 'ANC111_G2_S2026', N'ANC111 - Group 2 - Fall2026', N'Fall2026',
        N'Lớp Academic English 1 - nhóm 2', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ClassRoom WHERE class_code = 'LAB211_FA_S2026')
INSERT INTO dbo.ClassRoom (subject_id, teacher_id, class_code, class_name, semester, description, join_enabled)
VALUES (4, 2, 'LAB211_FA_S2026', N'LAB211 - Fall2026 - teacher2', N'Fall2026',
        N'Lớp OOP do thầy Hùng phụ trách', 1);
GO

-- =============================================================
-- 4) ENROLLMENTS - 1 lớp đã có, thêm cho 2 lớp mới
-- =============================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Enrollment WHERE class_id = 2 AND student_id = 2)
INSERT INTO dbo.Enrollment (class_id, student_id) VALUES
(2, 2),
(2, 3),
(3, 5),
(3, 6),
(3, 7);
GO

-- =============================================================
-- 5) ASSIGNMENTS - mỗi lớp 2 bài
-- =============================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE title = N'Lab 1: Servlet Basics')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (1, N'Lab 1: Servlet Basics',
        N'Tạo một Servlet đơn giản hiển thị "Hello World" từ doGet().',
        DATEADD(day, 7, GETDATE()), 10.0, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE title = N'Lab 2: JSP Form Handling')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (1, N'Lab 2: JSP Form Handling',
        N'Tạo form JSP nhận họ tên + email, xử lý bằng Servlet và hiển thị kết quả.',
        DATEADD(day, 14, GETDATE()), 10.0, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE title = N'Lab 1: OOP Design')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (3, N'Lab 1: OOP Design',
        N'Thiết kế 1 lớp Student với 4 thuộc tính + 2 phương thức. Minh hoạ kế thừa với lớp GraduateStudent.',
        DATEADD(day, 10, GETDATE()), 10.0, 2);
GO

PRINT '>> Demo seed refreshed.';
GO

-- =============================================================
-- Verify
-- =============================================================
SELECT 'AppUser' AS TableName, COUNT(*) AS Rows FROM dbo.AppUser
UNION ALL SELECT 'Subject', COUNT(*) FROM dbo.Subject
UNION ALL SELECT 'ClassRoom', COUNT(*) FROM dbo.ClassRoom
UNION ALL SELECT 'Enrollment', COUNT(*) FROM dbo.Enrollment
UNION ALL SELECT 'Assignment', COUNT(*) FROM dbo.Assignment
UNION ALL SELECT 'Submission', COUNT(*) FROM dbo.Submission
UNION ALL SELECT 'Grade', COUNT(*) FROM dbo.Grade
UNION ALL SELECT 'Project', COUNT(*) FROM dbo.Project
UNION ALL SELECT 'Student', COUNT(*) FROM dbo.Student
UNION ALL SELECT 'TeamMember', COUNT(*) FROM dbo.TeamMember
UNION ALL SELECT 'CommitRecord', COUNT(*) FROM dbo.CommitRecord
UNION ALL SELECT 'ContributionScore', COUNT(*) FROM dbo.ContributionScore
UNION ALL SELECT 'ExportHistory', COUNT(*) FROM dbo.ExportHistory;
GO
