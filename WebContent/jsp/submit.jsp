<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Nộp bài" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="card shadow">
    <div class="card-header bg-white">
        <h4 class="mb-0"><i class="bi bi-upload"></i> Nộp bài: ${assignment.title}</h4>
        <p class="mb-0 small text-muted">
            Deadline: <fmt:formatDate value="${assignment.dueDate}" pattern="dd/MM/yyyy HH:mm"/>
        </p>
    </div>
    <div class="card-body">
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/app/submissions">
            <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
            <div class="mb-3">
                <label class="form-label">Nội dung bài làm</label>
                <textarea name="content" class="form-control" rows="6" maxlength="10000"
                          placeholder="Dán link GitHub hoặc nội dung bài làm...">${submission.content}</textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Hoặc đường dẫn file</label>
                <input type="text" name="filePath" class="form-control" maxlength="500"
                       value="${submission.filePath}" placeholder="https://github.com/... hoặc đường dẫn file">
            </div>
            <button class="btn btn-primary">
                <i class="bi bi-check"></i> Lưu bài nộp
            </button>
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/app/assignments/detail?id=${assignment.assignmentId}">
                Huỷ
            </a>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp"/>
