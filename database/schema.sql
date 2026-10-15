-- =============================================================
-- Spirit - Database schema (for IDE live editing / SSMS)
-- =============================================================
-- Cập nhật: dùng cho IDE / SSMS để xem/sửa trực tiếp
-- Connection: localhost,1433 / spirit_user / Spirit@2024!
-- =============================================================

USE Spirit_GitAnalytics;
GO

-- -------------------------------------------------------------
-- 1. Project
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Project', 'U') IS NULL
CREATE TABLE dbo.Project (
    project_id        INT IDENTITY(1,1) PRIMARY KEY,
    project_code      VARCHAR(20)  UNIQUE NOT NULL,
    project_name      NVARCHAR(200) NOT NULL,
    repo_url          VARCHAR(500)  NOT NULL,
    local_path        VARCHAR(500),
    start_date        DATE,
    end_date          DATE,
    created_at        DATETIME DEFAULT GETDATE()
);
GO

-- -------------------------------------------------------------
-- 2. Student
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.Student', 'U') IS NULL
CREATE TABLE dbo.Student (
    student_id        INT IDENTITY(1,1) PRIMARY KEY,
    student_code      VARCHAR(20)  UNIQUE NOT NULL,
    full_name         NVARCHAR(100) NOT NULL,
    email             VARCHAR(100),
    created_at        DATETIME DEFAULT GETDATE()
);
GO

-- -------------------------------------------------------------
-- 3. TeamMember (project x student)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.TeamMember', 'U') IS NULL
CREATE TABLE dbo.TeamMember (
    team_member_id    INT IDENTITY(1,1) PRIMARY KEY,
    project_id        INT NOT NULL,
    student_id        INT NOT NULL,
    git_email         VARCHAR(150),
    role              NVARCHAR(50) DEFAULT N'Member',
    CONSTRAINT FK_TM_Project FOREIGN KEY (project_id) REFERENCES dbo.Project(project_id),
    CONSTRAINT FK_TM_Student FOREIGN KEY (student_id) REFERENCES dbo.Student(student_id),
    CONSTRAINT UQ_TM UNIQUE (project_id, student_id)
);
GO

-- -------------------------------------------------------------
-- 4. CommitRecord (raw commits from JGit)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.CommitRecord', 'U') IS NULL
CREATE TABLE dbo.CommitRecord (
    commit_id         INT IDENTITY(1,1) PRIMARY KEY,
    project_id        INT NOT NULL,
    team_member_id    INT,
    commit_hash       VARCHAR(64) NOT NULL,
    author_name       NVARCHAR(100),
    author_email      VARCHAR(150),
    commit_date       DATETIME NOT NULL,
    message           NVARCHAR(1000),
    files_changed     INT DEFAULT 0,
    lines_added       INT DEFAULT 0,
    lines_deleted     INT DEFAULT 0,
    CONSTRAINT FK_CR_Project FOREIGN KEY (project_id) REFERENCES dbo.Project(project_id),
    CONSTRAINT FK_CR_TeamMember FOREIGN KEY (team_member_id) REFERENCES dbo.TeamMember(team_member_id),
    CONSTRAINT UQ_CR UNIQUE (project_id, commit_hash)
);
GO

-- -------------------------------------------------------------
-- 5. ContributionScore (computed scores)
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.ContributionScore', 'U') IS NULL
CREATE TABLE dbo.ContributionScore (
    score_id          INT IDENTITY(1,1) PRIMARY KEY,
    project_id        INT NOT NULL,
    team_member_id    INT NOT NULL,
    total_commits     INT DEFAULT 0,
    total_lines_added INT DEFAULT 0,
    total_lines_deleted INT DEFAULT 0,
    active_days       INT DEFAULT 0,
    contribution_pct  DECIMAL(5,2),
    fairness_score    DECIMAL(5,2),
    status            NVARCHAR(20) DEFAULT N'NORMAL',
    last_analyzed     DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_CS_Project FOREIGN KEY (project_id) REFERENCES dbo.Project(project_id),
    CONSTRAINT FK_CS_TeamMember FOREIGN KEY (team_member_id) REFERENCES dbo.TeamMember(team_member_id),
    CONSTRAINT UQ_CS UNIQUE (project_id, team_member_id)
);
GO

-- -------------------------------------------------------------
-- 6. AnalysisHistory
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.AnalysisHistory', 'U') IS NULL
CREATE TABLE dbo.AnalysisHistory (
    history_id        INT IDENTITY(1,1) PRIMARY KEY,
    project_id        INT NOT NULL,
    analyzed_by       NVARCHAR(100),
    commit_count      INT,
    duration_ms       INT,
    status            NVARCHAR(20),
    note              NVARCHAR(500),
    analyzed_at       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AH_Project FOREIGN KEY (project_id) REFERENCES dbo.Project(project_id)
);
GO

-- Sample data (idempotent)
IF NOT EXISTS (SELECT 1 FROM dbo.Project WHERE project_code = 'PRJ301_G5')
INSERT INTO dbo.Project (project_code, project_name, repo_url, local_path, start_date, end_date)
VALUES ('PRJ301_G5', N'Spirit - Git Analytics Module',
        'https://github.com/Spirit-team/Spirit-backend',
        'C:/repos/Spirit-demo', '2026-09-01', '2026-11-15');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE student_code = 'HE100001')
INSERT INTO dbo.Student (student_code, full_name, email) VALUES
('HE100001', N'Nguyễn Văn An',     'an.nguyenvan@email.com'),
('HE100002', N'Trần Thị Bình',    'binh.tran@email.com'),
('HE100003', N'Lê Hoàng Cường',   'cuong.le@email.com'),
('HE100004', N'Phạm Thị Dung',    'dung.pham@email.com'),
('HE100005', N'Hoàng Văn Em',     'em.hoang@email.com');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TeamMember WHERE project_id = 1 AND student_id = 1)
INSERT INTO dbo.TeamMember (project_id, student_id, git_email, role)
VALUES
(1, 1, 'an.nguyenvan@email.com',   N'Leader'),
(1, 2, 'binh.tran@email.com',      N'Member'),
(1, 3, 'cuong.le@email.com',       N'Member'),
(1, 4, 'dung.pham@email.com',      N'Member'),
(1, 5, 'em.hoang@email.com',       N'Member');
GO
