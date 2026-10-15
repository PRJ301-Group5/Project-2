<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử Export CSV · Spirit</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body class="bg-spirit">
<nav class="navbar navbar-dark bg-primary mb-4">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/projects">
            🚀 Spirit · Group 5
        </a>
        <span class="navbar-text text-white">Lịch sử Export CSV</span>
    </div>
</nav>

<div class="container">
    <div class="card shadow">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
            <h4 class="mb-0">📁 Export History (50 mới nhất)</h4>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/projects">
                ← Quay lại Projects
            </a>
        </div>
        <div class="card-body">
            <table class="table table-sm table-hover align-middle">
                <thead class="table-light">
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
                        <td>${h.historyId}</td>
                        <td><span class="badge bg-primary">#${h.projectId}</span></td>
                        <td><code>${h.fileName}</code></td>
                        <td>${h.exportedBy}</td>
                        <td class="text-end">${h.rowCount}</td>
                        <td class="text-end">${h.fileBytes}</td>
                        <td><small>${h.exportedAt}</small></td>
                        <td class="text-center">
                            <a class="btn btn-sm btn-outline-primary"
                               href="${pageContext.request.contextPath}/exports?download=1&id=${h.historyId}">
                                ⬇ Download
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty history}">
                    <tr><td colspan="8" class="text-center text-muted py-4">
                        Chưa có lần export nào. Hãy bấm "Export CSV" ở trang Projects.
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
