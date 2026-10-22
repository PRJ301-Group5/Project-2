package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.LoginHistoryDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.LoginHistory;
import com.Spirit.gitanalytics.util.ClientIpUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * LogoutServlet - Ghi lại sự kiện đăng xuất rồi xoá session, redirect về /login.
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    private final LoginHistoryDAO loginHistoryDAO = new LoginHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            AppUser user = (AppUser) session.getAttribute("currentUser");
            if (user != null) {
                try {
                    LoginHistory h = new LoginHistory();
                    h.setUserId(user.getUserId());
                    h.setUsername(user.getUsername());
                    h.setIpAddress(ClientIpUtil.getClientIp(req));
                    h.setUserAgent(ClientIpUtil.getUserAgent(req));
                    h.setLoginStatus("SUCCESS");
                    h.setFailureReason("LOGOUT");
                    loginHistoryDAO.insert(h);
                } catch (Exception ignore) {
                    // Không để lỗi audit chặn việc đăng xuất
                }
            }
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
