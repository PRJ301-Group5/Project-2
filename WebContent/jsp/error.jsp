<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Error · Spirit</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body class="bg-spirit">
<div class="container text-center text-white" style="margin-top:120px;">
    <h1 class="display-1 fw-bold">⚠</h1>
    <h2>Đã xảy ra lỗi</h2>
    <p class="lead">${pageContext.errorData.statusCode} - ${pageContext.exception.message}</p>
    <a href="${pageContext.request.contextPath}/login" class="btn btn-light btn-lg">
        <i class="bi bi-house"></i> Về trang chính
    </a>
</div>
</body>
</html>
