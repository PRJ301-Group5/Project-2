package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AppUserDAO;
import com.Spirit.gitanalytics.dao.ClassRoomDAO;
import com.Spirit.gitanalytics.dao.SubjectDAO;
import com.Spirit.gitanalytics.model.AppUser;
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
import java.util.List;
import java.util.regex.Pattern;

/**
 * ClassRoomServlet - Teacher tạo / sửa / xoá lớp.
 * URL: /app/classes
 *
 * GET  ?action=create          -> forward /jsp/classes-create.jsp (form)
 * GET  ?action=edit&id={id}    -> forward form edit
 * GET  ?action=manage&id={id}  -> forward /jsp/classes-manage.jsp (danh sách student)
 * POST action=create | update | delete
 */
@WebServlet(name = "ClassRoomServlet", urlPatterns = {"/app/classes"})
public class ClassRoomServlet extends HttpServlet {

    private final ClassRoomDAO dao = new ClassRoomDAO();
    private final SubjectDAO subjectDao = new SubjectDAO();
    private final AppUserDAO userDao = new AppUserDAO();

    private static final Pattern CODE_PATTERN = Pattern.compile("^[A-Za-z0-9_-]{3,20}$");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        if (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Teacher/Admin mới quản lý lớp.");
            return;
        }
        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "create": {
                    req.setAttribute("subjects", subjectDao.findAll());
                    req.setAttribute("mode", "create");
                    req.getRequestDispatcher("/jsp/classes-form.jsp").forward(req, resp);
                    return;
                }
                case "edit": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    ClassRoom c = dao.findById(id);
                    if (c == null) { resp.sendError(404); return; }
                    if (!"ADMIN".equals(user.getRole()) && c.getTeacherId() != user.getUserId()) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    req.setAttribute("classRoom", c);
                    req.setAttribute("subjects", subjectDao.findAll());
                    req.setAttribute("mode", "edit");
                    req.getRequestDispatcher("/jsp/classes-form.jsp").forward(req, resp);
                    return;
                }
                case "manage": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    ClassRoom c = dao.findById(id);
                    if (c == null) { resp.sendError(404); return; }
                    if (!"ADMIN".equals(user.getRole()) && c.getTeacherId() != user.getUserId()) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    List<AppUser> students = userDao.findStudentsInClass(id);
                    req.setAttribute("classRoom", c);
                    req.setAttribute("students", students);
                    req.getRequestDispatcher("/jsp/classes-manage.jsp").forward(req, resp);
                    return;
                }
                default: { // list
                    List<ClassRoom> classes = "ADMIN".equals(user.getRole()) ? dao.findAll() : dao.findByTeacher(user.getUserId());
                    req.setAttribute("classes", classes);
                    req.getRequestDispatcher("/jsp/classes.jsp").forward(req, resp);
                }
            }
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        if (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "create";

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                ClassRoom existing = dao.findById(id);
                if (existing == null) { resp.sendError(404); return; }
                if (!"ADMIN".equals(user.getRole()) && existing.getTeacherId() != user.getUserId()) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
                }
                dao.delete(id);
                session.setAttribute("flash", "Đã xoá lớp #" + id);
                resp.sendRedirect(req.getContextPath() + "/app/classes");
                return;
            }

            if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                ClassRoom existing = dao.findById(id);
                if (existing == null) { resp.sendError(404); return; }
                if (!"ADMIN".equals(user.getRole()) && existing.getTeacherId() != user.getUserId()) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN); return;
                }
                String code = req.getParameter("classCode").trim();
                if (!CODE_PATTERN.matcher(code).matches()) {
                    throw new ServletException("Mã lớp không hợp lệ (3-20 ký tự A-Z, 0-9, _, -).");
                }
                existing.setSubjectId(Integer.parseInt(req.getParameter("subjectId")));
                existing.setClassCode(code);
                existing.setClassName(req.getParameter("className"));
                existing.setSemester(req.getParameter("semester"));
                existing.setDescription(req.getParameter("description"));
                existing.setJoinEnabled(req.getParameter("joinEnabled") != null);
                dao.update(existing);
                session.setAttribute("flash", "Đã cập nhật lớp " + code);
                resp.sendRedirect(req.getContextPath() + "/app/classes");
                return;
            }

            // create
            String code = req.getParameter("classCode").trim();
            if (!CODE_PATTERN.matcher(code).matches()) {
                req.setAttribute("error", "Mã lớp không hợp lệ (3-20 ký tự A-Z, 0-9, _, -).");
                req.setAttribute("subjects", subjectDao.findAll());
                req.setAttribute("mode", "create");
                req.getRequestDispatcher("/jsp/classes-form.jsp").forward(req, resp);
                return;
            }
            if (dao.findByCode(code) != null) {
                req.setAttribute("error", "Mã lớp '" + code + "' đã tồn tại. Hãy chọn mã khác.");
                req.setAttribute("subjects", subjectDao.findAll());
                req.setAttribute("mode", "create");
                req.getRequestDispatcher("/jsp/classes-form.jsp").forward(req, resp);
                return;
            }
            ClassRoom c = new ClassRoom();
            c.setSubjectId(Integer.parseInt(req.getParameter("subjectId")));
            c.setTeacherId(user.getUserId());
            c.setClassCode(code);
            c.setClassName(req.getParameter("className"));
            c.setSemester(req.getParameter("semester"));
            c.setDescription(req.getParameter("description"));
            c.setJoinEnabled(req.getParameter("joinEnabled") != null);
            dao.insert(c);
            session.setAttribute("flash", "Đã tạo lớp " + code + ". Mời sinh viên nhập mã này để vào lớp.");
            resp.sendRedirect(req.getContextPath() + "/app/classes");
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
