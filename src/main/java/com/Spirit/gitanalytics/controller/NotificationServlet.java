package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Notification;

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
 * NotificationServlet - Xem / đánh dấu đã đọc / xoá thông báo.
 * URL: /app/notifications
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {"/app/notifications"})
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notiDao = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        try {
            List<Notification> list = notiDao.findByUser(user.getUserId(), 100);
            req.setAttribute("notifications", list);
            req.getRequestDispatcher("/jsp/notifications.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        String action = req.getParameter("action");
        try {
            if ("read".equals(action)) {
                notiDao.markRead(Integer.parseInt(req.getParameter("id")), user.getUserId());
            } else if ("readAll".equals(action)) {
                notiDao.markAllRead(user.getUserId());
            } else if ("delete".equals(action)) {
                notiDao.delete(Integer.parseInt(req.getParameter("id")), user.getUserId());
            }
            resp.sendRedirect(req.getContextPath() + "/app/notifications");
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
