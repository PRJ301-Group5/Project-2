<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Chấm điểm" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="row">
    <div class="col-md-7">
        <div class="card shadow mb-3">
            <div class="card-header bg-white">
                <h5 class="mb-0"><i class="bi bi-person"></i> Bài nộp của ${submission.studentName}</h5>
                <p class="mb-0 small text-muted">Assignment: ${assignment.title}</p>
            </div>
            <div class="card-body">
                <h6>Nội dung:</h6>
                <pre class="bg-light p-3 rounded">${submission.content}</pre>
                <c:if test="${not empty submission.filePath}">
                    <h6>File:</h6>
                    <p><a href="${submission.filePath}" target="_blank">${submission.filePath}</a></p>
                </c:if>
            </div>
        </div>
    </div>

    <div class="col-md-5">
        <div class="card shadow">
            <div class="card-header bg-white">
                <h5 class="mb-0"><i class="bi bi-pencil-square"></i> Chấm điểm</h5>
            </div>
            <div class="card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>
                <form method="post" action="${pageContext.request.contextPath}/app/teacher/grading">
                    <input type="hidden" name="submissionId" value="${submission.submissionId}">
                    <div class="mb-3">
                        <label class="form-label">Điểm (0 - ${assignment.maxScore})</label>
                        <input type="number" name="score" class="form-control form-control-lg"
                               min="0" max="${assignment.maxScore}" step="0.5" required
                               value="${submission.score}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Feedback</label>
                        <textarea name="feedback" class="form-control" rows="4" maxlength="2000"
                                  placeholder="Nhận xét cho sinh viên...">${submission.feedback}</textarea>
                    </div>
                    <button class="btn btn-primary w-100">
                        <i class="bi bi-save"></i> Lưu điểm
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
