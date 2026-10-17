<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Thông báo" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-bell"></i></span>
            Thông báo của tôi
        </h1>
        <p class="subtitle">Cập nhật mới nhất về lớp, bài tập và điểm số.</p>
    </div>
    <div class="actions">
        <form method="post" action="${pageContext.request.contextPath}/app/notifications" class="d-inline spirit-auto-submit">
            <input type="hidden" name="action" value="readAll">
            <button class="btn btn-outline-primary spirit-loading">
                <i class="bi bi-check2-all"></i> Đánh dấu tất cả đã đọc
            </button>
        </form>
    </div>
</div>

<div class="card shadow-sm fade-in">
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state">
                    <div class="empty-icon"><i class="bi bi-bell-slash"></i></div>
                    <h6>Không có thông báo nào</h6>
                    <p>Mọi cập nhật sẽ hiển thị tại đây.</p>
                </div>
            </c:when>
            <c:otherwise>
                <ul class="list-group list-group-flush">
                    <c:forEach var="n" items="${notifications}">
                        <li class="list-group-item ${n.read ? '' : 'list-group-item-warning'}">
                            <div class="d-flex gap-2">
                                <div class="spirit-avatar flex-shrink-0">
                                    <i class="bi bi-${n.read ? 'envelope-open' : 'envelope'}"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-start gap-2">
                                        <strong>${n.title}</strong>
                                        <c:if test="${!n.read}">
                                            <span class="pill pill-warning">Mới</span>
                                        </c:if>
                                    </div>
                                    <p class="mb-1 text-muted">${n.body}</p>
                                    <div class="d-flex gap-2 align-items-center">
                                        <c:if test="${not empty n.link}">
                                            <a href="${pageContext.request.contextPath}${n.link}" class="small">
                                                <i class="bi bi-arrow-right-circle"></i> Xem chi tiết
                                            </a>
                                        </c:if>
                                        <form method="post" action="${pageContext.request.contextPath}/app/notifications" class="d-inline">
                                            <input type="hidden" name="action" value="read">
                                            <input type="hidden" name="id" value="${n.notificationId}">
                                            <c:if test="${!n.read}">
                                                <button class="btn btn-sm btn-ghost" title="Đánh dấu đã đọc">
                                                    <i class="bi bi-check2"></i>
                                                </button>
                                            </c:if>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/app/notifications" class="d-inline"
                                              onsubmit="return confirm('Xoá thông báo này?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${n.notificationId}">
                                            <button class="btn btn-sm btn-ghost text-danger" title="Xoá">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="footer.jsp"/>
