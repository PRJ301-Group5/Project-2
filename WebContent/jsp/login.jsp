<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đăng nhập" scope="request"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập · Spirit</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body class="bg-spirit auth-bg">
<div class="container">
    <div class="row justify-content-center mt-5">
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-lg">
                <div class="card-body p-4">
                    <div class="text-center mb-4">
                        <h2 class="fw-bold"><i class="bi bi-mortarboard-fill text-primary"></i> Spirit</h2>
                        <p class="text-muted small mb-0">AI Grading Tool for Lecturers</p>
                    </div>

                    <c:if test="${not empty success}">
                        <div class="alert alert-success">${success}</div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/login" novalidate>
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person"></i></span>
                                <input type="text" name="username" class="form-control"
                                       required minlength="3" maxlength="50" autocomplete="username">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input type="password" name="password" id="password" class="form-control"
                                       required minlength="6" autocomplete="current-password">
                                <button class="btn btn-outline-secondary" type="button" onclick="togglePwd()">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-box-arrow-in-right"></i> Đăng nhập
                        </button>
                    </form>
                    <hr>
                    <div class="text-center">
                        <a href="${pageContext.request.contextPath}/register" class="text-decoration-none">
                            Chưa có tài khoản? Đăng ký
                        </a>
                    </div>
                    <div class="alert alert-info mt-3 small">
                        <strong>Demo accounts:</strong><br>
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
    p.type = p.type === 'password' ? 'text' : 'password';
}
</script>
</body>
</html>
