package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
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
 * AssignmentDetailServlet - Trang chi tiết 1 assignment.
 * - Student: thấy bài tập, nộp bài (qua /app/submissions).
 * - Teacher: thấy danh sách bài nộp, link tới grading.
 * URL: /app/assignments/detail
 */
@WebServlet(name = "AssignmentDetailServlet", urlPatterns = {"/app/assignments/detail"})
public class AssignmentDetailServlet extends HttpServlet {

    private final AssignmentDAO asmDao = new AssignmentDAO();
    private final SubmissionDAO subDao = new SubmissionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            Assignment a = asmDao.findById(id);
            if (a == null) { resp.sendError(404, "Assignment không tồn tại."); return; }
            req.setAttribute("assignment", a);

            if ("STUDENT".equals(user.getRole())) {
                Submission mine = subDao.findByAssignmentAndStudent(id, user.getUserId());
                req.setAttribute("mySubmission", mine);
            } else {
                req.setAttribute("submissions", subDao.findByAssignment(id));
            }
            req.getRequestDispatcher("/jsp/assignment-detail.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
