package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.ClassRoomDAO;
import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.ClassRoom;
import com.Spirit.gitanalytics.model.Notification;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * EnrollmentServlet - Student tự join/leave lớp bằng class_code.
 * URL: /app/enroll
 *
 * GET  ?action=joinForm         -> /jsp/classes-join.jsp
 * GET  ?action=search&code=...  -> preview lớp trước khi join
 * POST action=join   | action=leave
 */
@WebServlet(name = "EnrollmentServlet", urlPatterns = {"/app/enroll"})
public class EnrollmentServlet extends HttpServlet {

    private final ClassRoomDAO classDao = new ClassRoomDAO();
    private final NotificationDAO notiDao = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        if (action == null) action = "joinForm";

        try {
            if ("search".equals(action)) {
                String code = req.getParameter("code");
                if (code == null || code.trim().isEmpty()) {
                    req.setAttribute("error", "Vui lòng nhập mã lớp.");
                } else {
                    ClassRoom c = classDao.findByCode(code.trim());
                    if (c == null) {
                        req.setAttribute("error", "Không tìm thấy lớp với mã '" + code + "'.");
                    } else if (!c.isJoinEnabled()) {
                        req.setAttribute("error", "Lớp này hiện không cho phép tự tham gia.");
                    } else if (classDao.isEnrolled(c.getClassId(), user.getUserId())) {
                        req.setAttribute("info", "Bạn đã là thành viên của lớp " + c.getClassCode() + ".");
                        req.setAttribute("classRoom", c);
                    } else {
                        req.setAttribute("classRoom", c);
                    }
                }
                req.getRequestDispatcher("/jsp/classes-join.jsp").forward(req, resp);
            } else { // joinForm
                req.getRequestDispatcher("/jsp/classes-join.jsp").forward(req, resp);
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

        String action = req.getParameter("action");
        if (action == null) action = "join";

        try {
            if ("leave".equals(action)) {
                int classId = Integer.parseInt(req.getParameter("classId"));
                classDao.unenroll(classId, user.getUserId());
                session.setAttribute("flash", "Đã rời lớp.");
            } else { // join
                int classId = Integer.parseInt(req.getParameter("classId"));
                ClassRoom c = classDao.findById(classId);
                if (c == null) { resp.sendError(404); return; }
                if (!c.isJoinEnabled()) {
                    session.setAttribute("flash", "Lớp này hiện không cho phép tự tham gia.");
                    resp.sendRedirect(req.getContextPath() + "/app/enroll");
                    return;
                }
                int n = classDao.enroll(classId, user.getUserId());
                if (n == 1) {
                    session.setAttribute("flash", "Đã vào lớp " + c.getClassCode() + " thành công.");
                    // Notify teacher
                    Notification n2 = new Notification();
                    n2.setUserId(c.getTeacherId());
                    n2.setTitle("Sinh viên mới vào lớp");
                    n2.setBody(user.getFullName() + " vừa tham gia lớp " + c.getClassCode() + ".");
                    n2.setLink("/gitanalytics/app/classes?action=manage&id=" + c.getClassId());
                    try { notiDao.insert(n2); } catch (Exception ignore) {}
                } else {
                    session.setAttribute("flash", "Bạn đã là thành viên lớp này rồi.");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/app/dashboard");
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
