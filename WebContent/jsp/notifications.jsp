<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Thông báo" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="card shadow">
    <div class="card-header bg-white d-flex justify-content-between align-items-center">
        <h5 class="mb-0"><i class="bi bi-bell"></i> Thông báo của tôi</h5>
        <form method="post" action="${pageContext.request.contextPath}/app/notifications" class="d-inline">
            <input type="hidden" name="action" value="readAll">
            <button class="btn btn-sm btn-outline-primary">Đánh dấu tất cả đã đọc</button>
        </form>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty notifications}">
                <p class="text-muted text-center py-4 m-0">
                    <i class="bi bi-bell-slash"></i> Không có thông báo nào.
                </p>
            </c:when>
            <c:otherwise>
                <ul class="list-group list-group-flush">
                    <c:forEach var="n" items="${notifications}">
                        <li class="list-group-item ${n.read ? '' : 'list-group-item-warning'}">
                            <div class="d-flex">
                                <div class="flex-grow-1">
                                    <strong>${n.title}</strong>
                                    <p class="mb-1">${n.body}</p>
                                    <c:if test="${not empty n.link}">
                                        <a href="${pageContext.request.contextPath}${n.link}" class="small">Xem chi tiết</a>
                                    </c:if>
                                </div>
                                <div class="text-end">
                                    <form method="post" action="${pageContext.request.contextPath}/app/notifications" class="d-inline">
                                        <input type="hidden" name="action" value="read">
                                        <input type="hidden" name="id" value="${n.notificationId}">
                                        <c:if test="${!n.read}">
                                            <button class="btn btn-sm btn-outline-success" title="Đã đọc">
                                                <i class="bi bi-check"></i>
                                            </button>
                                        </c:if>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/app/notifications" class="d-inline"
                                          onsubmit="return confirm('Xoá thông báo này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${n.notificationId}">
                                        <button class="btn btn-sm btn-outline-danger" title="Xoá">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
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
