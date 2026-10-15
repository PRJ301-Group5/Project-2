<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${pageTitle}">Spirit - AI Grading</c:out></title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body class="bg-spirit">
<nav class="navbar navbar-dark bg-primary mb-0">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/app/dashboard">
            <i class="bi bi-mortarboard-fill"></i> Spirit · AI Grading
        </a>
        <c:if test="${not empty sessionScope.currentUser}">
            <div class="d-flex align-items-center text-white">
                <a class="text-white me-3" href="${pageContext.request.contextPath}/app/notifications"
                   title="Thông báo">
                    <i class="bi bi-bell-fill"></i>
                    <c:if test="${unreadCount > 0}">
                        <span class="badge bg-danger">${unreadCount}</span>
                    </c:if>
                </a>
                <span class="me-3">
                    <i class="bi bi-person-circle"></i>
                    <c:out value="${sessionScope.currentUser.fullName}"/>
                    <small class="text-white-50">(<c:out value="${sessionScope.currentUser.role}"/>)</small>
                </span>
                <a class="btn btn-sm btn-outline-light me-1" href="${pageContext.request.contextPath}/app/profile">
                    <i class="bi bi-gear"></i> Profile
                </a>
                <a class="btn btn-sm btn-light" href="${pageContext.request.contextPath}/logout">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </c:if>
    </div>
</nav>
<c:if test="${not empty sessionScope.currentUser}">
<nav class="navbar navbar-expand bg-light border-bottom">
    <div class="container-fluid">
        <ul class="navbar-nav me-auto">
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/app/dashboard">
                <i class="bi bi-house"></i> Dashboard</a></li>
            <c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/app/assignments">
                    <i class="bi bi-journal-text"></i> Quản lý bài tập</a></li>
            </c:if>
            <c:if test="${sessionScope.role == 'STUDENT'}">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/app/subjects">
                    <i class="bi bi-book"></i> Môn học</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/app/assignments">
                    <i class="bi bi-journal-text"></i> Bài tập của tôi</a></li>
            </c:if>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/app/notifications">
                <i class="bi bi-bell"></i> Thông báo</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/projects">
                <i class="bi bi-github"></i> Git Analytics</a></li>
        </ul>
    </div>
</nav>
</c:if>
<div class="container py-4">
    <c:if test="${not empty sessionScope.flash}">
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle"></i> ${sessionScope.flash}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="flash" scope="session"/>
    </c:if>
