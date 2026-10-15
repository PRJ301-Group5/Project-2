<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Hồ sơ cá nhân" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="row">
    <div class="col-md-6">
        <div class="card shadow mb-3">
            <div class="card-header bg-white"><h5 class="mb-0"><i class="bi bi-person"></i> Thông tin cá nhân</h5></div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/app/profile">
                    <input type="hidden" name="action" value="updateInfo">
                    <div class="mb-2">
                        <label class="form-label">Username</label>
                        <input type="text" class="form-control" value="${sessionScope.currentUser.username}" readonly>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" value="${sessionScope.currentUser.email}" readonly>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Họ tên</label>
                        <input type="text" name="fullName" class="form-control" required
                               value="${sessionScope.currentUser.fullName}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Số điện thoại</label>
                        <input type="tel" name="phone" class="form-control" maxlength="20"
                               value="${sessionScope.currentUser.phone}">
                    </div>
                    <button class="btn btn-primary"><i class="bi bi-save"></i> Cập nhật</button>
                </form>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card shadow">
            <div class="card-header bg-white"><h5 class="mb-0"><i class="bi bi-lock"></i> Đổi mật khẩu</h5></div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/app/profile">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="mb-2">
                        <label class="form-label">Mật khẩu cũ</label>
                        <input type="password" name="oldPassword" class="form-control" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Mật khẩu mới</label>
                        <input type="password" name="newPassword" class="form-control" required minlength="6">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Xác nhận mật khẩu mới</label>
                        <input type="password" name="confirm" class="form-control" required minlength="6">
                    </div>
                    <button class="btn btn-warning"><i class="bi bi-key"></i> Đổi mật khẩu</button>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
