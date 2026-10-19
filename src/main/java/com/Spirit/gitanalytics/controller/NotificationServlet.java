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
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                // Click "Xem chi tiết" từ notifications.jsp -> auto markRead + mở link
                int nid = Integer.parseInt(idStr);
                notiDao.markRead(nid, user.getUserId());
                Notification n = notiDao.findById(nid, user.getUserId());
                if (n != null && n.getLink() != null && !n.getLink().isEmpty()) {
                    String link = n.getLink();
                    // Strip context path nếu link đã chứa (vd /gitanalytics/app/...)
                    if (link.startsWith(req.getContextPath() + "/")) {
                        link = link.substring(req.getContextPath().length());
                    }
                    resp.sendRedirect(req.getContextPath() + link);
                    return;
                }
                // Không có link nội bộ -> forward tới trang detail
                req.setAttribute("notification", n);
                req.getRequestDispatcher("/jsp/notification-detail.jsp").forward(req, resp);
                return;
            }
            List<Notification> list = notiDao.findByUser(user.getUserId(), 100);
            req.setAttribute("notifications", list);
            req.getRequestDispatcher("/jsp/notifications.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        } catch (NumberFormatException ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "id không hợp lệ.");
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
