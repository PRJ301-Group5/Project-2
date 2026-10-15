package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.Notification;
import com.Spirit.gitanalytics.model.Submission;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * SubmissionServlet - Student nộp bài (POST) hoặc xem lại (GET).
 * URL: /app/submissions
 */
@WebServlet(name = "SubmissionServlet", urlPatterns = {"/app/submissions"})
public class SubmissionServlet extends HttpServlet {

    private final SubmissionDAO subDao = new SubmissionDAO();
    private final AssignmentDAO asmDao = new AssignmentDAO();
    private final NotificationDAO notiDao = new NotificationDAO();

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

            // Validate
            if (a == null) { resp.sendError(404, "Assignment không tồn tại."); return; }
            if (a.getDueDate() != null && a.getDueDate().before(new java.util.Date())) {
                req.setAttribute("error", "Đã quá hạn nộp bài (deadline: " + a.getDueDate() + ").");
                req.setAttribute("assignment", a);
                req.getRequestDispatcher("/jsp/submit.jsp").forward(req, resp);
                return;
            }
            if ((content == null || content.trim().isEmpty()) && (filePath == null || filePath.trim().isEmpty())) {
                req.setAttribute("error", "Vui lòng nhập nội dung hoặc đường dẫn file.");
                req.setAttribute("assignment", a);
                req.getRequestDispatcher("/jsp/submit.jsp").forward(req, resp);
                return;
            }

            // Insert or update
            Submission existing = subDao.findByAssignmentAndStudent(assignmentId, user.getUserId());
            if (existing == null) {
                Submission s = new Submission();
                s.setAssignmentId(assignmentId);
                s.setStudentId(user.getUserId());
                s.setContent(content);
                s.setFilePath(filePath);
                subDao.insert(s);

                // Notify teacher of class
                Notification n = new Notification();
                n.setUserId(a.getCreatedBy());
                n.setTitle("Bài nộp mới: " + a.getTitle());
                n.setBody(user.getFullName() + " vừa nộp bài.");
                n.setLink("/gitanalytics/app/assignments/detail?id=" + a.getAssignmentId());
                try { notiDao.insert(n); } catch (Exception ignore) {}
            } else {
                existing.setContent(content);
                existing.setFilePath(filePath);
                subDao.update(existing);
            }
            req.getSession().setAttribute("flash", "Đã lưu bài nộp.");
            resp.sendRedirect(req.getContextPath() + "/app/assignments/detail?id=" + assignmentId);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
