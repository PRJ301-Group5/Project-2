<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Commits · ${project.projectName}</title>
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
        <span class="navbar-text text-white">Commits · ${project.projectName}</span>
    </div>
</nav>

<div class="container">
    <div class="card shadow">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
            <h4 class="mb-0">📜 Commit History</h4>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/dashboard?projectId=${project.projectId}">
                ← Quay lại Dashboard
            </a>
        </div>
        <div class="card-body">
            <table class="table table-sm table-hover">
                <thead class="table-light">
                <tr>
                    <th>Hash</th>
                    <th>Date</th>
                    <th>Author</th>
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
                        <td><small>${c.commitDate}</small></td>
                        <td>${c.authorName}<br><small class="text-muted">${c.authorEmail}</small></td>
                        <td><small>${c.message}</small></td>
                        <td class="text-end">${c.filesChanged}</td>
                        <td class="text-end text-success">+${c.linesAdded}</td>
                        <td class="text-end text-danger">-${c.linesDeleted}</td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${c.teamMemberId != null}">
                                    <span class="badge bg-success">✓</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-warning text-dark">?</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty commits}">
                    <tr><td colspan="8" class="text-center text-muted py-4">
                        Chưa có commit nào được analyze.
                    </td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
