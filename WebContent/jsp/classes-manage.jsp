<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Quản lý sinh viên" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-people"></i></span>
            Sinh viên lớp ${classRoom.classCode}
        </h1>
        <p class="subtitle">
            ${classRoom.className} ·
            Môn <code>${classRoom.subjectCode}</code> —
            <strong>${classRoom.subjectName}</strong> ·
            Học kỳ <span class="pill pill-info">${classRoom.semester}</span>
        </p>
        <c:if test="${classRoom.joinEnabled}">
            <div class="alert alert-info mt-2 mb-0">
                <i class="bi bi-info-circle"></i>
                Sinh viên có thể tự vào lớp bằng cách vào
                <strong>Dashboard → "Vào lớp bằng mã"</strong> và nhập mã
                <code class="fs-6">${classRoom.classCode}</code>
            </div>
        </c:if>
    </div>
    <div class="actions">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/app/classes">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>
</div>

<div class="row g-3">
    <div class="col-lg-4">
        <div class="card shadow-sm fade-in">
            <div class="card-header">
                <h5><i class="bi bi-info-circle"></i> Thông tin lớp</h5>
            </div>
            <div class="card-body">
                <p class="mb-1"><strong>Mã lớp:</strong> <code style="font-size: 0.95rem; padding: 4px 10px;">${classRoom.classCode}</code></p>
                <p class="mb-1"><strong>GV phụ trách:</strong> ${classRoom.teacherName}</p>
                <p class="mb-1"><strong>Học kỳ:</strong> ${classRoom.semester}</p>
                <p class="mb-1"><strong>Cho phép SV tự vào:</strong>
                    <c:choose>
                        <c:when test="${classRoom.joinEnabled}"><span class="pill pill-success">Bật</span></c:when>
                        <c:otherwise><span class="pill pill-warning">Tắt</span></c:otherwise>
                    </c:choose>
                </p>
                <p class="mb-0"><strong>Sĩ số:</strong> <span class="pill pill-navy">${empty students ? 0 : students.size()}</span></p>
                <hr>
                <a class="btn btn-sm btn-primary w-100" href="${pageContext.request.contextPath}/app/assignments?classId=${classRoom.classId}">
                    <i class="bi bi-journal-text"></i> Bài tập của lớp
                </a>
            </div>
        </div>
    </div>

    <div class="col-lg-8">
        <div class="card shadow-sm fade-in">
            <div class="card-header">
                <h5><i class="bi bi-people"></i> Sinh viên đã tham gia</h5>
                <span class="pill pill-muted">${empty students ? 0 : students.size()} SV</span>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty students}">
                        <div class="empty-state">
                            <div class="empty-icon"><i class="bi bi-people"></i></div>
                            <h6>Chưa có sinh viên nào</h6>
                            <p>Sinh viên có thể tự vào lớp bằng mã <code>${classRoom.classCode}</code>.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <ul class="list-group list-group-flush">
                            <c:forEach var="s" items="${students}">
                                <li class="list-group-item">
                                    <div class="d-flex align-items-center gap-2">
                                        <c:set var="initials" value="${fn:toUpperCase(fn:substring(s.fullName, 0, 1))}" />
                                        <c:if test="${fn:length(s.fullName) > 4}">
                                            <c:set var="initials" value="${fn:toUpperCase(fn:substring(s.fullName, 0, 1))}${fn:toUpperCase(fn:substring(s.fullName, fn:indexOf(s.fullName, ' ') + 1, fn:indexOf(s.fullName, ' ') + 2))}" />
                                        </c:if>
                                        <span class="spirit-avatar" style="width:36px;height:36px;font-size:13px;">${initials}</span>
                                        <div class="flex-grow-1">
                                            <div class="fw-semibold">${s.fullName}</div>
                                            <small class="text-muted">@${s.username} · ${s.email}</small>
                                        </div>
                                        <span class="pill pill-success"><i class="bi bi-check2"></i> Đã tham gia</span>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
