package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.LoginHistoryDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.LoginHistory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * LoginHistoryServlet - Xem lịch sử đăng nhập.
 * URL: /app/login-history
 *
 * Phân quyền:
 *   - STUDENT : chỉ xem lịch sử của chính mình
 *   - TEACHER : xem lịch sử của mình + toàn hệ thống (gần đây)
 *   - ADMIN   : xem toàn hệ thống + lọc theo user
 *
 * Tham số query:
 *   ?userId=N   (TEACHER/ADMIN) - xem lịch sử của user N
 */
@WebServlet(name = "LoginHistoryServlet", urlPatterns = {"/app/login-history"})
public class LoginHistoryServlet extends HttpServlet {

    private final LoginHistoryDAO dao = new LoginHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String role = user.getRole();
        boolean isAdmin = "ADMIN".equals(role);
        boolean isTeacher = "TEACHER".equals(role) || isAdmin;

        // userId cần xem: mặc định là chính mình
        int targetUserId = user.getUserId();
        String userIdParam = req.getParameter("userId");
        if (userIdParam != null && !userIdParam.trim().isEmpty()) {
            try {
                int requested = Integer.parseInt(userIdParam.trim());
                // STUDENT không được xem của người khác
                if (isTeacher && requested > 0) {
                    targetUserId = requested;
                }
            } catch (NumberFormatException ignore) {}
        }

        try {
            // Lịch sử của user được chọn
            List<LoginHistory> history = dao.findByUser(targetUserId, 100);
            req.setAttribute("history", history);
            req.setAttribute("targetUserId", targetUserId);
            req.setAttribute("isSelf", targetUserId == user.getUserId());

            // TEACHER/ADMIN: thêm danh sách toàn hệ thống ở tab thứ 2
            if (isTeacher) {
                req.setAttribute("systemHistory", dao.listRecent(200));
            }

            // Thống kê nhanh
            req.setAttribute("totalCount", history.size());
            int failed = 0;
            for (LoginHistory h : history) {
                if (!h.isSuccess()) failed++;
            }
            req.setAttribute("failedCount", failed);

            req.getRequestDispatcher("/jsp/login-history.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
}
