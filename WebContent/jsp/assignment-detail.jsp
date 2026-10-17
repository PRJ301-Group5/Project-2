<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="${assignment.title}" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-journal-bookmark"></i></span>
            ${assignment.title}
        </h1>
        <p class="subtitle">
            <i class="bi bi-people"></i> Lớp <code>${assignment.classCode}</code> ·
            <i class="bi bi-calendar-event"></i> Deadline <fmt:formatDate value="${assignment.dueDate}" pattern="dd/MM/yyyy HH:mm"/> ·
            <i class="bi bi-trophy"></i> Tối đa ${assignment.maxScore} điểm
        </p>
    </div>
    <div class="actions">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/app/assignments">
            <i class="bi bi-arrow-left"></i> Danh sách
        </a>
    </div>
</div>

<div class="row g-3">
    <div class="col-lg-8">
        <div class="card shadow-sm fade-in card-feature">
            <div class="card-header">
                <h5><i class="bi bi-card-text"></i> Mô tả bài tập</h5>
            </div>
            <div class="card-body">
                <p class="mb-0">${assignment.description}</p>

                <c:if test="${sessionScope.role == 'STUDENT'}">
                    <hr class="my-4">
                    <c:choose>
                        <c:when test="${not empty mySubmission}">
                            <h6 class="grade-section-title">
                                <i class="bi bi-check-circle text-success"></i> Bạn đã nộp bài
                            </h6>
                            <div class="alert alert-info">
                                <strong>Nội dung:</strong>
                                <p class="mb-2 mt-1">${mySubmission.content}</p>
                                <c:if test="${not empty mySubmission.filePath}">
                                    <strong>File:</strong>
                                    <a href="${mySubmission.filePath}" target="_blank" rel="noopener">${mySubmission.filePath}</a>
                                </c:if>
                            </div>

                            <c:choose>
                                <c:when test="${mySubmission.score != null}">
                                    <div class="grade-score-box">
                                        <div class="score">${mySubmission.score}<span class="score-max"> / ${assignment.maxScore}</span></div>
                                        <div class="score-hint">Điểm của bạn</div>
                                    </div>
                                    <c:if test="${not empty mySubmission.feedback}">
                                        <div class="alert alert-success mt-3">
                                            <strong><i class="bi bi-chat-quote"></i> Feedback từ giảng viên:</strong>
                                            <p class="mb-0 mt-1">${mySubmission.feedback}</p>
                                        </div>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-warning">
                                        <i class="bi bi-hourglass-split"></i> Bài của bạn đang chờ được chấm.
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <a class="btn btn-orange spirit-loading"
                               href="${pageContext.request.contextPath}/app/submissions?assignmentId=${assignment.assignmentId}">
                                <i class="bi bi-pencil"></i> Sửa bài
                            </a>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state" style="padding: 32px 16px;">
                                <div class="empty-icon"><i class="bi bi-upload"></i></div>
                                <h6>Bạn chưa nộp bài</h6>
                                <p>Hãy nộp bài trước deadline để được chấm điểm.</p>
                                <a class="btn btn-primary btn-lg spirit-loading mt-2"
                                   href="${pageContext.request.contextPath}/app/submissions?assignmentId=${assignment.assignmentId}">
                                    <i class="bi bi-cloud-upload"></i> Nộp bài ngay
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </div>
        </div>
    </div>

    <c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
        <div class="col-lg-4">
            <div class="card shadow-sm fade-in">
                <div class="card-header">
                    <h5><i class="bi bi-people"></i> Bài nộp</h5>
                    <span class="pill pill-navy">${submissions.size()}</span>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty submissions}">
                            <div class="empty-state">
                                <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                                <h6>Chưa có bài nộp</h6>
                                <p>Chờ sinh viên nộp bài.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <ul class="list-group list-group-flush">
                                <c:forEach var="s" items="${submissions}">
                                    <li class="list-group-item">
                                        <div class="d-flex justify-content-between align-items-start gap-2">
                                            <div class="flex-grow-1">
                                                <strong class="d-block">${s.studentName}</strong>
                                                <small class="text-muted">
                                                    <i class="bi bi-clock"></i>
                                                    <fmt:formatDate value="${s.submittedAt}" pattern="dd/MM HH:mm"/>
                                                </small>
                                            </div>
                                            <c:choose>
                                                <c:when test="${s.score != null}">
                                                    <span class="pill pill-success">${s.score}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pill pill-warning">Chờ chấm</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <a class="btn btn-sm btn-outline-primary mt-2"
                                           href="${pageContext.request.contextPath}/app/teacher/grading?submissionId=${s.submissionId}">
                                            <i class="bi bi-pencil-square"></i> Chấm
                                        </a>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="footer.jsp"/>
