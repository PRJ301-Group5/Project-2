<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Chấm điểm" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-pencil-square"></i></span>
            Chấm điểm bài nộp
        </h1>
        <p class="subtitle">${assignment.title} · Lớp <code>${assignment.classCode}</code></p>
    </div>
    <div class="actions">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/app/assignments/detail?id=${assignment.assignmentId}">
            <i class="bi bi-arrow-left"></i> Quay lại
        </a>
    </div>
</div>

<c:if test="${not empty error}">
    <div class="alert alert-danger fade-in">
        <i class="bi bi-exclamation-triangle"></i>
        <div>${error}</div>
    </div>
</c:if>

<div class="row g-3 fade-in">
    <div class="col-lg-7">
        <div class="card shadow-sm grade-card">
            <div class="card-header">
                <h5><i class="bi bi-person-circle"></i> Bài nộp của ${submission.studentName}</h5>
                <span class="pill pill-navy"><i class="bi bi-hash"></i> #${submission.submissionId}</span>
            </div>
            <div class="card-body">
                <h6 class="grade-section-title">Nội dung</h6>
                <pre>${submission.content}</pre>

                <c:if test="${not empty submission.filePath}">
                    <h6 class="grade-section-title mt-4">Tệp đính kèm</h6>
                    <a class="btn btn-outline-primary" href="${submission.filePath}" target="_blank" rel="noopener">
                        <i class="bi bi-link-45deg"></i> ${submission.filePath}
                    </a>
                </c:if>
            </div>
        </div>
    </div>

    <div class="col-lg-5">
        <div class="card shadow-sm grade-card">
            <div class="card-header">
                <h5><i class="bi bi-mortarboard"></i> Bảng điểm</h5>
            </div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/app/teacher/grading" class="spirit-auto-submit">
                    <input type="hidden" name="submissionId" value="${submission.submissionId}">

                    <div class="grade-score-box mb-3">
                        <div class="score">
                            <c:choose>
                                <c:when test="${not empty submission.score}">${submission.score}</c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                            <span class="score-max">/ ${assignment.maxScore}</span>
                        </div>
                        <div class="score-hint">Điểm tối đa của bài tập</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Điểm (0 - ${assignment.maxScore})</label>
                        <input type="number" name="score" class="form-control form-control-lg"
                               min="0" max="${assignment.maxScore}" step="0.5" required
                               value="${submission.score}" placeholder="0.0">
                    </div>

                    <div class="mb-4">
                        <label class="form-label">Feedback cho sinh viên</label>
                        <textarea name="feedback" class="form-control" rows="6" maxlength="2000"
                                  placeholder="Nhận xét chi tiết: ưu điểm, điểm cần cải thiện, gợi ý phát triển…">${submission.feedback}</textarea>
                        <small class="text-muted">Tối đa 2000 ký tự</small>
                    </div>

                    <div class="d-grid gap-2">
                        <button class="btn btn-primary btn-lg spirit-loading" type="submit">
                            <i class="bi bi-check2-circle"></i> Lưu điểm
                        </button>
                        <a class="btn btn-outline-orange" href="${pageContext.request.contextPath}/app/assignments/detail?id=${assignment.assignmentId}">
                            <i class="bi bi-x-lg"></i> Hủy
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
