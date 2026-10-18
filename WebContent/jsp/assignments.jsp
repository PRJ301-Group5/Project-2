<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Bài tập" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-head fade-in">
    <div>
        <h1 class="title">
            <span class="icon-box"><i class="bi bi-journal-text"></i></span>
            <c:choose>
                <c:when test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">Quản lý bài tập</c:when>
                <c:otherwise>Bài tập của tôi</c:otherwise>
            </c:choose>
        </h1>
        <p class="subtitle">Tạo, theo dõi và chấm điểm bài tập.</p>
    </div>
</div>

<c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
    <div class="card shadow-sm mb-3 fade-in card-feature">
        <div class="card-header">
            <h5><i class="bi bi-plus-circle"></i> Tạo bài tập mới</h5>
        </div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/app/assignments"
                  enctype="multipart/form-data" class="row g-3 spirit-auto-submit">
                <div class="col-md-4">
                    <label class="form-label">Lớp</label>
                    <select name="classId" class="form-select" required>
                        <c:forEach var="c" items="${classes}">
                            <option value="${c.classId}">${c.subjectCode} — ${c.className}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-8">
                    <label class="form-label">Tiêu đề</label>
                    <input type="text" name="title" class="form-control" required maxlength="200" placeholder="VD: Assignment 1 — Spring Boot CRUD">
                </div>
                <div class="col-12">
                    <label class="form-label">Mô tả</label>
                    <textarea name="description" class="form-control" rows="2" placeholder="Mô tả chi tiết yêu cầu bài tập…"></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Deadline</label>
                    <input type="datetime-local" name="dueDate" class="form-control" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Điểm tối đa</label>
                    <input type="number" name="maxScore" class="form-control" required value="10" min="0" step="0.5">
                </div>
                <div class="col-12">
                    <label class="form-label">File đính kèm (đề bài, tài liệu, code mẫu…)</label>
                    <input type="file" name="attachments" class="form-control" multiple
                           accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.md,.csv,.java,.py,.js,.ts,.html,.css,.json,.xml,.yml,.zip,.rar,.7z,.png,.jpg,.jpeg,.gif,.svg">
                    <small class="text-muted">Có thể chọn nhiều file. Tối đa 25 MB / file.</small>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button class="btn btn-primary w-100 spirit-loading" type="submit">
                        <i class="bi bi-plus-lg"></i> Tạo
                    </button>
                </div>
            </form>
        </div>
    </div>
</c:if>

<div class="card shadow-sm fade-in">
    <div class="card-header">
        <h5><i class="bi bi-list-task"></i> Danh sách bài tập</h5>
        <span class="pill pill-muted">${empty assignments ? 0 : assignments.size()} bài</span>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty assignments}">
                <div class="empty-state">
                    <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                    <h6>Chưa có bài tập nào</h6>
                    <p>Hãy tạo bài tập mới để bắt đầu.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Tiêu đề</th>
                                <th>Lớp</th>
                                <th>Deadline</th>
                                <th class="text-end">Điểm max</th>
                                <th class="text-center">Submissions</th>
                                <th class="text-end"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="a" items="${assignments}">
                                <tr>
                                    <td>
                                        <div class="fw-semibold">${a.title}</div>
                                        <small class="text-muted">${a.description}</small>
                                    </td>
                                    <td><code>${a.classCode}</code></td>
                                    <td>
                                        <i class="bi bi-calendar-event text-muted me-1"></i>
                                        <fmt:formatDate value="${a.dueDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td class="text-end fw-semibold">${a.maxScore}</td>
                                    <td class="text-center">
                                        <span class="pill pill-info">${a.submissionCount}</span>
                                    </td>
                                    <td class="text-end">
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="${pageContext.request.contextPath}/app/assignments/detail?id=${a.assignmentId}">
                                            <i class="bi bi-eye"></i> Chi tiết
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

<jsp:include page="footer.jsp"/>
