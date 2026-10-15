<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác thực OTP · Spirit</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body class="bg-spirit auth-bg">
<div class="container">
    <div class="row justify-content-center mt-5">
        <div class="col-md-5">
            <div class="card shadow">
                <div class="card-body p-4">
                    <h3 class="fw-bold mb-2">Xác thực OTP</h3>
                    <p class="text-muted small">Mã OTP đã được gửi tới <strong>${email}</strong></p>

                    <c:if test="${not empty info}">
                        <div class="alert alert-info">${info}</div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>
                    <c:if test="${not empty sessionScope.demoOtp}">
                        <div class="alert alert-warning">
                            <i class="bi bi-bug"></i> <strong>DEMO MODE</strong>: Mã OTP của bạn là
                            <code class="fs-5">${sessionScope.demoOtp}</code>
                            (SMTP Gmail chưa được cấu hình - trong production, mã sẽ gửi qua email thật).
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/register">
                        <input type="hidden" name="action" value="verify">
                        <div class="mb-3">
                            <label class="form-label">Mã OTP (6 chữ số)</label>
                            <input type="text" name="code" class="form-control form-control-lg text-center"
                                   required pattern="[0-9]{6}" maxlength="6" placeholder="000000">
                        </div>
                        <button class="btn btn-primary w-100">Xác nhận</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
