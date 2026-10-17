<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Commits · ${project.projectName}</title>
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
                    <span class="brand-sub">Commit history</span>
                </span>
            </a>
            <div class="d-flex align-items-center gap-2">
                <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/exports">
                    <i class="bi bi-cloud-download"></i> Export History
                </a>
                <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/projects">
                    <i class="bi bi-folder2-open"></i> Projects
                </a>
            </div>
        </div>
    </div>
</header>

<div class="container py-4">
    <div class="page-head fade-in">
        <div>
            <h1 class="title">
                <span class="icon-box"><i class="bi bi-clock-history"></i></span>
                Commit History
            </h1>
            <p class="subtitle">
                <code>${project.projectCode}</code> · ${project.projectName}
            </p>
        </div>
        <div class="actions">
            <a class="btn btn-outline-primary"
               href="${pageContext.request.contextPath}/dashboard?projectId=${project.projectId}">
                <i class="bi bi-arrow-left"></i> Quay lại Dashboard
            </a>
            <a class="btn btn-orange"
               href="${pageContext.request.contextPath}/export.csv?projectId=${project.projectId}">
                <i class="bi bi-download"></i> Export CSV
            </a>
        </div>
    </div>

    <div class="card shadow-sm fade-in">
        <div class="card-header">
            <h5><i class="bi bi-list-ul"></i> Tất cả commits</h5>
            <span class="pill pill-muted">${empty commits ? 0 : commits.size()} commit</span>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${empty commits}">
                    <div class="empty-state">
                        <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                        <h6>Chưa có commit nào được phân tích</h6>
                        <p>Hãy chạy <strong>Analyze</strong> ở trang Projects.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Hash</th>
                                    <th>Ngày</th>
                                    <th>Tác giả</th>
                                    <th>Message</th>
                                    <th class="text-end">Files</th>
                                    <th class="text-end">+Lines</th>
                                    <th class="text-end">-Lines</th>
                                    <th class="text-center">Member</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${commits}">
                                    <tr>
                                        <td><code>${c.commitHash.substring(0,7)}</code></td>
                                        <td><small class="text-muted">${c.commitDate}</small></td>
                                        <td>
                                            <div class="fw-semibold">${c.authorName}</div>
                                            <small class="text-muted">${c.authorEmail}</small>
                                        </td>
                                        <td><small>${c.message}</small></td>
                                        <td class="text-end fw-semibold">${c.filesChanged}</td>
                                        <td class="text-end text-success fw-semibold">+${c.linesAdded}</td>
                                        <td class="text-end text-danger fw-semibold">-${c.linesDeleted}</td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${c.teamMemberId != null}">
                                                    <span class="pill pill-success" title="Đã map"><i class="bi bi-check2"></i> Mapped</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pill pill-warning" title="Chưa map">Unknown</span>
                                                </c:otherwise>
                                            </c:choose>
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
