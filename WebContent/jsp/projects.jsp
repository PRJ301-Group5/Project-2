<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh sách Project · Spirit</title>
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
        <a class="btn btn-sm btn-outline-light" href="${pageContext.request.contextPath}/exports">
            📁 Export History
        </a>
    </div>
</nav>

<div class="container">
    <div class="card shadow">
        <div class="card-header bg-white">
            <h3 class="mb-0">Danh sách Project</h3>
        </div>
        <div class="card-body">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                <tr>
                    <th>#</th>
                    <th>Code</th>
                    <th>Tên Project</th>
                    <th>Repo</th>
                    <th>Thời gian</th>
                    <th class="text-center">Hành động</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="p" items="${projects}" varStatus="status">
                    <tr>
                        <td>${status.count}</td>
                        <td><code>${p.projectCode}</code></td>
                        <td>${p.projectName}</td>
                        <td><a href="${p.repoUrl}" target="_blank" rel="noopener">${p.repoUrl}</a></td>
                        <td>
                            <small class="text-muted">
                                ${p.startDate} → ${p.endDate}
                            </small>
                        </td>
                        <td class="text-center">
                            <a href="${pageContext.request.contextPath}/dashboard?projectId=${p.projectId}"
                               class="btn btn-sm btn-primary">📊 Dashboard</a>
                            <a href="${pageContext.request.contextPath}/commits?projectId=${p.projectId}"
                               class="btn btn-sm btn-outline-secondary">📝 Commits</a>
                            <a href="${pageContext.request.contextPath}/export.csv?projectId=${p.projectId}"
                               class="btn btn-sm btn-outline-info">📥 Export CSV</a>
                            <form action="${pageContext.request.contextPath}/analyze"
                                  method="post" style="display:inline">
                                <input type="hidden" name="projectId" value="${p.projectId}">
                                <button type="submit" class="btn btn-sm btn-success"
                                        onclick="return confirm('Chạy analyze cho project này?')">
                                    ⚙ Analyze
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty projects}">
                    <tr><td colspan="6" class="text-center text-muted py-4">
                        Chưa có project nào. Hãy import schema.sql trong <code>/database</code>.
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
