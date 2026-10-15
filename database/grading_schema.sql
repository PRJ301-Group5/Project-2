-- =============================================================
-- Spirit - Grading Module schema additions
-- Add to existing Spirit_GitAnalytics database.
-- Run after schema.sql / bootstrap.sql.
-- =============================================================
USE Spirit_GitAnalytics;
GO

-- -------------------------------------------------------------
-- 7. AppUser (Teacher + Student account)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.AppUser', 'U') IS NULL
CREATE TABLE dbo.AppUser (
    user_id           INT IDENTITY(1,1) PRIMARY KEY,
    username          VARCHAR(50)  UNIQUE NOT NULL,
    password_hash     VARCHAR(255) NOT NULL,
    full_name         NVARCHAR(100) NOT NULL,
    email             VARCHAR(150) UNIQUE NOT NULL,
    phone             VARCHAR(20),
    role              VARCHAR(20)  NOT NULL CHECK (role IN ('TEACHER','STUDENT','ADMIN')),
    is_active         BIT DEFAULT 1,
    created_at        DATETIME DEFAULT GETDATE()
);
GO

-- -------------------------------------------------------------
-- 8. Subject (e.g. ANC111, ABC222)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Subject', 'U') IS NULL
CREATE TABLE dbo.Subject (
    subject_id        INT IDENTITY(1,1) PRIMARY KEY,
    subject_code      VARCHAR(20)  UNIQUE NOT NULL,
    subject_name      NVARCHAR(200) NOT NULL,
    semester          VARCHAR(20),
    description       NVARCHAR(500),
    created_at        DATETIME DEFAULT GETDATE()
);
GO

-- -------------------------------------------------------------
-- 9. Class (1 teacher teaches 1 subject in 1 semester)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.ClassRoom', 'U') IS NULL
CREATE TABLE dbo.ClassRoom (
    class_id          INT IDENTITY(1,1) PRIMARY KEY,
    subject_id        INT NOT NULL,
    teacher_id        INT NOT NULL,
    class_code        VARCHAR(20)  UNIQUE NOT NULL,
    class_name        NVARCHAR(100),
    semester          VARCHAR(20),
    created_at        DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Class_Subject FOREIGN KEY (subject_id) REFERENCES dbo.Subject(subject_id),
    CONSTRAINT FK_Class_Teacher FOREIGN KEY (teacher_id) REFERENCES dbo.AppUser(user_id)
);
GO

-- -------------------------------------------------------------
-- 10. Enrollment (Student in Class)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Enrollment', 'U') IS NULL
CREATE TABLE dbo.Enrollment (
    enrollment_id     INT IDENTITY(1,1) PRIMARY KEY,
    class_id          INT NOT NULL,
    student_id        INT NOT NULL,
    enrolled_at       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Enr_Class FOREIGN KEY (class_id) REFERENCES dbo.ClassRoom(class_id),
    CONSTRAINT FK_Enr_Student FOREIGN KEY (student_id) REFERENCES dbo.AppUser(user_id),
    CONSTRAINT UQ_Enr UNIQUE (class_id, student_id)
);
GO

-- -------------------------------------------------------------
-- 11. Assignment (Bài tập)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Assignment', 'U') IS NULL
CREATE TABLE dbo.Assignment (
    assignment_id     INT IDENTITY(1,1) PRIMARY KEY,
    class_id          INT NOT NULL,
    title             NVARCHAR(200) NOT NULL,
    description       NVARCHAR(MAX),
    prompt_file       VARCHAR(500),
    due_date          DATETIME NOT NULL,
    max_score         DECIMAL(5,2) DEFAULT 10.0,
    created_by        INT NOT NULL,
    created_at        DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Asm_Class FOREIGN KEY (class_id) REFERENCES dbo.ClassRoom(class_id),
    CONSTRAINT FK_Asm_Creator FOREIGN KEY (created_by) REFERENCES dbo.AppUser(user_id)
);
GO

-- -------------------------------------------------------------
-- 12. Submission (Bài nộp của sinh viên)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Submission', 'U') IS NULL
CREATE TABLE dbo.Submission (
    submission_id     INT IDENTITY(1,1) PRIMARY KEY,
    assignment_id     INT NOT NULL,
    student_id        INT NOT NULL,
    content           NVARCHAR(MAX),
    file_path         VARCHAR(500),
    submitted_at      DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Sub_Asm FOREIGN KEY (assignment_id) REFERENCES dbo.Assignment(assignment_id),
    CONSTRAINT FK_Sub_Student FOREIGN KEY (student_id) REFERENCES dbo.AppUser(user_id),
    CONSTRAINT UQ_Sub UNIQUE (assignment_id, student_id)
);
GO

-- -------------------------------------------------------------
-- 13. Grade (Điểm + feedback)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Grade', 'U') IS NULL
CREATE TABLE dbo.Grade (
    grade_id          INT IDENTITY(1,1) PRIMARY KEY,
    submission_id     INT NOT NULL UNIQUE,
    grader_id         INT NOT NULL,
    score             DECIMAL(5,2) NOT NULL,
    feedback          NVARCHAR(MAX),
    graded_at         DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Gr_Sub FOREIGN KEY (submission_id) REFERENCES dbo.Submission(submission_id),
    CONSTRAINT FK_Gr_Grader FOREIGN KEY (grader_id) REFERENCES dbo.AppUser(user_id)
);
GO

-- -------------------------------------------------------------
-- 14. Notification
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Notification', 'U') IS NULL
CREATE TABLE dbo.Notification (
    notification_id   INT IDENTITY(1,1) PRIMARY KEY,
    user_id           INT NOT NULL,
    title             NVARCHAR(200) NOT NULL,
    body              NVARCHAR(MAX),
    link              VARCHAR(500),
    is_read           BIT DEFAULT 0,
    created_at        DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Noti_User FOREIGN KEY (user_id) REFERENCES dbo.AppUser(user_id)
);
GO

-- -------------------------------------------------------------
-- 15. OtpCode (OTP for register/forgot password)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.OtpCode', 'U') IS NULL
CREATE TABLE dbo.OtpCode (
    otp_id            INT IDENTITY(1,1) PRIMARY KEY,
    target            VARCHAR(150) NOT NULL,  -- email or phone
    purpose           VARCHAR(20)  NOT NULL,  -- REGISTER / FORGOT
    code              VARCHAR(10)  NOT NULL,
    expires_at        DATETIME     NOT NULL,
    is_used           BIT DEFAULT 0,
    created_at        DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX IX_Noti_User ON dbo.Notification(user_id, is_read);
CREATE INDEX IX_Sub_Student ON dbo.Submission(student_id);
CREATE INDEX IX_Asm_Class ON dbo.Assignment(class_id, due_date);
CREATE INDEX IX_Otp_Target ON dbo.OtpCode(target, code, is_used);
GO

-- =============================================================
-- SAMPLE DATA for grading module
-- Password for all demo accounts: "Password@123"
-- bcrypt hash of "Password@123" with cost 10
-- =============================================================

-- Teacher account
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE username = 'teacher1')
INSERT INTO dbo.AppUser (username, password_hash, full_name, email, role)
VALUES ('teacher1',
        '$2a$10$DowJonesIndustrialAverageHashForDemo.Password123xxxxxxxxxxxxxx',
        N'Nguyễn Thị Lan', 'teacher1@fpt.edu.vn', 'TEACHER');
GO

-- Student accounts
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE username = 'student1')
INSERT INTO dbo.AppUser (username, password_hash, full_name, email, role)
VALUES
('student1', '$2a$10$DowJonesIndustrialAverageHashForDemo.Password123xxxxxxxxxxxxxx',
   N'Trần Văn Nam', 'student1@fpt.edu.vn', 'STUDENT'),
('student2', '$2a$10$DowJonesIndustrialAverageHashForDemo.Password123xxxxxxxxxxxxxx',
   N'Lê Thị Hoa',  'student2@fpt.edu.vn', 'STUDENT'),
('student3', '$2a$10$DowJonesIndustrialAverageHashForDemo.Password123xxxxxxxxxxxxxx',
   N'Phạm Văn Bình','student3@fpt.edu.vn', 'STUDENT');
GO

-- Subjects
IF NOT EXISTS (SELECT 1 FROM dbo.Subject WHERE subject_code = 'PRJ301')
INSERT INTO dbo.Subject (subject_code, subject_name, semester, description)
VALUES
('PRJ301', N'Java Web Application Development', N'Fall2026', N'PRJ301 - Java Web'),
('ANC111', N'Academic English 1',                N'Fall2026', N'ANC111 - English 1'),
('ABC222', N'Business Communication',            N'Fall2026', N'ABC222 - BizCom');
GO

-- Class
IF NOT EXISTS (SELECT 1 FROM dbo.ClassRoom WHERE class_code = 'PRJ301_G5_S2026')
INSERT INTO dbo.ClassRoom (subject_id, teacher_id, class_code, class_name, semester)
VALUES (1, 1, 'PRJ301_G5_S2026', N'PRJ301 - Group 5 - Fall2026', N'Fall2026');
GO

-- Enrollments
IF NOT EXISTS (SELECT 1 FROM dbo.Enrollment WHERE class_id = 1 AND student_id = 2)
INSERT INTO dbo.Enrollment (class_id, student_id)
VALUES
(1, 2),
(1, 3),
(1, 4);
GO

-- Sample assignment
IF NOT EXISTS (SELECT 1 FROM dbo.Assignment WHERE title = N'Lab 1: Servlet Basics')
INSERT INTO dbo.Assignment (class_id, title, description, due_date, max_score, created_by)
VALUES (1, N'Lab 1: Servlet Basics',
        N'Tạo một Servlet đơn giản hiển thị "Hello World".',
        DATEADD(day, 7, GETDATE()), 10.0, 1);
GO

PRINT '>> Grading module schema + sample data installed.';
GO
