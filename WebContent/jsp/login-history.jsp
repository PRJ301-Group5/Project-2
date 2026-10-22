<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Lịch sử đăng nhập" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-clock-history"></i></span>
            Lịch sử đăng nhập
        </h1>
        <p class="subtitle">
            <c:choose>
                <c:when test="${isSelf}">
                    Lịch sử đăng nhập của tài khoản <strong>${sessionScope.currentUser.username}</strong>.
                </c:when>
                <c:otherwise>
                    Lịch sử đăng nhập của user <strong>#${targetUserId}</strong>.
                </c:otherwise>
            </c:choose>
        </p>
    </div>
    <div class="actions">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/app/profile">
            <i class="bi bi-person"></i> Hồ sơ
        </a>
    </div>
</div>

<div class="row g-3 mb-3 fade-in">
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-body">
                <div class="text-muted small mb-1"><i class="bi bi-list-ol"></i> Tổng số lần</div>
                <div class="h3 mb-0">${totalCount}</div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-body">
                <div class="text-muted small mb-1"><i class="bi bi-shield-exclamation"></i> Đăng nhập thất bại</div>
                <div class="h3 mb-0 ${failedCount > 0 ? 'text-danger' : ''}">${failedCount}</div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-body">
                <div class="text-muted small mb-1"><i class="bi bi-clock"></i> Đăng nhập gần nhất</div>
                <div class="h6 mb-0">
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser.lastLogin}">
                            <fmt:formatDate value="${sessionScope.currentUser.lastLogin}" pattern="dd/MM/yyyy HH:mm"/>
                        </c:when>
                        <c:otherwise>Chưa có</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card shadow-sm fade-in">
    <div class="card-header">
        <h5><i class="bi bi-person-clock"></i> Lịch sử của tôi</h5>
        <span class="pill pill-navy">${totalCount} bản ghi</span>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty history}">
                <div class="empty-state">
                    <div class="empty-icon"><i class="bi bi-clock-history"></i></div>
                    <h6>Chưa có lịch sử đăng nhập</h6>
                    <p>Các lần đăng nhập của bạn sẽ được ghi lại tại đây.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th style="width: 160px;">Thời gian</th>
                            <th style="width: 110px;">Trạng thái</th>
                            <th style="width: 150px;">IP Address</th>
                            <th>Thiết bị / Trình duyệt</th>
                            <th style="width: 200px;">Ghi chú</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="h" items="${history}">
                            <tr>
                                <td>
                                    <fmt:formatDate value="${h.loginAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${h.success}">
                                            <span class="pill pill-success"><i class="bi bi-check-circle-fill"></i> Thành công</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill pill-danger"><i class="bi bi-x-circle-fill"></i> Thất bại</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <code class="small">${h.ipLabel}</code>
                                </td>
                                <td>
                                    <span class="small text-muted">
                                        <i class="bi bi-laptop"></i> ${h.browserLabel}
                                    </span>
                                </td>
                                <td class="small text-muted">
                                    <c:if test="${not empty h.failureReason}">${h.failureReason}</c:if>
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

<c:if test="${not empty systemHistory}">
<div class="card shadow-sm mt-3 fade-in">
    <div class="card-header">
        <h5><i class="bi bi-globe2"></i> Toàn hệ thống (200 lần gần nhất)</h5>
        <span class="pill pill-orange">Audit</span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th style="width: 160px;">Thời gian</th>
                    <th style="width: 130px;">Username</th>
                    <th style="width: 110px;">Trạng thái</th>
                    <th style="width: 150px;">IP Address</th>
                    <th>Thiết bị / Trình duyệt</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="h" items="${systemHistory}">
                    <tr class="${h.userId == targetUserId ? 'table-warning' : ''}">
                        <td><fmt:formatDate value="${h.loginAt}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/app/login-history?userId=${h.userId}">
                                ${h.username}
                            </a>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${h.success}">
                                    <span class="pill pill-success">OK</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="pill pill-danger">Fail</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><code class="small">${h.ipLabel}</code></td>
                        <td class="small text-muted">${h.browserLabel}</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>
</c:if>

<jsp:include page="footer.jsp"/>
