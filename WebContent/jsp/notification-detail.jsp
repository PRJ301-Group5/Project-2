<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="${notification.title}" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-bell-fill"></i></span>
            Thông báo
        </h1>
        <p class="subtitle">Chi tiết thông báo của bạn</p>
    </div>
    <div class="actions">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/app/notifications">
            <i class="bi bi-arrow-left"></i> Quay lại danh sách
        </a>
    </div>
</div>

<div class="card shadow-sm fade-in">
    <div class="card-body">
        <c:choose>
            <c:when test="${empty notification}">
                <div class="empty-state">
                    <div class="empty-icon"><i class="bi bi-question-circle"></i></div>
                    <h6>Không tìm thấy thông báo</h6>
                    <p>Thông báo này có thể đã bị xoá hoặc không thuộc về bạn.</p>
                    <a class="btn btn-primary mt-2" href="${pageContext.request.contextPath}/app/notifications">
                        <i class="bi bi-list"></i> Xem tất cả thông báo
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <h4 class="mb-2">
                    <i class="bi bi-${notification.read ? 'envelope-open' : 'envelope-fill text-warning'}"></i>
                    ${notification.title}
                </h4>
                <p class="text-muted small mb-3">
                    <i class="bi bi-clock"></i>
                    <fmt:formatDate value="${notification.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    <c:if test="${!notification.read}">
                        <span class="pill pill-warning ms-2">Mới</span>
                    </c:if>
                </p>
                <hr>
                <p style="white-space: pre-wrap; line-height: 1.7;">${notification.body}</p>

                <c:if test="${not empty notification.link}">
                    <hr>
                    <a class="btn btn-primary spirit-loading" href="${pageContext.request.contextPath}${notification.link}">
                        <i class="bi bi-arrow-right-circle"></i> Mở nội dung liên quan
                    </a>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="footer.jsp"/>
