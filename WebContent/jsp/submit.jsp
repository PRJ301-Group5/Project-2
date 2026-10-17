<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Nộp bài" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-cloud-upload"></i></span>
            Nộp bài: ${assignment.title}
        </h1>
        <p class="subtitle">
            <i class="bi bi-calendar-event"></i> Deadline
            <fmt:formatDate value="${assignment.dueDate}" pattern="dd/MM/yyyy HH:mm"/>
        </p>
    </div>
    <div class="actions">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/app/assignments/detail?id=${assignment.assignmentId}">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>
</div>

<div class="card shadow-sm fade-in card-feature">
    <div class="card-header">
        <h5><i class="bi bi-pencil-square"></i> Thông tin bài nộp</h5>
    </div>
    <div class="card-body">
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-triangle"></i> ${error}
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/app/submissions" class="spirit-auto-submit">
            <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
            <div class="mb-3">
                <label class="form-label">Nội dung bài làm</label>
                <textarea name="content" class="form-control" rows="8" maxlength="10000"
                          placeholder="Dán link GitHub repo, gist hoặc nội dung bài làm của bạn…">${submission.content}</textarea>
                <small class="text-muted">Tối đa 10,000 ký tự</small>
            </div>
            <div class="mb-4">
                <label class="form-label">Hoặc đường dẫn file (tùy chọn)</label>
                <input type="text" name="filePath" class="form-control" maxlength="500"
                       value="${submission.filePath}" placeholder="https://github.com/… hoặc đường dẫn file">
            </div>
            <div class="d-flex gap-2">
                <button class="btn btn-primary spirit-loading" type="submit">
                    <i class="bi bi-check2"></i> Lưu bài nộp
                </button>
                <a class="btn btn-outline-secondary"
                   href="${pageContext.request.contextPath}/app/assignments/detail?id=${assignment.assignmentId}">
                    <i class="bi bi-x-lg"></i> Huỷ
                </a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp"/>
