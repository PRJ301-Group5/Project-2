package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AppUserDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.util.SecurityUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * LoginServlet - GET hiển thị form, POST xác thực.
 * URL: /login
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AppUserDAO userDAO = new AppUserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Nếu đã login thì redirect về dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/app/dashboard");
            return;
        }
        req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = trim(req.getParameter("username"));
        String password = req.getParameter("password");

        if (username.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ username và password.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
            return;
        }

        try {
            AppUser user = userDAO.findByUsername(username);
            if (user == null || !user.isActive()) {
                req.setAttribute("error", "Tài khoản không tồn tại hoặc đã bị khoá.");
                req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
                return;
            }
            if (!SecurityUtil.verifyPassword(password, user.getPasswordHash())) {
                req.setAttribute("error", "Sai mật khẩu.");
                req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
                return;
            }
            // OK
            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("role", user.getRole());
            session.setMaxInactiveInterval(30 * 60); // 30 min
            resp.sendRedirect(req.getContextPath() + "/app/dashboard");
        } catch (SQLException | ClassNotFoundException ex) {
            req.setAttribute("error", "Lỗi hệ thống: " + ex.getMessage());
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
        }
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}
