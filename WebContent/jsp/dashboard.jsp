<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Dashboard" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="row">
    <div class="col-md-8">
        <div class="card shadow mb-4">
            <div class="card-header bg-white">
                <h5 class="mb-0">
                    <i class="bi bi-collection"></i>
                    <c:choose>
                        <c:when test="${sessionScope.role == 'TEACHER'}">Lớp bạn phụ trách</c:when>
                        <c:when test="${sessionScope.role == 'STUDENT'}">Môn học của bạn</c:when>
                        <c:otherwise>Tất cả lớp</c:otherwise>
                    </c:choose>
                </h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty classes}">
                        <p class="text-muted text-center py-3">
                            <i class="bi bi-inbox"></i> Chưa có lớp nào.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <div class="row">
                            <c:forEach var="c" items="${classes}">
                                <div class="col-md-6 mb-3">
                                    <div class="border rounded p-3 h-100">
                                        <h6 class="mb-1">
                                            <i class="bi bi-book"></i>
                                            <code>${c.subjectCode}</code>
                                            <span class="text-muted">·</span>
                                            ${c.subjectName}
                                        </h6>
                                        <p class="mb-1 small">${c.className}</p>
                                        <p class="mb-2 small text-muted">
                                            GV: ${c.teacherName} · ${c.semester}
                                        </p>
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="${pageContext.request.contextPath}/app/assignments?classId=${c.classId}">
                                            <i class="bi bi-journal-text"></i> Bài tập
                                        </a>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="card shadow">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="bi bi-journal-text"></i> Bài tập</h5>
                <c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
                    <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/app/assignments">
                        <i class="bi bi-plus"></i> Tạo mới
                    </a>
                </c:if>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty assignments}">
                        <p class="text-muted text-center py-4">
                            <i class="bi bi-inbox"></i> Chưa có bài tập nào.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Tiêu đề</th>
                                    <th>Lớp</th>
                                    <th>Deadline</th>
                                    <th class="text-center">Submissions</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="a" items="${assignments}">
                                    <tr>
                                        <td>${a.title}</td>
                                        <td><code>${a.classCode}</code></td>
                                        <td>
                                            <fmt:formatDate value="${a.dueDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-info">${a.submissionCount}</span>
                                        </td>
                                        <td class="text-end">
                                            <a class="btn btn-sm btn-outline-primary"
                                               href="${pageContext.request.contextPath}/app/assignments/detail?id=${a.assignmentId}">
                                                Xem
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card shadow">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="bi bi-bell"></i> Thông báo</h5>
                <c:if test="${unreadCount > 0}">
                    <span class="badge bg-danger">${unreadCount} mới</span>
                </c:if>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty notifications}">
                        <p class="text-muted text-center py-3 m-0">
                            <i class="bi bi-bell-slash"></i> Không có thông báo.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <ul class="list-group list-group-flush">
                            <c:forEach var="n" items="${notifications}">
                                <li class="list-group-item ${n.read ? '' : 'list-group-item-warning'}">
                                    <div class="d-flex">
                                        <i class="bi bi-dot"></i>
                                        <div class="flex-grow-1">
                                            <strong>${n.title}</strong>
                                            <p class="mb-0 small text-muted">${n.body}</p>
                                        </div>
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
