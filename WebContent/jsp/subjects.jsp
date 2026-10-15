<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Môn học" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="card shadow">
    <div class="card-header bg-white">
        <h4 class="mb-0"><i class="bi bi-book"></i> Môn học của bạn</h4>
    </div>
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="table-light">
                <tr>
                    <th>Mã môn</th>
                    <th>Tên môn</th>
                    <th>Học kỳ</th>
                    <th>Mô tả</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty subjects}">
                        <tr><td colspan="4" class="text-center text-muted py-4">
                            <i class="bi bi-inbox"></i> Chưa có môn học nào.
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="s" items="${subjects}">
                            <tr>
                                <td><code>${s.subjectCode}</code></td>
                                <td>${s.subjectName}</td>
                                <td><span class="badge bg-secondary">${s.semester}</span></td>
                                <td><small class="text-muted">${s.description}</small></td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="footer.jsp"/>
