<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Hồ sơ cá nhân" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-person-circle"></i></span>
            Hồ sơ cá nhân
        </h1>
        <p class="subtitle">Quản lý thông tin tài khoản và mật khẩu.</p>
    </div>
</div>

<div class="row g-3 fade-in fade-in-stagger">
    <div class="col-lg-6">
        <div class="card shadow-sm">
            <div class="card-header">
                <h5><i class="bi bi-person"></i> Thông tin cá nhân</h5>
            </div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/app/profile" class="spirit-auto-submit">
                    <input type="hidden" name="action" value="updateInfo">
                    <div class="mb-3">
                        <label class="form-label">Username</label>
                        <input type="text" class="form-control" value="${sessionScope.currentUser.username}" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" value="${sessionScope.currentUser.email}" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Họ tên</label>
                        <input type="text" name="fullName" class="form-control" required
                               value="${sessionScope.currentUser.fullName}">
                    </div>
            <div class="mb-4">
                <label class="form-label">Số điện thoại</label>
                <input type="tel" name="phone" class="form-control" maxlength="20"
                       value="${sessionScope.currentUser.phone}" placeholder="VD: 0901 234 567">
            </div>
            <div class="mb-4">
                <label class="form-label">Lần đăng nhập gần nhất</label>
                <div class="form-control-plaintext">
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser.lastLogin}">
                            <i class="bi bi-clock-history"></i>
                            <fmt:formatDate value="${sessionScope.currentUser.lastLogin}" pattern="dd/MM/yyyy HH:mm:ss"/>
                        </c:when>
                        <c:otherwise>
                            <span class="text-muted">Chưa đăng nhập lần nào</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <button class="btn btn-primary spirit-loading" type="submit">
                <i class="bi bi-save"></i> Cập nhật thông tin
            </button>
            </form>
            <a class="btn btn-outline-secondary mt-2"
               href="${pageContext.request.contextPath}/app/login-history">
                <i class="bi bi-clock-history"></i> Xem lịch sử đăng nhập
            </a>
            </div>
        </div>
    </div>

    <div class="col-lg-6">
        <div class="card shadow-sm card-feature">
            <div class="card-header">
                <h5><i class="bi bi-lock"></i> Đổi mật khẩu</h5>
            </div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/app/profile" class="spirit-auto-submit">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu cũ</label>
                        <input type="password" name="oldPassword" class="form-control" required placeholder="Nhập mật khẩu hiện tại">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu mới</label>
                        <input type="password" name="newPassword" class="form-control" required minlength="6" placeholder="Tối thiểu 6 ký tự">
                    </div>
                    <div class="mb-4">
                        <label class="form-label">Xác nhận mật khẩu mới</label>
                        <input type="password" name="confirm" class="form-control" required minlength="6" placeholder="Nhập lại mật khẩu mới">
                    </div>
                    <button class="btn btn-orange spirit-loading" type="submit">
                        <i class="bi bi-key"></i> Đổi mật khẩu
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
