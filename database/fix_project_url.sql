USE Spirit_GitAnalytics;
GO
IF EXISTS (SELECT 1 FROM dbo.Project WHERE project_code = 'PRJ301_G5')
UPDATE dbo.Project
SET repo_url = 'https://github.com/PRJ301-Group5/Project-2'
WHERE project_code = 'PRJ301_G5';
PRINT '>> Project repo_url updated.';
GO
