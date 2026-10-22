<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Đăng ký" scope="request"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký · Spirit</title>
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
        <div class="col-md-7 col-lg-6 col-xl-5">
            <div class="auth-card fade-in">
                <div class="auth-head">
                    <div class="mark-lg"><i class="bi bi-person-plus-fill"></i></div>
                    <h2>Tạo tài khoản</h2>
                    <p class="sub">Đăng ký để bắt đầu sử dụng Spirit.</p>
                </div>
                <div class="auth-body">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">
                            <i class="bi bi-exclamation-triangle"></i> ${error}
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/register" novalidate class="spirit-auto-submit">
                        <div class="mb-3">
                            <label class="form-label">Username</label>
                            <input type="text" name="username" class="form-control" required minlength="3" maxlength="50" value="${param.username}" placeholder="3-50 ký tự, không dấu">
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Mật khẩu</label>
                                <input type="password" name="password" class="form-control" required minlength="6" placeholder="Tối thiểu 6 ký tự">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Xác nhận</label>
                                <input type="password" name="confirm" class="form-control" required minlength="6" placeholder="Nhập lại">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="fullName" class="form-control" required maxlength="100" value="${param.fullName}">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" required value="${param.email}" placeholder="example@fpt.edu.vn">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Vai trò</label>
                            <select name="role" id="roleSelect" class="form-select" required>
                                <option value="STUDENT" ${param.role == 'STUDENT' or empty param.role ? 'selected' : ''}>Student — sinh viên</option>
                                <option value="TEACHER" ${param.role == 'TEACHER' ? 'selected' : ''}>Teacher — giảng viên</option>
                            </select>
                        </div>
                        <div class="mb-4">
                            <label class="form-label" id="userCodeLabel">MSSV</label>
                            <input type="text" name="userCode" id="userCodeInput" class="form-control" required
                                   maxlength="8" value="${param.userCode}"
                                   placeholder="SE123456"
                                   pattern="(SE[0-9]{6}|GV[0-9]{4})"
                                   title="Sinh viên: SE + 6 chữ số (VD: SE123456). Giảng viên: GV + 4 chữ số (VD: GV0001).">
                            <small class="text-muted" id="userCodeHint">
                                <i class="bi bi-info-circle"></i> Sinh viên: SE + 6 chữ số (VD: SE123456)
                            </small>
                        </div>
                        <button class="btn btn-primary btn-lg w-100 spirit-loading">
                            <i class="bi bi-send"></i> Gửi mã OTP
                        </button>
                    </form>
                    <hr>
                    <div class="text-center">
                        <a href="${pageContext.request.contextPath}/login">Đã có tài khoản? <strong>Đăng nhập</strong></a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
(function () {
    var roleSelect = document.getElementById('roleSelect');
    var codeInput = document.getElementById('userCodeInput');
    var codeLabel = document.getElementById('userCodeLabel');
    var codeHint  = document.getElementById('userCodeHint');
    if (!roleSelect || !codeInput) return;

    function sync() {
        var isStudent = roleSelect.value === 'STUDENT';
        codeLabel.textContent = isStudent ? 'MSSV' : 'Mã thẻ giảng viên';
        codeInput.placeholder = isStudent ? 'SE123456' : 'GV0001';
        codeInput.setAttribute('pattern', isStudent ? 'SE[0-9]{6}' : 'GV[0-9]{4}');
        codeHint.innerHTML = isStudent
            ? '<i class="bi bi-info-circle"></i> Sinh viên: SE + 6 chữ số (VD: SE123456)'
            : '<i class="bi bi-info-circle"></i> Giảng viên: GV + 4 chữ số (VD: GV0001)';
    }
    roleSelect.addEventListener('change', sync);
    sync();
})();
</script>
</body>
</html>
