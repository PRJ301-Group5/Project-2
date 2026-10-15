<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký · Spirit</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body class="bg-spirit auth-bg">
<div class="container">
    <div class="row justify-content-center mt-5">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-lg">
                <div class="card-body p-4">
                    <h3 class="fw-bold mb-3"><i class="bi bi-person-plus"></i> Đăng ký tài khoản</h3>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/register" novalidate>
                        <div class="mb-2">
                            <label class="form-label">Username</label>
                            <input type="text" name="username" class="form-control" required minlength="3" maxlength="50"
                                   value="${param.username}" placeholder="3-50 ký tự">
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-2">
                                <label class="form-label">Mật khẩu</label>
                                <input type="password" name="password" class="form-control" required minlength="6">
                            </div>
                            <div class="col-md-6 mb-2">
                                <label class="form-label">Xác nhận</label>
                                <input type="password" name="confirm" class="form-control" required minlength="6">
                            </div>
                        </div>
                        <div class="mb-2">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="fullName" class="form-control" required maxlength="100"
                                   value="${param.fullName}">
                        </div>
                        <div class="mb-2">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" required
                                   value="${param.email}" placeholder="example@fpt.edu.vn">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Vai trò</label>
                            <select name="role" class="form-select" required>
                                <option value="STUDENT" ${param.role == 'STUDENT' ? 'selected' : ''}>Student</option>
                                <option value="TEACHER" ${param.role == 'TEACHER' ? 'selected' : ''}>Teacher</option>
                            </select>
                        </div>
                        <button class="btn btn-primary w-100">
                            <i class="bi bi-send"></i> Gửi mã OTP
                        </button>
                    </form>
                    <hr>
                    <div class="text-center">
                        <a href="${pageContext.request.contextPath}/login">Đã có tài khoản? Đăng nhập</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
