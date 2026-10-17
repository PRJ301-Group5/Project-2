<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử Export CSV · Spirit</title>
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
                    <span class="brand-sub">Export history</span>
                </span>
            </a>
            <div class="d-flex align-items-center gap-2">
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
                <span class="icon-box"><i class="bi bi-cloud-download"></i></span>
                Lịch sử Export CSV
            </h1>
            <p class="subtitle">50 file CSV mới nhất đã được xuất — tải lại bất kỳ lúc nào.</p>
        </div>
        <div class="actions">
            <span class="pill pill-navy">${empty history ? 0 : history.size()} bản ghi</span>
        </div>
    </div>

    <div class="card shadow-sm fade-in">
        <div class="card-header">
            <h5><i class="bi bi-clock-history"></i> Tất cả lần export</h5>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${empty history}">
                    <div class="empty-state">
                        <div class="empty-icon"><i class="bi bi-cloud-slash"></i></div>
                        <h6>Chưa có lần export nào</h6>
                        <p>Hãy bấm <strong>Export CSV</strong> ở trang Projects để bắt đầu.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Project</th>
                                    <th>File name</th>
                                    <th>Exported by</th>
                                    <th class="text-end">Rows</th>
                                    <th class="text-end">Bytes</th>
                                    <th>Exported at</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="h" items="${history}">
                                    <tr>
                                        <td><span class="text-muted">#${h.historyId}</span></td>
                                        <td><span class="pill pill-navy">${h.projectId}</span></td>
                                        <td><code>${h.fileName}</code></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="spirit-avatar" style="width: 28px; height: 28px; font-size: 11px;">${h.exportedBy.substring(0,1).toUpperCase()}</span>
                                                <span>${h.exportedBy}</span>
                                            </div>
                                        </td>
                                        <td class="text-end fw-semibold">${h.rowCount}</td>
                                        <td class="text-end text-muted">${h.fileBytes}</td>
                                        <td><small>${h.exportedAt}</small></td>
                                        <td class="text-center">
                                            <a class="btn btn-sm btn-primary"
                                               href="${pageContext.request.contextPath}/exports?download=1&id=${h.historyId}">
                                                <i class="bi bi-download"></i> Download
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
