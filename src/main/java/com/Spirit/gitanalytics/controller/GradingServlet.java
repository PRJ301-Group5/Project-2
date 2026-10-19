package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AppUserDAO;
import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.GradeDAO;
import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.dao.SubmissionFileDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.Grade;
import com.Spirit.gitanalytics.model.Notification;
import com.Spirit.gitanalytics.model.Submission;
import com.Spirit.gitanalytics.service.EmailService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * GradingServlet - Teacher chấm điểm.
 * GET: hiển thị form chấm. POST: lưu điểm + feedback.
 * URL: /app/teacher/grading
 */
@WebServlet(name = "GradingServlet", urlPatterns = {"/app/teacher/grading"})
public class GradingServlet extends HttpServlet {

    private final SubmissionDAO subDao = new SubmissionDAO();
    private final SubmissionFileDAO subFileDao = new SubmissionFileDAO();
    private final GradeDAO gradeDao = new GradeDAO();
    private final AssignmentDAO asmDao = new AssignmentDAO();
    private final AppUserDAO userDao = new AppUserDAO();
    private final NotificationDAO notiDao = new NotificationDAO();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Teacher mới được chấm điểm.");
            return;
        }
        try {
            int submissionId = Integer.parseInt(req.getParameter("submissionId"));
            Submission s = subDao.findById(submissionId);
            if (s == null) { resp.sendError(404); return; }
            Assignment a = asmDao.findById(s.getAssignmentId());
            req.setAttribute("submission", s);
            req.setAttribute("assignment", a);
            // Load file đính kèm của sinh viên để teacher tải về xem
            req.setAttribute("submissionFiles", subFileDao.findBySubmission(submissionId));
            req.getRequestDispatcher("/jsp/grade.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Teacher mới được chấm điểm.");
            return;
        }
        try {
            int submissionId = Integer.parseInt(req.getParameter("submissionId"));
            double score = Double.parseDouble(req.getParameter("score"));
            String feedback = req.getParameter("feedback");

            Submission s = subDao.findById(submissionId);
            Assignment a = asmDao.findById(s.getAssignmentId());
            if (score < 0 || score > a.getMaxScore()) {
                req.setAttribute("error", "Điểm phải từ 0 đến " + a.getMaxScore());
                req.setAttribute("submission", s);
                req.setAttribute("assignment", a);
                req.getRequestDispatcher("/jsp/grade.jsp").forward(req, resp);
                return;
            }

            Grade g = new Grade();
            g.setSubmissionId(submissionId);
            g.setGraderId(user.getUserId());
            g.setScore(score);
            g.setFeedback(feedback);
            gradeDao.upsert(g);

            // Notify student
            AppUser student = userDao.findById(s.getStudentId());
            Notification n = new Notification();
            n.setUserId(student.getUserId());
            n.setTitle("Đã có điểm: " + a.getTitle());
            n.setBody("Bạn được " + score + "/" + a.getMaxScore() + ". Xem chi tiết.");
            n.setLink("/app/assignments/detail?id=" + a.getAssignmentId());
            try { notiDao.insert(n); emailService.sendGradeNotice(student.getEmail(), a.getTitle(), score); } catch (Exception ignore) {}

            req.getSession().setAttribute("flash", "Đã lưu điểm " + score + "/" + a.getMaxScore() + " cho " + student.getFullName());
            resp.sendRedirect(req.getContextPath() + "/app/assignments/detail?id=" + a.getAssignmentId());
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
