<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title><c:out value="${pageTitle}">Spirit — Git Analytics</c:out></title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css?v=2.0">
</head>
<body class="bg-spirit">
<c:if test="${not empty sessionScope.currentUser}">
<header class="spirit-topbar">
    <div class="container">
        <div class="d-flex align-items-center justify-content-between gap-3">
            <a class="brand" href="${pageContext.request.contextPath}/app/dashboard">
                <span class="spirit-mark"><i class="bi bi-mortarboard-fill"></i></span>
                <span>
                    Spirit
                    <span class="brand-sub">Git Analytics · Group 5</span>
                </span>
            </a>

            <div class="d-flex align-items-center gap-2">
                <a class="spirit-bell" href="${pageContext.request.contextPath}/app/notifications" title="Thông báo">
                    <i class="bi bi-bell"></i>
                    <c:if test="${unreadCount > 0}">
                        <span class="dot"></span>
                    </c:if>
                </a>

                <c:set var="u" value="${sessionScope.currentUser}" />
                <c:set var="initials" value="${fn:toUpperCase(fn:substring(u.fullName, 0, 1))}" />
                <c:if test="${fn:length(u.fullName) > 4}">
                    <c:set var="initials" value="${fn:toUpperCase(fn:substring(u.fullName, 0, 1))}${fn:toUpperCase(fn:substring(u.fullName, fn:indexOf(u.fullName, ' ') + 1, fn:indexOf(u.fullName, ' ') + 2))}" />
                </c:if>
                <span class="user-chip d-none d-md-inline-flex">
                    <span class="spirit-avatar">${initials}</span>
                    <span class="d-none d-lg-inline">${u.fullName}</span>
                    <c:if test="${not empty u.userCode}">
                        <code class="user-code" title="Mã định danh tài khoản">${u.userCode}</code>
                    </c:if>
                    <span class="role-pill role-${fn:toLowerCase(u.role)}">${u.role}</span>
                </span>

                <a class="btn btn-sm btn-ghost" href="${pageContext.request.contextPath}/app/profile" title="Hồ sơ">
                    <i class="bi bi-gear"></i>
                </a>
                <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/logout" title="Đăng xuất">
                    <i class="bi bi-box-arrow-right"></i>
                </a>
            </div>
        </div>
    </div>
</header>

<nav class="spirit-subnav">
    <div class="container">
        <div class="d-flex align-items-center gap-1 flex-wrap">
            <a class="nav-pill" href="${pageContext.request.contextPath}/app/dashboard">
                <i class="bi bi-house"></i> Dashboard
            </a>

            <c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
                <a class="nav-pill" href="${pageContext.request.contextPath}/app/classes">
                    <i class="bi bi-collection"></i> Lớp học
                </a>
                <a class="nav-pill" href="${pageContext.request.contextPath}/app/assignments">
                    <i class="bi bi-journal-text"></i> Quản lý bài tập
                </a>
            </c:if>

            <c:if test="${sessionScope.role == 'STUDENT'}">
                <a class="nav-pill" href="${pageContext.request.contextPath}/app/enroll">
                    <i class="bi bi-key"></i> Vào lớp bằng mã
                </a>
                <a class="nav-pill" href="${pageContext.request.contextPath}/app/subjects">
                    <i class="bi bi-book"></i> Môn học
                </a>
                <a class="nav-pill" href="${pageContext.request.contextPath}/app/assignments">
                    <i class="bi bi-journal-text"></i> Bài tập của tôi
                </a>
            </c:if>

            <span class="nav-divider"></span>
            <a class="nav-pill" href="${pageContext.request.contextPath}/projects">
                <i class="bi bi-github"></i> Git Analytics
            </a>
            <a class="nav-pill" href="${pageContext.request.contextPath}/exports">
                <i class="bi bi-cloud-download"></i> Export History
            </a>
            <a class="nav-pill" href="${pageContext.request.contextPath}/app/login-history">
                <i class="bi bi-clock-history"></i> Lịch sử đăng nhập
            </a>
            <a class="nav-pill" href="${pageContext.request.contextPath}/app/notifications">
                <i class="bi bi-bell"></i> Thông báo
            </a>
        </div>
    </div>
</nav>
</c:if>

<div class="container py-4">
    <c:if test="${not empty sessionScope.flash}">
        <div class="alert alert-success alert-dismissible fade show fade-in" role="alert">
            <i class="bi bi-check-circle"></i>
            <div class="flex-grow-1">${sessionScope.flash}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="flash" scope="session"/>
    </c:if>
