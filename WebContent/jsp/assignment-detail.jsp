<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="${assignment.title}" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="row">
    <div class="col-md-8">
        <div class="card shadow mb-4">
            <div class="card-header bg-white">
                <h4 class="mb-0">${assignment.title}</h4>
                <p class="mb-0 small text-muted">
                    Lớp: <code>${assignment.classCode}</code> ·
                    Deadline: <fmt:formatDate value="${assignment.dueDate}" pattern="dd/MM/yyyy HH:mm"/> ·
                    Max: ${assignment.maxScore} điểm
                </p>
            </div>
            <div class="card-body">
                <h6>Mô tả:</h6>
                <p>${assignment.description}</p>

                <c:if test="${sessionScope.role == 'STUDENT'}">
                    <hr>
                    <c:choose>
                        <c:when test="${not empty mySubmission}">
                            <h6><i class="bi bi-check-circle text-success"></i> Bạn đã nộp bài</h6>
                            <p><strong>Nội dung:</strong> ${mySubmission.content}</p>
                            <c:if test="${not empty mySubmission.filePath}">
                                <p><strong>File:</strong> <a href="${mySubmission.filePath}" target="_blank">${mySubmission.filePath}</a></p>
                            </c:if>
                            <c:choose>
                                <c:when test="${mySubmission.score != null}">
                                    <div class="alert alert-success">
                                        <strong>Điểm: ${mySubmission.score} / ${assignment.maxScore}</strong><br>
                                        Feedback: ${mySubmission.feedback}
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-info">Chưa được chấm điểm.</div>
                                </c:otherwise>
                            </c:choose>
                            <a class="btn btn-warning"
                               href="${pageContext.request.contextPath}/app/submissions?assignmentId=${assignment.assignmentId}">
                                <i class="bi bi-pencil"></i> Sửa bài
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-primary"
                               href="${pageContext.request.contextPath}/app/submissions?assignmentId=${assignment.assignmentId}">
                                <i class="bi bi-upload"></i> Nộp bài
                            </a>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </div>
        </div>
    </div>

    <c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header bg-white">
                    <h6 class="mb-0"><i class="bi bi-people"></i> Bài nộp (${submissions.size()})</h6>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty submissions}">
                            <p class="text-muted text-center py-3 m-0">
                                <i class="bi bi-inbox"></i> Chưa có bài nộp.
                            </p>
                        </c:when>
                        <c:otherwise>
                            <ul class="list-group list-group-flush">
                                <c:forEach var="s" items="${submissions}">
                                    <li class="list-group-item">
                                        <strong>${s.studentName}</strong><br>
                                        <small class="text-muted">
                                            <fmt:formatDate value="${s.submittedAt}" pattern="dd/MM HH:mm"/>
                                        </small>
                                        <c:choose>
                                            <c:when test="${s.score != null}">
                                                <span class="badge bg-success float-end">${s.score}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary float-end">Chưa chấm</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <br>
                                        <a class="btn btn-sm btn-outline-primary mt-1"
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
