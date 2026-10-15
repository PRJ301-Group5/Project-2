package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.ClassRoomDAO;
import com.Spirit.gitanalytics.dao.SubjectDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.ClassRoom;
import com.Spirit.gitanalytics.model.Subject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

/**
 * AssignmentServlet - Quản lý bài tập (Teacher CRUD + Student list).
 * GET: list (lọc theo classId nếu có). POST: create / update / delete theo action.
 * URL: /app/assignments
 */
@WebServlet(name = "AssignmentServlet", urlPatterns = {"/app/assignments"})
public class AssignmentServlet extends HttpServlet {

    private final AssignmentDAO asmDao = new AssignmentDAO();
    private final ClassRoomDAO classDao = new ClassRoomDAO();
    private final SubjectDAO subjDao = new SubjectDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        try {
            List<Assignment> assignments;
            String classIdParam = req.getParameter("classId");

            if ("TEACHER".equals(user.getRole()) || "ADMIN".equals(user.getRole())) {
                assignments = (classIdParam == null || classIdParam.isEmpty())
                    ? asmDao.findAll()
                    : asmDao.findByClass(Integer.parseInt(classIdParam));
            } else {
                // Student: chỉ thấy assignment của các lớp mình tham gia
                List<ClassRoom> myClasses = classDao.findByStudent(user.getUserId());
                List<Integer> classIds = new java.util.ArrayList<>();
                for (ClassRoom c : myClasses) classIds.add(c.getClassId());
                assignments = asmDao.findByStudentClasses(classIds);
            }

            req.setAttribute("assignments", assignments);
            req.setAttribute("classes", classDao.findAll());
            req.getRequestDispatcher("/jsp/assignments.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Teacher mới có thể tạo bài tập.");
            return;
        }
        String action = req.getParameter("action");
        if (action == null) action = "create";
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                asmDao.delete(id);
                req.getSession().setAttribute("flash", "Đã xoá bài tập #" + id);
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Assignment a = asmDao.findById(id);
                if (a == null) { resp.sendError(404); return; }
                a.setTitle(req.getParameter("title"));
                a.setDescription(req.getParameter("description"));
                a.setDueDate(Timestamp.valueOf(req.getParameter("dueDate").replace("T", " ") + ":00"));
                a.setMaxScore(Double.parseDouble(req.getParameter("maxScore")));
                asmDao.update(a);
                req.getSession().setAttribute("flash", "Đã cập nhật bài tập #" + id);
            } else {
                Assignment a = new Assignment();
                a.setClassId(Integer.parseInt(req.getParameter("classId")));
                a.setTitle(req.getParameter("title"));
                a.setDescription(req.getParameter("description"));
                a.setDueDate(Timestamp.valueOf(req.getParameter("dueDate").replace("T", " ") + ":00"));
                a.setMaxScore(Double.parseDouble(req.getParameter("maxScore")));
                a.setCreatedBy(user.getUserId());
                asmDao.insert(a);
                req.getSession().setAttribute("flash", "Đã tạo bài tập mới.");
            }
            resp.sendRedirect(req.getContextPath() + "/app/assignments");
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
