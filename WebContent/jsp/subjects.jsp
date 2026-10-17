<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Môn học" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-book"></i></span>
            Môn học của bạn
        </h1>
        <p class="subtitle">Danh sách môn học đang theo học trong học kỳ này.</p>
    </div>
</div>

<div class="card shadow-sm fade-in">
    <div class="card-header">
        <h5><i class="bi bi-collection"></i> Tất cả môn học</h5>
        <span class="pill pill-muted">${empty subjects ? 0 : subjects.size()} môn</span>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty subjects}">
                <div class="empty-state">
                    <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                    <h6>Chưa có môn học nào</h6>
                    <p>Vui lòng liên hệ admin.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="row g-3 p-3 fade-in-stagger">
                    <c:forEach var="s" items="${subjects}">
                        <div class="col-md-6 col-lg-4">
                            <div class="project-tile">
                                <span class="tile-icon"><i class="bi bi-book-half"></i></span>
                                <h6 class="tile-title">${s.subjectName}</h6>
                                <span class="tile-code">${s.subjectCode}</span>
                                <p class="tile-desc">${s.description}</p>
                                <div class="tile-actions">
                                    <span class="pill pill-navy"><i class="bi bi-calendar3"></i> ${s.semester}</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="footer.jsp"/>
