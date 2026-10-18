<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Vào lớp" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-key"></i></span>
            Vào lớp bằng mã
        </h1>
        <p class="subtitle">Nhập mã lớp do giảng viên cung cấp để tham gia lớp học.</p>
    </div>
</div>

<div class="row g-3">
    <div class="col-lg-6">
        <div class="card shadow-sm fade-in card-feature">
            <div class="card-header">
                <h5><i class="bi bi-search"></i> Tra cứu mã lớp</h5>
            </div>
            <div class="card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-triangle"></i> ${error}
                    </div>
                </c:if>
                <c:if test="${not empty info}">
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle"></i> ${info}
                    </div>
                </c:if>

                <form method="get" action="${pageContext.request.contextPath}/app/enroll">
                    <input type="hidden" name="action" value="search">
                    <div class="mb-3">
                        <label class="form-label">Mã lớp</label>
                        <input type="text" name="code" class="form-control form-control-lg"
                               style="letter-spacing: 0.1em; font-family: 'JetBrains Mono', monospace; font-weight: 600;"
                               placeholder="VD: PRJ301_G5_S2026" required
                               value="${param.code}" autofocus>
                        <small class="text-muted">Mã lớp do giảng viên cung cấp. Không phân biệt hoa thường.</small>
                    </div>
                    <button class="btn btn-primary btn-lg spirit-loading" type="submit">
                        <i class="bi bi-search"></i> Tra cứu
                    </button>
                </form>
            </div>
        </div>
    </div>

    <div class="col-lg-6">
        <c:if test="${not empty classRoom}">
            <div class="card shadow-sm fade-in">
                <div class="card-header">
                    <h5><i class="bi bi-collection"></i> Thông tin lớp</h5>
                </div>
                <div class="card-body">
                    <h3 class="mb-1">${classRoom.subjectName}</h3>
                    <p class="mb-2">
                        <code style="font-size: 1rem; padding: 4px 10px;">${classRoom.classCode}</code>
                        <span class="pill pill-info ms-2">${classRoom.semester}</span>
                    </p>
                    <p class="mb-2"><strong>Tên lớp:</strong> ${classRoom.className}</p>
                    <p class="mb-2"><strong>Giảng viên:</strong> ${classRoom.teacherName}</p>
                    <c:if test="${not empty classRoom.description}">
                        <p class="mb-3 text-muted">${classRoom.description}</p>
                    </c:if>
                    <p class="mb-3">
                        <strong>Sĩ số hiện tại:</strong>
                        <span class="pill pill-navy">${classRoom.studentCount} sinh viên</span>
                    </p>

                    <form method="post" action="${pageContext.request.contextPath}/app/enroll" class="spirit-auto-submit">
                        <input type="hidden" name="action" value="join">
                        <input type="hidden" name="classId" value="${classRoom.classId}">
                        <button class="btn btn-primary btn-lg spirit-loading" type="submit">
                            <i class="bi bi-box-arrow-in-right"></i> Tham gia lớp này
                        </button>
                    </form>
                </div>
            </div>
        </c:if>

        <c:if test="${empty classRoom and empty error and empty info}">
            <div class="card shadow-sm fade-in">
                <div class="card-body">
                    <div class="empty-state">
                        <div class="empty-icon"><i class="bi bi-question-circle"></i></div>
                        <h6>Chưa tra cứu</h6>
                        <p>Nhập mã lớp ở form bên trái để xem thông tin chi tiết.</p>
                    </div>
                </div>
            </div>
        </c:if>
    </div>
</div>

<div class="card shadow-sm fade-in mt-3">
    <div class="card-header">
        <h5><i class="bi bi-info-circle"></i> Hướng dẫn</h5>
    </div>
    <div class="card-body">
        <ol class="mb-0">
            <li>Nhận mã lớp từ giảng viên (thường có dạng <code>MA_MON_NHOM_HOCKY</code>).</li>
            <li>Nhập mã vào ô bên trái, bấm <strong>Tra cứu</strong>.</li>
            <li>Kiểm tra thông tin lớp (môn học, giảng viên, mô tả).</li>
            <li>Bấm <strong>Tham gia lớp này</strong> để hoàn tất. Lớp sẽ xuất hiện trong Dashboard của bạn.</li>
        </ol>
    </div>
</div>

<jsp:include page="footer.jsp"/>
