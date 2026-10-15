USE Spirit_GitAnalytics;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Submission WHERE assignment_id = 1 AND student_id = 2)
INSERT INTO dbo.Submission (assignment_id, student_id, content) VALUES
(1, 2, N'Em chào thầy, em đã hoàn thành bài Lab 1 với Hello World Servlet. File đính kèm: HelloServlet.java'),
(1, 3, N'Bài làm của em: sử dụng doGet() trả về PrintWriter với Hello World.'),
(1, 4, N'Em submit bài Lab 1. Code hoạt động trên Tomcat 9.');
GO

PRINT '>> Sample submissions added.';
GO
