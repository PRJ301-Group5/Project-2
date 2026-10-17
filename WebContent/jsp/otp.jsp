<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Xác thực OTP" scope="request"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác thực OTP · Spirit</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css?v=2.0">
</head>
<body class="bg-spirit auth-bg">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5 col-xl-4">
            <div class="auth-card fade-in">
                <div class="auth-head">
                    <div class="mark-lg"><i class="bi bi-shield-lock-fill"></i></div>
                    <h2>Xác thực OTP</h2>
                    <p class="sub">Mã OTP đã được gửi tới <strong>${email}</strong></p>
                </div>
                <div class="auth-body">
                    <c:if test="${not empty info}">
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle"></i> ${info}
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">
                            <i class="bi bi-exclamation-triangle"></i> ${error}
                        </div>
                    </c:if>
                    <c:if test="${not empty sessionScope.demoOtp}">
                        <div class="alert alert-warning">
                            <i class="bi bi-bug"></i> <strong>DEMO MODE</strong> — Mã OTP của bạn là
                            <code style="font-size: 1.1rem; font-weight: 700;">${sessionScope.demoOtp}</code>
                            <br><small>SMTP Gmail chưa cấu hình — production sẽ gửi email thật.</small>
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/register" class="spirit-auto-submit">
                        <input type="hidden" name="action" value="verify">
                        <div class="mb-4">
                            <label class="form-label text-center d-block">Mã OTP (6 chữ số)</label>
                            <input type="text" name="code" class="form-control form-control-lg text-center fw-bold"
                                   style="letter-spacing: 0.4em; font-size: 1.5rem; font-family: 'JetBrains Mono', monospace;"
                                   required pattern="[0-9]{6}" maxlength="6" placeholder="000000" autofocus>
                        </div>
                        <button class="btn btn-primary btn-lg w-100 spirit-loading">
                            <i class="bi bi-check2-circle"></i> Xác nhận
                        </button>
                    </form>
                    <hr>
                    <div class="text-center">
                        <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
