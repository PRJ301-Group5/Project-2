package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AppUserDAO;
import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.ClassRoomDAO;
import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
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
import java.util.ArrayList;
import java.util.List;

/**
 * DashboardServlet - Trang chính sau khi login.
 * Teacher: thấy lớp + assignment mình tạo + thông báo.
 * Student: thấy môn học + assignment sắp đến hạn + thông báo.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/app/dashboard"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            ClassRoomDAO classDao = new ClassRoomDAO();
            AssignmentDAO asmDao = new AssignmentDAO();
            NotificationDAO notiDao = new NotificationDAO();

            List<ClassRoom> classes = new ArrayList<>();
            List<Assignment> assignments = new ArrayList<>();
            List<Notification> notifications = notiDao.findByUser(user.getUserId(), 10);
            int unread = notiDao.countUnread(user.getUserId());

            if ("TEACHER".equals(user.getRole()) || "ADMIN".equals(user.getRole())) {
                classes = classDao.findByTeacher(user.getUserId());
                assignments = asmDao.findAll();
            } else if ("STUDENT".equals(user.getRole())) {
                classes = classDao.findByStudent(user.getUserId());
                List<Integer> classIds = new ArrayList<>();
                for (ClassRoom c : classes) classIds.add(c.getClassId());
                assignments = asmDao.findByStudentClasses(classIds);
            }

            req.setAttribute("classes", classes);
            req.setAttribute("assignments", assignments);
            req.setAttribute("notifications", notifications);
            req.setAttribute("unreadCount", unread);
            req.getRequestDispatcher("/jsp/dashboard.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
