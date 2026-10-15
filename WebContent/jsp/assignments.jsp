<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Bài tập" scope="request"/>
<jsp:include page="header.jsp"/>

<c:if test="${sessionScope.role == 'TEACHER' || sessionScope.role == 'ADMIN'}">
    <div class="card shadow mb-4">
        <div class="card-header bg-white"><h5 class="mb-0"><i class="bi bi-plus-circle"></i> Tạo bài tập mới</h5></div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/app/assignments" class="row g-2">
                <div class="col-md-4">
                    <label class="form-label">Lớp</label>
                    <select name="classId" class="form-select" required>
                        <c:forEach var="c" items="${classes}">
                            <option value="${c.classId}">${c.subjectCode} - ${c.className}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-8">
                    <label class="form-label">Tiêu đề</label>
                    <input type="text" name="title" class="form-control" required maxlength="200">
                </div>
                <div class="col-12">
                    <label class="form-label">Mô tả</label>
                    <textarea name="description" class="form-control" rows="2"></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Deadline</label>
                    <input type="datetime-local" name="dueDate" class="form-control" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Điểm tối đa</label>
                    <input type="number" name="maxScore" class="form-control" required value="10" min="0" step="0.5">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button class="btn btn-primary w-100"><i class="bi bi-plus"></i> Tạo</button>
                </div>
            </form>
        </div>
    </div>
</c:if>

<div class="card shadow">
    <div class="card-header bg-white">
        <h5 class="mb-0"><i class="bi bi-list-task"></i> Danh sách bài tập</h5>
    </div>
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th>Tiêu đề</th>
                    <th>Lớp</th>
                    <th>Deadline</th>
                    <th class="text-end">Điểm max</th>
                    <th class="text-center">Submissions</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty assignments}">
                        <tr><td colspan="6" class="text-center text-muted py-4">
                            <i class="bi bi-inbox"></i> Chưa có bài tập nào.
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="a" items="${assignments}">
                            <tr>
                                <td><strong>${a.title}</strong><br>
                                    <small class="text-muted">${a.description}</small></td>
                                <td><code>${a.classCode}</code></td>
                                <td><fmt:formatDate value="${a.dueDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td class="text-end">${a.maxScore}</td>
                                <td class="text-center">
                                    <span class="badge bg-info">${a.submissionCount}</span>
                                </td>
                                <td class="text-end">
                                    <a class="btn btn-sm btn-outline-primary"
                                       href="${pageContext.request.contextPath}/app/assignments/detail?id=${a.assignmentId}">
                                        <i class="bi bi-eye"></i> Chi tiết
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="footer.jsp"/>
