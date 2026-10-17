<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đăng nhập" scope="request"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập · Spirit</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
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
                    <div class="mark-lg"><i class="bi bi-mortarboard-fill"></i></div>
                    <h2>Spirit</h2>
                    <p class="sub">AI Grading + Git Analytics for Lecturers</p>
                </div>
                <div class="auth-body">
                    <c:if test="${not empty success}">
                        <div class="alert alert-success">
                            <i class="bi bi-check-circle"></i> ${success}
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">
                            <i class="bi bi-exclamation-triangle"></i> ${error}
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/login" novalidate class="spirit-auto-submit">
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person"></i></span>
                                <input type="text" name="username" class="form-control" required minlength="3" maxlength="50" autocomplete="username" placeholder="teacher1">
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label">Mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input type="password" name="password" id="password" class="form-control" required minlength="6" autocomplete="current-password" placeholder="••••••••">
                                <button class="btn btn-outline-secondary" type="button" onclick="togglePwd()">
                                    <i class="bi bi-eye" id="eyeIcon"></i>
                                </button>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary btn-lg w-100 spirit-loading">
                            <i class="bi bi-box-arrow-in-right"></i> Đăng nhập
                        </button>
                    </form>
                    <hr>
                    <div class="text-center">
                        <a href="${pageContext.request.contextPath}/register" class="text-decoration-none">
                            Chưa có tài khoản? <strong>Đăng ký</strong>
                        </a>
                    </div>
                    <div class="alert alert-info mt-3 small mb-0">
                        <strong><i class="bi bi-info-circle"></i> Demo accounts</strong><br>
                        Teacher: <code>teacher1 / Password@123</code><br>
                        Student: <code>student1 / Password@123</code>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
function togglePwd() {
    const p = document.getElementById('password');
    const i = document.getElementById('eyeIcon');
    if (p.type === 'password') {
        p.type = 'text';
        i.classList.remove('bi-eye'); i.classList.add('bi-eye-slash');
    } else {
        p.type = 'password';
        i.classList.remove('bi-eye-slash'); i.classList.add('bi-eye');
    }
}
</script>
</body>
</html>
