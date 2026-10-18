<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Quản lý lớp" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-collection"></i></span>
            <c:choose>
                <c:when test="${sessionScope.role == 'ADMIN'}">Tất cả lớp học</c:when>
                <c:otherwise>Lớp bạn phụ trách</c:otherwise>
            </c:choose>
        </h1>
        <p class="subtitle">Tạo lớp, chia sẻ mã lớp cho sinh viên, quản lý thành viên và bài tập.</p>
    </div>
    <div class="actions">
        <a class="btn btn-primary spirit-loading" href="${pageContext.request.contextPath}/app/classes?action=create">
            <i class="bi bi-plus-lg"></i> Tạo lớp mới
        </a>
    </div>
</div>

<div class="card shadow-sm fade-in">
    <div class="card-header">
        <h5><i class="bi bi-collection"></i> Danh sách lớp</h5>
        <span class="pill pill-muted">${empty classes ? 0 : classes.size()} lớp</span>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty classes}">
                <div class="empty-state">
                    <div class="empty-icon"><i class="bi bi-collection"></i></div>
                    <h6>Chưa có lớp nào</h6>
                    <p>Bấm <strong>Tạo lớp mới</strong> ở trên để bắt đầu.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>Mã lớp</th>
                                <th>Tên lớp</th>
                                <th>Môn học</th>
                                <th>Học kỳ</th>
                                <th class="text-center">SV</th>
                                <th class="text-center">Trạng thái</th>
                                <th class="text-end"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${classes}">
                                <tr>
                                    <td>
                                        <code style="font-size: 0.95rem; padding: 4px 10px;">${c.classCode}</code>
                                    </td>
                                    <td>
                                        <div class="fw-semibold">${c.className}</div>
                                        <small class="text-muted">${c.description}</small>
                                    </td>
                                    <td>
                                        <div>${c.subjectName}</div>
                                        <small class="text-muted"><code>${c.subjectCode}</code></small>
                                    </td>
                                    <td><span class="pill pill-info">${c.semester}</span></td>
                                    <td class="text-center">
                                        <span class="pill pill-navy">${c.studentCount}</span>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${c.joinEnabled}">
                                                <span class="pill pill-success"><i class="bi bi-check2"></i> Mở</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="pill pill-warning"><i class="bi bi-lock"></i> Khoá</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="${pageContext.request.contextPath}/app/classes?action=manage&id=${c.classId}">
                                            <i class="bi bi-people"></i> SV
                                        </a>
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="${pageContext.request.contextPath}/app/classes?action=edit&id=${c.classId}">
                                            <i class="bi bi-pencil"></i> Sửa
                                        </a>
                                        <a class="btn btn-sm btn-outline-orange"
                                           href="${pageContext.request.contextPath}/app/assignments?classId=${c.classId}">
                                            <i class="bi bi-journal-text"></i> BT
                                        </a>
                                        <form action="${pageContext.request.contextPath}/app/classes" method="post" class="d-inline"
                                              onsubmit="return confirm('Xoá lớp ${c.classCode}? Mọi bài tập & bài nộp sẽ bị xoá.');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${c.classId}">
                                            <button class="btn btn-sm btn-ghost text-danger" title="Xoá">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="footer.jsp"/>
