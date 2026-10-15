<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // Nếu chưa login -> về trang login
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // Đã login -> về dashboard
    response.sendRedirect(request.getContextPath() + "/app/dashboard");
%>
