-- =============================================================
-- Spirit - RESTORE demo data (AssignmentFile / Submission /
--           SubmissionFile / Grade / SubmissionArtifact)
--
-- Sinh lại dữ liệu demo bị mất do chạy lại migration 004.
-- Nguồn: C:\tmp\FileSeeder.java + database/demo_grading_data.sql
--        + uploads/ trên đĩa (file vẫn còn nguyên).
--
-- Run: sqlcmd -S localhost -E -b -d Spirit_GitAnalytics -i 007_restore_demo_data.sql
-- =============================================================
USE Spirit_GitAnalytics;
GO

SET NOCOUNT ON;
GO

-- =============================================================
-- 1) ASSIGNMENT FILE - 27 file đề (3 file / bài x 9 bài)
--    Sinh bởi FileSeeder.java: readme.txt + starter-code.txt + rubric.txt
--    uploaded_by = teacher1 (user_id = 1) cho tất cả.
-- =============================================================

-- ---------- Assignment 1: Lab 1: Servlet Lifecycle (PRJ301) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 1 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (1, N'readme.txt', '487884ae_readme.txt', 'assignments/487884ae_readme.txt', 130, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 1 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (1, N'starter-code.txt', 'b8460fa6_starter-code.txt', 'assignments/b8460fa6_starter-code.txt', 52, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 1 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (1, N'rubric.txt', 'e076c780_rubric.txt', 'assignments/e076c780_rubric.txt', 74, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 2: Lab 2: JSP + JSTL (PRJ301) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 2 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (2, N'readme.txt', '8d4e1fd6_readme.txt', 'assignments/8d4e1fd6_readme.txt', 129, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 2 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (2, N'starter-code.txt', '135e0e28_starter-code.txt', 'assignments/135e0e28_starter-code.txt', 65, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 2 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (2, N'rubric.txt', 'a8f3a33a_rubric.txt', 'assignments/a8f3a33a_rubric.txt', 70, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 3: Assignment 1: CRUD with JDBC (PRJ301) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 3 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (3, N'readme.txt', '117de690_readme.txt', 'assignments/117de690_readme.txt', 128, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 3 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (3, N'starter-code.txt', 'e6a6d678_starter-code.txt', 'assignments/e6a6d678_starter-code.txt', 84, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 3 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (3, N'rubric.txt', 'fd85bdbb_rubric.txt', 'assignments/fd85bdbb_rubric.txt', 61, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 4: Lab 1: ArrayList vs LinkedList (CSD201) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 4 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (4, N'readme.txt', '7f464b49_readme.txt', 'assignments/7f464b49_readme.txt', 151, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 4 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (4, N'starter-code.txt', '64d168b3_starter-code.txt', 'assignments/64d168b3_starter-code.txt', 39, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 4 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (4, N'rubric.txt', '8673b8b3_rubric.txt', 'assignments/8673b8b3_rubric.txt', 65, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 5: Lab 2: Stack & Queue (CSD201) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 5 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (5, N'readme.txt', 'aa8e8936_readme.txt', 'assignments/aa8e8936_readme.txt', 132, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 5 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (5, N'starter-code.txt', '8e601a68_starter-code.txt', 'assignments/8e601a68_starter-code.txt', 40, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 5 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (5, N'rubric.txt', '4030f01a_rubric.txt', 'assignments/4030f01a_rubric.txt', 72, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 6: Assignment 1: Binary Search Tree (CSD201) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 6 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (6, N'readme.txt', '5038cf9f_readme.txt', 'assignments/5038cf9f_readme.txt', 112, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 6 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (6, N'starter-code.txt', '26912cc3_starter-code.txt', 'assignments/26912cc3_starter-code.txt', 75, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 6 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (6, N'rubric.txt', '7f7906d7_rubric.txt', 'assignments/7f7906d7_rubric.txt', 62, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 7: Lab 1: Use Case Diagram (SWR302) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 7 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (7, N'readme.txt', '1facb1ba_readme.txt', 'assignments/1facb1ba_readme.txt', 145, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 7 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (7, N'starter-code.txt', '6ae70480_starter-code.txt', 'assignments/6ae70480_starter-code.txt', 42, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 7 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (7, N'rubric.txt', '7acf404c_rubric.txt', 'assignments/7acf404c_rubric.txt', 76, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 8: Lab 2: SRS Document (SWR302) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 8 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (8, N'readme.txt', '98c96fd5_readme.txt', 'assignments/98c96fd5_readme.txt', 117, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 8 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (8, N'starter-code.txt', '2866ba81_starter-code.txt', 'assignments/2866ba81_starter-code.txt', 76, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 8 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (8, N'rubric.txt', 'e873c38f_rubric.txt', 'assignments/e873c38f_rubric.txt', 60, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- ---------- Assignment 9: Assignment 1: Class + Sequence Diagram (SWR302) ----------
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 9 AND file_name = 'readme.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (9, N'readme.txt', 'aa4714c0_readme.txt', 'assignments/aa4714c0_readme.txt', 142, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 9 AND file_name = 'starter-code.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (9, N'starter-code.txt', '98091df8_starter-code.txt', 'assignments/98091df8_starter-code.txt', 26, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
IF NOT EXISTS (SELECT 1 FROM dbo.AssignmentFile WHERE assignment_id = 9 AND file_name = 'rubric.txt')
INSERT INTO dbo.AssignmentFile (assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by, uploaded_at)
VALUES (9, N'rubric.txt', '78cedaa7_rubric.txt', 'assignments/78cedaa7_rubric.txt', 60, 'text/plain;charset=utf-8', 1, '2026-10-18 22:05:52');
GO

-- =============================================================
-- 2) SUBMISSION - 3 bài nộp của student1 (Trần Văn Nam, user_id = 2)
--    id 1 -> assignment 6 (BST)          lúc 12:48:31
--    id 2 -> assignment 3 (CRUD)         lúc 12:50:22
--    id 3 -> assignment 1 (Servlet Life)  lúc 12:55:07
--    (submission_id là cột IDENTITY -> cần SET IDENTITY_INSERT)
-- =============================================================

SET IDENTITY_INSERT dbo.Submission ON;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Submission WHERE assignment_id = 6 AND student_id = 2)
INSERT INTO dbo.Submission (submission_id, assignment_id, student_id, content, file_path, submitted_at)
VALUES (1, 6, 2, N'Em nộp bài Assignment 1: Binary Search Tree. File đính kèm là ảnh bài làm.', NULL, '2026-10-19 12:48:31');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Submission WHERE assignment_id = 3 AND student_id = 2)
INSERT INTO dbo.Submission (submission_id, assignment_id, student_id, content, file_path, submitted_at)
VALUES (2, 3, 2, N'Em nộp bài Assignment 1: CRUD with JDBC. Kèm starter kit để thầy chạy thử.', NULL, '2026-10-19 12:50:22');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Submission WHERE assignment_id = 1 AND student_id = 2)
INSERT INTO dbo.Submission (submission_id, assignment_id, student_id, content, file_path, submitted_at)
VALUES (3, 1, 2, N'Em chào thầy,

Em nộp bài Lab 1 - Servlet Hello World.
Em có đính kèm 2 file:
  - HelloServlet.java (source code)
  - README.md (hướng dẫn chạy)

Em đã test trên Tomcat 9.0.50 và Jetty 9.4, đều chạy OK.
Mong thầy chấm giúp em ạ.

Em cảm ơn!', NULL, '2026-10-19 12:55:07');
GO

SET IDENTITY_INSERT dbo.Submission OFF;
GO

-- =============================================================
-- 3) SUBMISSION FILE - 7 file nộp
-- =============================================================

-- submission 1: ảnh bài làm BST
IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = 1 AND file_name = N'1792139099070_4041369225795814003_g8573792567738131866_05813e7c346888a65f35fb46f1a3c766.jpg')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at)
VALUES (1, N'1792139099070_4041369225795814003_g8573792567738131866_05813e7c346888a65f35fb46f1a3c766.jpg',
        '222f960c_1792139099070_4041369225795814003_g8573792567738131866_05813e7c346888a65f35fb46f1a3c766.jpg',
        'submissions/222f960c_1792139099070_4041369225795814003_g8573792567738131866_05813e7c346888a65f35fb46f1a3c766.jpg',
        58170, 'image/jpeg', '2026-10-19 12:48:31');
GO

-- submission 2: starter kit
IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = 2 AND file_name = N'student-starter-kit-v1.1.zip')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at)
VALUES (2, N'student-starter-kit-v1.1.zip', 'e035db97_student-starter-kit-v1.1.zip',
        'submissions/e035db97_student-starter-kit-v1.1.zip', 22011, 'application/zip', '2026-10-19 12:50:22');
GO

-- submission 3: 5 file (2 file demo + 3 file upload qua web)
IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = 3 AND file_name = 'HelloServlet.java')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at)
VALUES (3, N'HelloServlet.java', 'demo_helloservlet.java', 'submissions/demo_helloservlet.java',
        1091, 'text/x-java-source', '2026-10-19 12:55:07');
IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = 3 AND file_name = 'README.md')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at)
VALUES (3, N'README.md', 'demo_readme.md', 'submissions/demo_readme.md',
        380, 'text/markdown', '2026-10-19 12:55:08');
IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = 3 AND file_name = 'test1.txt')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at)
VALUES (3, N'test1.txt', 'b9655d51_test1.txt', 'submissions/b9655d51_test1.txt',
        21, 'text/plain', '2026-10-19 13:15:01');
IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = 3 AND file_name = 'test2.md')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at)
VALUES (3, N'test2.md', '1410f7ca_test2.md', 'submissions/1410f7ca_test2.md',
        23, 'text/markdown', '2026-10-19 13:15:01');
IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionFile WHERE submission_id = 3 AND file_name = 'restore.txt')
INSERT INTO dbo.SubmissionFile (submission_id, file_name, stored_name, file_path, file_size, content_type, uploaded_at)
VALUES (3, N'restore.txt', '01a9f3e8_restore.txt', 'submissions/01a9f3e8_restore.txt',
        15, 'text/plain', '2026-10-19 13:15:50');
GO

-- =============================================================
-- 4) GRADE - 2 điểm
--    id 1: submission 3 (assignment 1) - 9.0/10.0  (demo_grading_data.sql)
--    id 2: submission 2 (assignment 3) - 5.0/10.0  (GradingServlet)
-- =============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Grade WHERE submission_id = 3)
INSERT INTO dbo.Grade (submission_id, grader_id, score, feedback, graded_at)
VALUES (3, 1, 9.0, N'Bài làm tốt!
- Cấu trúc code sạch, dễ đọc.
- Có README hướng dẫn chạy.
Gợi ý: thêm comment cho mỗi method để code dễ bảo trì hơn.', '2026-10-19 12:55:08');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Grade WHERE submission_id = 2)
INSERT INTO dbo.Grade (submission_id, grader_id, score, feedback, graded_at)
VALUES (2, 1, 5.0, N'Bài làm đạt yêu cầu cơ bản.
- CRUD hoạt động với đủ 4 thao tác.
- Có validate input cơ bản.
Gợi ý: bổ sung phân trang danh sách và xử lý transaction khi thêm/sửa.', '2026-10-19 13:16:45');
GO

-- =============================================================
-- 5) SUBMISSION ARTIFACT - ZIP + SHA-256 cho submission 3
--    File ZIP vẫn còn trên đĩa: uploads/artifacts/sub_3_76ce3b66.zip
--    SHA-256 tính lại từ file trên đĩa (khớp giá trị đã lưu).
-- =============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.SubmissionArtifact WHERE submission_id = 3)
INSERT INTO dbo.SubmissionArtifact (submission_id, zip_stored_name, zip_path, zip_size, sha256, file_count, verification_status, created_at, verified_at)
VALUES (3, 'sub_3_76ce3b66.zip', 'artifacts/sub_3_76ce3b66.zip', 1488,
        'b74004abf04679697ac86028b3617370bd150b27b24fc79a14fcba82ff5cb0f7',
        5, 'PENDING', '2026-10-19 13:15:50', NULL);
GO

-- =============================================================
-- 6) VERIFY
-- =============================================================
PRINT '>> Demo data restored.';
GO

SELECT 'AssignmentFile' AS [Table], COUNT(*) AS [Rows] FROM dbo.AssignmentFile
UNION ALL SELECT 'Submission', COUNT(*) FROM dbo.Submission
UNION ALL SELECT 'SubmissionFile', COUNT(*) FROM dbo.SubmissionFile
UNION ALL SELECT 'Grade', COUNT(*) FROM dbo.Grade
UNION ALL SELECT 'SubmissionArtifact', COUNT(*) FROM dbo.SubmissionArtifact
UNION ALL SELECT 'LoginHistory', COUNT(*) FROM dbo.LoginHistory;
GO
