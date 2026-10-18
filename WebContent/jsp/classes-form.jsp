<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="${mode == 'edit' ? 'Sửa lớp' : 'Tạo lớp'}" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-${mode == 'edit' ? 'pencil-square' : 'plus-circle'}"></i></span>
            ${mode == 'edit' ? 'Sửa lớp' : 'Tạo lớp mới'}
        </h1>
        <p class="subtitle">
            <c:choose>
                <c:when test="${mode == 'edit'}">Cập nhật thông tin lớp học.</c:when>
                <c:otherwise>Đặt mã lớp để sinh viên tự tham gia. Mã lớp là duy nhất và không thể trùng.</c:otherwise>
            </c:choose>
        </p>
    </div>
    <div class="actions">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/app/classes">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>
</div>

<c:if test="${not empty error}">
    <div class="alert alert-danger fade-in">
        <i class="bi bi-exclamation-triangle"></i> ${error}
    </div>
</c:if>

<div class="card shadow-sm fade-in card-feature">
    <div class="card-header">
        <h5><i class="bi bi-info-circle"></i> Thông tin lớp</h5>
    </div>
    <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/app/classes" class="spirit-auto-submit">
            <input type="hidden" name="action" value="${mode == 'edit' ? 'update' : 'create'}">
            <c:if test="${mode == 'edit'}">
                <input type="hidden" name="id" value="${classRoom.classId}">
            </c:if>

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Mã lớp <span class="text-danger">*</span></label>
                    <input type="text" name="classCode" class="form-control" required minlength="3" maxlength="20"
                           pattern="[A-Za-z0-9_-]{3,20}" placeholder="VD: PRJ301_G6_S2026"
                           value="${classRoom.classCode}">
                    <small class="text-muted">3-20 ký tự: A-Z, 0-9, _, -. Sinh viên nhập mã này để vào lớp.</small>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Môn học <span class="text-danger">*</span></label>
                    <select name="subjectId" class="form-select" required>
                        <option value="">-- Chọn môn --</option>
                        <c:forEach var="s" items="${subjects}">
                            <option value="${s.subjectId}" ${classRoom.subjectId == s.subjectId ? 'selected' : ''}>
                                ${s.subjectCode} — ${s.subjectName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-8">
                    <label class="form-label">Tên lớp</label>
                    <input type="text" name="className" class="form-control" maxlength="100"
                           placeholder="VD: PRJ301 - Group 5 - Fall2026"
                           value="${classRoom.className}">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Học kỳ</label>
                    <input type="text" name="semester" class="form-control" maxlength="20" placeholder="VD: Fall2026"
                           value="${classRoom.semester}">
                </div>

                <div class="col-12">
                    <label class="form-label">Mô tả</label>
                    <textarea name="description" class="form-control" rows="2" maxlength="500"
                              placeholder="Mô tả ngắn cho lớp học...">${classRoom.description}</textarea>
                </div>

                <div class="col-12">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="joinEnabled" id="joinEnabled"
                               ${empty classRoom || classRoom.joinEnabled ? 'checked' : ''}>
                        <label class="form-check-label" for="joinEnabled">
                            <strong>Cho phép sinh viên tự vào lớp bằng mã lớp</strong>
                            <small class="d-block text-muted">Nếu tắt, chỉ giảng viên mới thêm được sinh viên vào lớp.</small>
                        </label>
                    </div>
                </div>
            </div>

            <hr class="my-4">

            <div class="d-flex gap-2">
                <button class="btn btn-primary spirit-loading" type="submit">
                    <i class="bi bi-check2-circle"></i>
                    ${mode == 'edit' ? 'Cập nhật' : 'Tạo lớp'}
                </button>
                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/app/classes">
                    <i class="bi bi-x-lg"></i> Huỷ
                </a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp"/>
