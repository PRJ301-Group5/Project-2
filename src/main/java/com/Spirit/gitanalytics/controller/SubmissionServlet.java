package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.AssignmentFileDAO;
import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.dao.SubmissionFileDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.Notification;
import com.Spirit.gitanalytics.model.Submission;
import com.Spirit.gitanalytics.model.SubmissionFile;
import com.Spirit.gitanalytics.service.ArtifactService;
import com.Spirit.gitanalytics.util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * SubmissionServlet - Student nộp bài (POST) hoặc xem lại (GET).
 * Hỗ trợ multipart upload nhiều file bài làm.
 * URL: /app/submissions
 */
@WebServlet(name = "SubmissionServlet", urlPatterns = {"/app/submissions"})
@MultipartConfig(maxFileSize = 26 * 1024 * 1024, maxRequestSize = 200 * 1024 * 1024)
public class SubmissionServlet extends HttpServlet {

    private final SubmissionDAO subDao = new SubmissionDAO();
    private final AssignmentDAO asmDao = new AssignmentDAO();
    private final AssignmentFileDAO afDao = new AssignmentFileDAO();
    private final SubmissionFileDAO sfDao = new SubmissionFileDAO();
    private final NotificationDAO notiDao = new NotificationDAO();
    private final ArtifactService artifactService = new ArtifactService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        try {
            int assignmentId = Integer.parseInt(req.getParameter("assignmentId"));
            Submission s = subDao.findByAssignmentAndStudent(assignmentId, user.getUserId());
            Assignment a = asmDao.findById(assignmentId);
            req.setAttribute("submission", s);
            req.setAttribute("assignment", a);
            req.setAttribute("assignmentFiles", afDao.findByAssignment(assignmentId));
            if (s != null) {
                req.setAttribute("submissionFiles", sfDao.findBySubmission(s.getSubmissionId()));
                try {
                    com.Spirit.gitanalytics.model.SubmissionArtifact art =
                        new com.Spirit.gitanalytics.service.ArtifactService().find(s.getSubmissionId());
                    req.setAttribute("artifact", art);
                } catch (Exception ex) {
                    req.setAttribute("artifact", null);
                }
            }
            req.getRequestDispatcher("/jsp/submit.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        try {
            int assignmentId = Integer.parseInt(req.getParameter("assignmentId"));
            String content = req.getParameter("content");
            String filePath = req.getParameter("filePath");
            Assignment a = asmDao.findById(assignmentId);

            if (a == null) { resp.sendError(404, "Assignment không tồn tại."); return; }
            if (a.getDueDate() != null && a.getDueDate().before(new java.util.Date())) {
                req.setAttribute("error", "Đã quá hạn nộp bài (deadline: " + a.getDueDate() + ").");
                req.setAttribute("assignment", a);
                req.getRequestDispatcher("/jsp/submit.jsp").forward(req, resp);
                return;
            }

            // Lưu file upload nếu có
            List<FileUploadUtil.UploadResult> uploaded = FileUploadUtil.saveFiles(req, "attachments", "submissions");

            if ((content == null || content.trim().isEmpty())
                && (filePath == null || filePath.trim().isEmpty())
                && uploaded.isEmpty()) {
                req.setAttribute("error", "Vui lòng nhập nội dung, dán link hoặc upload ít nhất 1 file.");
                req.setAttribute("assignment", a);
                req.getRequestDispatcher("/jsp/submit.jsp").forward(req, resp);
                return;
            }

            // Insert or update submission
            Submission existing = subDao.findByAssignmentAndStudent(assignmentId, user.getUserId());
            int submissionId;
            if (existing == null) {
                Submission s = new Submission();
                s.setAssignmentId(assignmentId);
                s.setStudentId(user.getUserId());
                s.setContent(content);
                s.setFilePath(filePath);
                subDao.insert(s);
                submissionId = s.getSubmissionId();

            Notification n = new Notification();
            n.setUserId(a.getCreatedBy());
            n.setTitle("Bài nộp mới: " + a.getTitle());
            n.setBody(user.getFullName() + " vừa nộp bài" + (uploaded.isEmpty() ? "." : " với " + uploaded.size() + " file.") );
            n.setLink("/app/assignments/detail?id=" + a.getAssignmentId());
            try { notiDao.insert(n); } catch (Exception ignore) {}
            } else {
                existing.setContent(content);
                existing.setFilePath(filePath);
                subDao.update(existing);
                submissionId = existing.getSubmissionId();
            }

            // Lưu từng file
            for (FileUploadUtil.UploadResult r : uploaded) {
                sfDao.insert(r.toSubmissionFile(submissionId));
            }

            // Nén ZIP + tính SHA-256 ngay khi nộp (4.4.1 + 4.4.2)
            if (!uploaded.isEmpty()) {
                try {
                    String uploadRoot = FileUploadUtil.getRootDir(req);
                    artifactService.createArtifact(submissionId, sfDao.findBySubmission(submissionId), uploadRoot);
                } catch (Exception ex) {
                    // Không fail cả request, chỉ log flash warning
                    session.setAttribute("flash", "Bài đã lưu nhưng tạo artifact thất bại: " + ex.getMessage());
                }
            }

            session.setAttribute("flash", "Đã lưu bài nộp" + (uploaded.isEmpty() ? "." : " với " + uploaded.size() + " file."));
            resp.sendRedirect(req.getContextPath() + "/app/assignments/detail?id=" + assignmentId);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
