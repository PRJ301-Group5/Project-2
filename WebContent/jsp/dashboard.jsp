<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Dashboard" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-grid-1x2"></i></span>
            <c:choose>
                <c:when test="${sessionScope.role == 'TEACHER'}">Lớp phụ trách</c:when>
                <c:when test="${sessionScope.role == 'STUDENT'}">Môn học của bạn</c:when>
                <c:otherwise>Tổng quan hệ thống</c:otherwise>
            </c:choose>
        </h1>
        <p class="subtitle">
            Chào <strong>${sessionScope.currentUser.fullName}</strong> 👋 ·
            <c:choose>
                <c:when test="${sessionScope.role == 'TEACHER'}">Quản lý lớp và chấm bài nhanh chóng.</c:when>
                <c:when test="${sessionScope.role == 'STUDENT'}">Theo dõi tiến độ và nộp bài đúng hạn.</c:when>
                <c:otherwise>Toàn quyền quản trị.</c:otherwise>
            </c:choose>
        </p>
    </div>
    <c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
        <div class="actions">
            <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/projects">
                <i class="bi bi-github"></i> Git Analytics
            </a>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/app/assignments">
                <i class="bi bi-plus-lg"></i> Tạo bài tập
            </a>
        </div>
    </c:if>
</div>

<div class="row g-3 fade-in fade-in-stagger">
    <div class="col-md-3 col-sm-6">
        <div class="stat-card">
            <span class="stat-icon"><i class="bi bi-collection"></i></span>
            <div class="stat-label">Lớp / Môn</div>
            <div class="stat-value">${empty classes ? 0 : classes.size()}</div>
            <div class="stat-trend up">
                <i class="bi bi-arrow-up-short"></i> đang hoạt động
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="stat-card">
            <span class="stat-icon orange"><i class="bi bi-journal-text"></i></span>
            <div class="stat-label">Bài tập</div>
            <div class="stat-value">${empty assignments ? 0 : assignments.size()}</div>
            <div class="stat-trend">
                <i class="bi bi-clock"></i> trong học kỳ
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="stat-card">
            <span class="stat-icon green"><i class="bi bi-check2-square"></i></span>
            <div class="stat-label">Bài nộp</div>
            <div class="stat-value">${empty assignments ? 0 : assignments.size()}</div>
            <div class="stat-trend up">
                <i class="bi bi-graph-up"></i> tổng cộng
            </div>
        </div>
    </div>
    <div class="col-md-3 col-sm-6">
        <div class="stat-card">
            <span class="stat-icon purple"><i class="bi bi-bell"></i></span>
            <div class="stat-label">Thông báo mới</div>
            <div class="stat-value">${empty unreadCount ? 0 : unreadCount}</div>
            <div class="stat-trend">
                <a href="${pageContext.request.contextPath}/app/notifications">Xem tất cả →</a>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 mt-1">
    <div class="col-lg-8">
        <div class="card shadow-sm fade-in">
            <div class="card-header">
                <h5><i class="bi bi-collection"></i>
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
                        <div class="empty-state">
                            <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                            <h6>Chưa có lớp nào</h6>
                            <p>Vui lòng liên hệ admin để được phân công lớp.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="row g-3 fade-in-stagger">
                            <c:forEach var="c" items="${classes}">
                                <div class="col-md-6">
                                    <div class="project-tile">
                                        <span class="tile-icon"><i class="bi bi-book"></i></span>
                                        <h6 class="tile-title">${c.subjectName}</h6>
                                        <span class="tile-code">${c.subjectCode}</span>
                                        <p class="tile-desc">
                                            <i class="bi bi-people"></i> ${c.className}<br>
                                            <i class="bi bi-person"></i> GV: ${c.teacherName}<br>
                                            <i class="bi bi-calendar3"></i> ${c.semester}
                                        </p>
                                        <div class="tile-actions">
                                            <a class="btn btn-sm btn-primary"
                                               href="${pageContext.request.contextPath}/app/assignments?classId=${c.classId}">
                                                <i class="bi bi-journal-text"></i> Bài tập
                                            </a>
                                            <a class="btn btn-sm btn-outline-primary"
                                               href="${pageContext.request.contextPath}/dashboard?projectId=${c.projectId}">
                                                <i class="bi bi-graph-up"></i> Analytics
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="card shadow-sm mt-3 fade-in">
            <div class="card-header">
                <h5><i class="bi bi-list-task"></i> Bài tập gần đây</h5>
                <c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
                    <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/app/assignments">
                        <i class="bi bi-plus-lg"></i> Tạo mới
                    </a>
                </c:if>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty assignments}">
                        <div class="empty-state">
                            <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                            <h6>Chưa có bài tập nào</h6>
                            <p>Hãy tạo bài tập mới để bắt đầu.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Tiêu đề</th>
                                        <th>Lớp</th>
                                        <th>Deadline</th>
                                        <th class="text-center">Submissions</th>
                                        <th class="text-end"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="a" items="${assignments}">
                                        <tr>
                                            <td>
                                                <div class="fw-semibold">${a.title}</div>
                                                <small class="text-muted">${a.description}</small>
                                            </td>
                                            <td><code>${a.classCode}</code></td>
                                            <td><fmt:formatDate value="${a.dueDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td class="text-center">
                                                <span class="pill pill-info">${a.submissionCount}</span>
                                            </td>
                                            <td class="text-end">
                                                <a class="btn btn-sm btn-outline-primary"
                                                   href="${pageContext.request.contextPath}/app/assignments/detail?id=${a.assignmentId}">
                                                    Xem <i class="bi bi-arrow-right"></i>
                                                </a>
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
    </div>

    <div class="col-lg-4">
        <div class="card shadow-sm fade-in">
            <div class="card-header">
                <h5><i class="bi bi-bell"></i> Thông báo</h5>
                <c:if test="${unreadCount > 0}">
                    <span class="pill pill-danger">${unreadCount} mới</span>
                </c:if>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty notifications}">
                        <div class="empty-state">
                            <div class="empty-icon"><i class="bi bi-bell-slash"></i></div>
                            <h6>Không có thông báo</h6>
                            <p>Mọi cập nhật sẽ hiển thị tại đây.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <ul class="list-group list-group-flush">
                            <c:forEach var="n" items="${notifications}">
                                <li class="list-group-item ${n.read ? '' : 'list-group-item-warning'}">
                                    <div class="d-flex gap-2">
                        <i class="bi bi-dot ${n.read ? 'text-muted' : 'text-warning'}"></i>
                                        <div class="flex-grow-1">
                                            <strong class="d-block">${n.title}</strong>
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
