package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AppUserDAO;
import com.Spirit.gitanalytics.dao.OtpCodeDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.OtpCode;
import com.Spirit.gitanalytics.service.EmailService;
import com.Spirit.gitanalytics.util.SecurityUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.regex.Pattern;

/**
 * RegisterServlet - Bước 1: nhập thông tin -> gửi OTP.
 * Bước 2: xác thực OTP -> tạo AppUser.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private static final Pattern EMAIL = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private final AppUserDAO userDAO = new AppUserDAO();
    private final OtpCodeDAO otpDAO = new OtpCodeDAO();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            doVerify(req, resp);
        } else {
            doSendOtp(req, resp);
        }
    }

    private void doSendOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = trim(req.getParameter("username"));
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirm");
        String fullName = trim(req.getParameter("fullName"));
        String email    = trim(req.getParameter("email"));
        String role     = req.getParameter("role");

        // Validation
        if (username.isEmpty() || username.length() < 3) {
            req.setAttribute("error", "Username phải từ 3 ký tự trở lên.");
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
            return;
        }
        if (password == null || password.length() < 6) {
            req.setAttribute("error", "Password phải từ 6 ký tự trở lên.");
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
            return;
        }
        if (fullName.isEmpty()) {
            req.setAttribute("error", "Họ tên không được trống.");
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
            return;
        }
        if (!EMAIL.matcher(email).matches()) {
            req.setAttribute("error", "Email không hợp lệ.");
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
            return;
        }
        if (!"TEACHER".equals(role) && !"STUDENT".equals(role)) {
            req.setAttribute("error", "Role phải là TEACHER hoặc STUDENT.");
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
            return;
        }
        try {
            if (userDAO.findByUsername(username) != null) {
                req.setAttribute("error", "Username đã tồn tại.");
                req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
                return;
            }
            if (userDAO.findByEmail(email) != null) {
                req.setAttribute("error", "Email đã được sử dụng.");
                req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
                return;
            }

            // Sinh OTP, lưu DB, gửi email (console)
            String code = emailService.sendOtp(email, "REGISTER");
            OtpCode otp = new OtpCode();
            otp.setTarget(email);
            otp.setPurpose("REGISTER");
            otp.setCode(code);
            otp.setExpiresAt(new Timestamp(System.currentTimeMillis() + 5 * 60_000)); // 5 min
            otpDAO.insert(otp);

            // Lưu thông tin tạm vào session, chuyển sang trang OTP
            HttpSession session = req.getSession(true);
            session.setAttribute("pendingUsername", username);
            session.setAttribute("pendingPassword", password);
            session.setAttribute("pendingFullName", fullName);
            session.setAttribute("pendingEmail", email);
            session.setAttribute("pendingRole", role);
            session.setAttribute("demoOtp", code); // chỉ để demo UI

            req.setAttribute("email", email);
            req.setAttribute("info", "Mã OTP đã được gửi tới " + email + ". Vui lòng kiểm tra (xem console log nếu chưa có Gmail SMTP).");
            req.getRequestDispatcher("/jsp/otp.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            req.setAttribute("error", "Lỗi: " + ex.getMessage());
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
        }
    }

    private void doVerify(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = trim(req.getParameter("code"));
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/register");
            return;
        }
        String email = (String) session.getAttribute("pendingEmail");
        if (email == null) {
            resp.sendRedirect(req.getContextPath() + "/register");
            return;
        }
        try {
            OtpCode otp = otpDAO.findValid(email, "REGISTER", code);
            if (otp == null) {
                req.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/jsp/otp.jsp").forward(req, resp);
                return;
            }
            // OK - tạo tài khoản
            AppUser u = new AppUser();
            u.setUsername((String) session.getAttribute("pendingUsername"));
            u.setPasswordHash(SecurityUtil.hashPassword((String) session.getAttribute("pendingPassword")));
            u.setFullName((String) session.getAttribute("pendingFullName"));
            u.setEmail(email);
            u.setRole((String) session.getAttribute("pendingRole"));
            u.setActive(true);
            userDAO.insert(u);
            otpDAO.markUsed(otp.getOtpId());

            // clear session pending
            session.removeAttribute("pendingUsername");
            session.removeAttribute("pendingPassword");
            session.removeAttribute("pendingFullName");
            session.removeAttribute("pendingEmail");
            session.removeAttribute("pendingRole");
            session.removeAttribute("demoOtp");

            req.setAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            req.setAttribute("error", "Lỗi: " + ex.getMessage());
            req.setAttribute("email", email);
            req.getRequestDispatcher("/jsp/otp.jsp").forward(req, resp);
        }
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}
