package com.Spirit.gitanalytics.filter;

import com.Spirit.gitanalytics.model.AppUser;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * AuthFilter - Bảo vệ tất cả URL dưới /app/*.
 * Nếu chưa login -> redirect về /login.
 * Nếu URL có "/teacher/" -> bắt buộc role TEACHER/ADMIN.
 * Nếu URL có "/student/" -> bắt buộc role STUDENT/ADMIN.
 */
public class AuthFilter implements Filter {

    private static final List<String> PUBLIC_PREFIXES = Arrays.asList(
        "/login", "/register", "/otp", "/forgot", "/logout",
        "/css/", "/js/", "/images/", "/index.jsp", "/projects"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpReq = (HttpServletRequest) req;
        HttpServletResponse httpResp = (HttpServletResponse) resp;
        String path = httpReq.getRequestURI().substring(httpReq.getContextPath().length());

        // Cho phép root path (index)
        if (path.equals("/") || path.isEmpty()) {
            chain.doFilter(req, resp);
            return;
        }
        // Cho phép các public endpoints
        for (String pub : PUBLIC_PREFIXES) {
            if (path.equals(pub) || path.startsWith(pub)) {
                chain.doFilter(req, resp);
                return;
            }
        }
        // Bỏ qua JSP, error, health check
        if (path.endsWith(".jsp") && !path.startsWith("/app/")) {
            chain.doFilter(req, resp);
            return;
        }

        HttpSession session = httpReq.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("currentUser") : null;

        if (user == null) {
            // Chưa đăng nhập
            httpResp.sendRedirect(httpReq.getContextPath() + "/login");
            return;
        }

        // Role check
        if (path.startsWith("/app/teacher/") && !("TEACHER".equals(user.getRole()) || "ADMIN".equals(user.getRole()))) {
            httpResp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền Teacher.");
            return;
        }
        if (path.startsWith("/app/student/") && !("STUDENT".equals(user.getRole()) || "ADMIN".equals(user.getRole()))) {
            httpResp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền Student.");
            return;
        }

        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {}
}
