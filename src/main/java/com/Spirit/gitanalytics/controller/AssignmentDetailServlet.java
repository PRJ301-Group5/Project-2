package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.AssignmentFileDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.dao.SubmissionFileDAO;
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
import java.util.List;

/**
 * AssignmentDetailServlet - Trang chi tiết 1 assignment.
 * - Student: thấy đề bài + file đề, bài nộp của mình, file đính kèm.
 * - Teacher: thấy danh sách bài nộp + file sinh viên gửi, link tới grading.
 * URL: /app/assignments/detail
 */
@WebServlet(name = "AssignmentDetailServlet", urlPatterns = {"/app/assignments/detail"})
public class AssignmentDetailServlet extends HttpServlet {

    private final AssignmentDAO asmDao = new AssignmentDAO();
    private final SubmissionDAO subDao = new SubmissionDAO();
    private final AssignmentFileDAO afDao = new AssignmentFileDAO();
    private final SubmissionFileDAO sfDao = new SubmissionFileDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            Assignment a = asmDao.findById(id);
            if (a == null) { resp.sendError(404, "Assignment không tồn tại."); return; }
            req.setAttribute("assignment", a);
            req.setAttribute("assignmentFiles", afDao.findByAssignment(id));

            if ("STUDENT".equals(user.getRole())) {
                Submission mine = subDao.findByAssignmentAndStudent(id, user.getUserId());
                req.setAttribute("mySubmission", mine);
                if (mine != null) {
                    req.setAttribute("mySubmissionFiles", sfDao.findBySubmission(mine.getSubmissionId()));
                }
            } else {
                List<Submission> subs = subDao.findByAssignment(id);
                req.setAttribute("submissions", subs);
                // Load files cho mỗi submission
                java.util.Map<Integer, List<com.Spirit.gitanalytics.model.SubmissionFile>> subFiles =
                    new java.util.HashMap<>();
                for (Submission s : subs) {
                    subFiles.put(s.getSubmissionId(), sfDao.findBySubmission(s.getSubmissionId()));
                }
                req.setAttribute("subFilesMap", subFiles);
            }
            req.getRequestDispatcher("/jsp/assignment-detail.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
