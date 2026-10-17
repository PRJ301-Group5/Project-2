<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Lỗi" scope="request"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lỗi · Spirit</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css?v=2.0">
    <style>
        .error-wrap {
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            padding: 24px;
        }
    </style>
</head>
<body class="bg-spirit">
<div class="error-wrap">
    <div class="text-center fade-in" style="max-width: 480px;">
        <div class="spirit-mark mx-auto mb-3" style="width: 80px; height: 80px; font-size: 32px; border-radius: 20px;">
            <i class="bi bi-exclamation-triangle"></i>
        </div>
        <h1 class="mb-2" style="font-size: 2.5rem;">Đã xảy ra lỗi</h1>
        <p class="text-muted mb-1">${pageContext.errorData.statusCode}</p>
        <p class="text-muted mb-4">${pageContext.exception.message}</p>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-lg spirit-loading">
            <i class="bi bi-house"></i> Về trang chính
        </a>
    </div>
</div>
</body>
</html>
