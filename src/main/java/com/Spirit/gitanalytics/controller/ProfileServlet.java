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
 * ProfileServlet - Xem / sửa thông tin cá nhân, đổi mật khẩu.
 * URL: /app/profile
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/app/profile"})
public class ProfileServlet extends HttpServlet {

    private final AppUserDAO userDAO = new AppUserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        String action = req.getParameter("action");
        try {
            if ("updateInfo".equals(action)) {
                user.setFullName(req.getParameter("fullName"));
                user.setPhone(req.getParameter("phone"));
                userDAO.updatePassword(user.getUserId(), user.getPasswordHash()); // placeholder
                // Cập nhật thông tin (gọi update cụ thể)
                userDAO.updateInfo(user);
                session.setAttribute("currentUser", user);
                req.setAttribute("flash", "Đã cập nhật thông tin.");
            } else if ("changePassword".equals(action)) {
                String oldP = req.getParameter("oldPassword");
                String newP = req.getParameter("newPassword");
                String cfm  = req.getParameter("confirm");
                if (!SecurityUtil.verifyPassword(oldP, user.getPasswordHash())) {
                    req.setAttribute("error", "Mật khẩu cũ không đúng.");
                } else if (newP == null || newP.length() < 6) {
                    req.setAttribute("error", "Mật khẩu mới phải từ 6 ký tự.");
                } else if (!newP.equals(cfm)) {
                    req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
                } else {
                    String newHash = SecurityUtil.hashPassword(newP);
                    userDAO.updatePassword(user.getUserId(), newHash);
                    user.setPasswordHash(newHash);
                    session.setAttribute("currentUser", user);
                    req.setAttribute("flash", "Đã đổi mật khẩu.");
                }
            }
            req.getRequestDispatcher("/jsp/profile.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
