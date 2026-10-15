-- =============================================================
-- Spirit - SQL Server connection test (verified)
-- =============================================================

-- 1. Verify connection
SELECT
    @@SERVERNAME           AS ServerName,
    SERVERPROPERTY('InstanceName')   AS Instance,
    SERVERPROPERTY('ProductVersion') AS Version,
    DB_NAME()              AS CurrentDatabase,
    SYSTEM_USER            AS ConnectedUser;
GO

-- 2. List tables
SELECT
    t.TABLE_NAME,
    (SELECT COUNT(*) FROM Spirit_GitAnalytics.INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_NAME = t.TABLE_NAME) AS Columns
FROM Spirit_GitAnalytics.INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_SCHEMA = 'dbo'
ORDER BY t.TABLE_NAME;
GO

-- 3. Sample queries
SELECT 'Project'          AS Tbl, COUNT(*) AS Rows FROM Spirit_GitAnalytics.dbo.Project
UNION ALL SELECT 'Student',           COUNT(*) FROM Spirit_GitAnalytics.dbo.Student
UNION ALL SELECT 'TeamMember',        COUNT(*) FROM Spirit_GitAnalytics.dbo.TeamMember
UNION ALL SELECT 'CommitRecord',      COUNT(*) FROM Spirit_GitAnalytics.dbo.CommitRecord
UNION ALL SELECT 'ContributionScore', COUNT(*) FROM Spirit_GitAnalytics.dbo.ContributionScore;
GO

-- 4. Top contributors
SELECT TOP 5
    s.full_name,
    s.student_code,
    cs.total_commits,
    cs.total_lines_added,
    cs.contribution_pct,
    cs.fairness_score,
    cs.status
FROM Spirit_GitAnalytics.dbo.ContributionScore cs
JOIN Spirit_GitAnalytics.dbo.TeamMember tm ON cs.team_member_id = tm.team_member_id
JOIN Spirit_GitAnalytics.dbo.Student    s  ON tm.student_id   = s.student_id
ORDER BY cs.contribution_pct DESC;
GO
