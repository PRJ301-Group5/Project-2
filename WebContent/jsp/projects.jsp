<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh sách Project · Spirit</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css?v=2.0">
</head>
<body class="bg-spirit">
<header class="spirit-topbar">
    <div class="container">
        <div class="d-flex align-items-center justify-content-between gap-3">
            <a class="brand" href="${pageContext.request.contextPath}/projects">
                <span class="spirit-mark"><i class="bi bi-github"></i></span>
                <span>
                    Spirit · Git Analytics
                    <span class="brand-sub">Contribution tracking</span>
                </span>
            </a>
            <div class="d-flex align-items-center gap-2">
                <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/exports">
                    <i class="bi bi-cloud-download"></i> Export History
                </a>
                <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/app/dashboard">
                    <i class="bi bi-grid"></i> Dashboard
                </a>
            </div>
        </div>
    </div>
</header>

<div class="container py-4">
    <div class="page-head fade-in">
        <div>
            <h1 class="title">
                <span class="icon-box"><i class="bi bi-folder2-open"></i></span>
                Danh sách Project
            </h1>
            <p class="subtitle">Quản lý và phân tích contribution cho từng project Git.</p>
        </div>
        <div class="actions">
            <span class="pill pill-navy">${empty projects ? 0 : projects.size()} project</span>
        </div>
    </div>

    <div class="row g-3 fade-in-stagger">
        <c:forEach var="p" items="${projects}" varStatus="status">
            <div class="col-md-6 col-lg-4">
                <div class="project-tile">
                    <span class="tile-icon"><i class="bi bi-github"></i></span>
                    <h6 class="tile-title">${p.projectName}</h6>
                    <span class="tile-code">${p.projectCode}</span>
                    <p class="tile-desc">
                        <i class="bi bi-link-45deg"></i>
                        <a href="${p.repoUrl}" target="_blank" rel="noopener" class="text-truncate d-inline-block align-bottom" style="max-width: 220px;">
                            ${p.repoUrl}
                        </a>
                        <br>
                        <i class="bi bi-calendar3"></i>
                        <small>${p.startDate} → ${p.endDate}</small>
                    </p>
                    <div class="tile-actions">
                        <a class="btn btn-sm btn-primary"
                           href="${pageContext.request.contextPath}/dashboard?projectId=${p.projectId}">
                            <i class="bi bi-bar-chart"></i> Dashboard
                        </a>
                        <a class="btn btn-sm btn-outline-primary"
                           href="${pageContext.request.contextPath}/commits?projectId=${p.projectId}">
                            <i class="bi bi-list-ul"></i> Commits
                        </a>
                    </div>
                    <div class="d-flex gap-1 mt-2 flex-wrap">
                        <a class="btn btn-sm btn-outline-orange"
                           href="${pageContext.request.contextPath}/export.csv?projectId=${p.projectId}">
                            <i class="bi bi-download"></i> CSV
                        </a>
                        <form action="${pageContext.request.contextPath}/analyze" method="post" class="d-inline spirit-auto-submit">
                            <input type="hidden" name="projectId" value="${p.projectId}">
                            <button type="submit" class="btn btn-sm btn-orange spirit-loading"
                                    onclick="return confirm('Chạy phân tích contribution cho project này?');">
                                <i class="bi bi-play-circle"></i> Analyze
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </c:forEach>
        <c:if test="${empty projects}">
            <div class="col-12">
                <div class="empty-state">
                    <div class="empty-icon"><i class="bi bi-folder-x"></i></div>
                    <h6>Chưa có project nào</h6>
                    <p>Hãy import <code>database/bootstrap.sql</code> để có dữ liệu mẫu.</p>
                </div>
            </div>
        </c:if>
    </div>
</div>

<footer class="spirit-footer">
    <div>
        <strong>Spirit</strong> &copy; 2026 · Group 5 ·
        <a href="https://github.com/PRJ301-Group5/Project-2" target="_blank" rel="noopener">PRJ301 — Java Web Application</a>
    </div>
    <div class="mt-1">AI Grading + Git Contribution Analytics · Spirit v2.0</div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
