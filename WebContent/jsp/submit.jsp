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

<c:if test="${not empty error}">
    <div class="alert alert-danger fade-in">
        <i class="bi bi-exclamation-triangle"></i> ${error}
    </div>
</c:if>

<c:if test="${not empty assignmentFiles and not empty assignmentFiles.size() and assignmentFiles.size() > 0}">
    <div class="card shadow-sm mb-3 fade-in card-feature">
        <div class="card-header">
            <h5><i class="bi bi-paperclip"></i> File đề bài từ giảng viên</h5>
            <span class="pill pill-navy">${assignmentFiles.size()} file</span>
        </div>
        <div class="card-body">
            <ul class="file-list">
                <c:forEach var="f" items="${assignmentFiles}">
                    <li class="file-item">
                        <div class="file-icon ${f.contentType.startsWith('image/') ? 'orange' : ''}">
                            <i class="bi bi-${f.contentType.contains('pdf') ? 'file-earmark-pdf' : f.contentType.contains('zip') ? 'file-earmark-zip' : 'file-earmark'}"></i>
                        </div>
                        <div class="file-info">
                            <a class="file-name" href="${pageContext.request.contextPath}/app/files?type=assignment&id=${f.fileId}">
                                ${f.fileName}
                            </a>
                            <div class="file-meta">
                                <span>${f.humanSize}</span> ·
                                <fmt:formatDate value="${f.uploadedAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>
                        </div>
                        <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/app/files?type=assignment&id=${f.fileId}">
                            <i class="bi bi-download"></i> Tải xuống
                        </a>
                    </li>
                </c:forEach>
            </ul>
        </div>
    </div>
</c:if>

<div class="card shadow-sm fade-in">
    <div class="card-header">
        <h5><i class="bi bi-pencil-square"></i> Bài nộp của bạn</h5>
    </div>
    <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/app/submissions"
              enctype="multipart/form-data" class="spirit-auto-submit" id="submitForm">
            <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
            <input type="hidden" name="submitToken" value="${submitToken}">

            <c:if test="${graded}">
                <div class="alert alert-warning mb-4">
                    <i class="bi bi-lock-fill"></i>
                    <strong>Bài đã được chấm và đã khóa.</strong>
                    Bạn không thể nộp lại hoặc chỉnh sửa bài nữa.
                </div>
            </c:if>

            <c:if test="${not empty submission}">
                <c:choose>
                    <c:when test="${submission.score != null}">
                        <div class="grade-score-box mb-4">
                            <div class="score">${submission.score}<span class="score-max"> / ${assignment.maxScore}</span></div>
                            <div class="score-hint">Đã được chấm</div>
                        </div>
                        <c:if test="${not empty submission.feedback}">
                            <div class="alert alert-success mb-4">
                                <strong><i class="bi bi-chat-quote"></i> Feedback từ giảng viên:</strong>
                                <p class="mb-0 mt-1">${submission.feedback}</p>
                            </div>
                        </c:if>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-info mb-4">
                            <i class="bi bi-hourglass-split"></i> Bạn đã nộp bài. Bạn có thể cập nhật nội dung + file bên dưới.
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <div class="mb-3">
                <label class="form-label">Nội dung bài làm</label>
                <textarea name="content" class="form-control" rows="6" maxlength="10000"
                          placeholder="Dán link GitHub repo, gist hoặc nội dung bài làm của bạn…"><c:choose>
                    <c:when test="${not empty formContent}">${formContent}</c:when>
                    <c:otherwise>${submission.content}</c:otherwise>
                </c:choose></textarea>
                <small class="text-muted">Tối đa 10,000 ký tự</small>
            </div>

            <div class="mb-3">
                <label class="form-label">Hoặc đường dẫn file (link Google Drive, GitHub…)</label>
                <input type="text" name="filePath" class="form-control" maxlength="500"
                       value="<c:choose>
                           <c:when test="${not empty formFilePath}">${formFilePath}</c:when>
                           <c:otherwise>${submission.filePath}</c:otherwise>
                       </c:choose>"
                       placeholder="https://github.com/… hoặc đường dẫn file">
            </div>

            <div class="mb-4">
                <label class="form-label">Đính kèm file bài làm</label>
                <div class="file-drop" id="fileDrop">
                    <input type="file" name="attachments" id="fileInput" multiple
                           accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.md,.csv,.java,.py,.js,.ts,.html,.css,.json,.xml,.yml,.zip,.rar,.7z,.png,.jpg,.jpeg,.gif,.svg">
                    <div class="file-drop-icon"><i class="bi bi-cloud-arrow-up"></i></div>
                    <div class="file-drop-text">
                        <strong>Kéo & thả file vào đây</strong> hoặc <a href="#" id="browseBtn">chọn từ máy</a>
                    </div>
                    <div class="file-drop-hint">Tối đa 25 MB / file. Có thể chọn nhiều file.</div>
                </div>
                <ul class="file-list mt-2" id="fileList"></ul>
            </div>

            <c:if test="${not empty submissionFiles and submissionFiles.size() > 0}">
                <div class="mb-4">
                    <label class="form-label">File đã nộp trước đó</label>
                    <ul class="file-list">
                        <c:forEach var="f" items="${submissionFiles}">
                            <li class="file-item uploaded">
                                <div class="file-icon"><i class="bi bi-file-earmark-check"></i></div>
                                <div class="file-info">
                                    <span class="file-name">${f.fileName}</span>
                                    <div class="file-meta">
                                        <span>${f.humanSize}</span> ·
                                        <fmt:formatDate value="${f.uploadedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </div>
                                <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/app/files?type=submission&id=${f.fileId}">
                                    <i class="bi bi-download"></i>
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                    <small class="text-muted">Upload thêm file mới ở trên sẽ được thêm vào bài nộp.</small>
                </div>

                <c:if test="${not empty artifact}">
                    <div class="mb-4">
                        <label class="form-label"><i class="bi bi-shield-check"></i> Artifact (ZIP + SHA-256)</label>
                        <div class="alert alert-success mb-2 py-2">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <i class="bi bi-file-earmark-zip"></i>
                                    <strong>${artifact.zipStoredName}</strong>
                                    <span class="text-muted ms-2">${artifact.humanSize} · ${artifact.fileCount} file</span>
                                    <c:choose>
                                        <c:when test="${artifact.verificationStatus == 'VERIFIED'}">
                                            <span class="pill pill-success ms-2"><i class="bi bi-check-circle-fill"></i> VERIFIED</span>
                                        </c:when>
                                        <c:when test="${artifact.verificationStatus == 'TAMPERED'}">
                                            <span class="pill pill-danger ms-2"><i class="bi bi-exclamation-octagon-fill"></i> TAMPERED</span>
                                        </c:when>
                                        <c:when test="${artifact.verificationStatus == 'MISSING'}">
                                            <span class="pill pill-warning ms-2"><i class="bi bi-question-circle"></i> MISSING</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill pill-muted ms-2">PENDING</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <a class="btn btn-sm btn-orange"
                                   href="${pageContext.request.contextPath}/app/artifact?submissionId=${submission.submissionId}">
                                    <i class="bi bi-download"></i> Tải ZIP
                                </a>
                            </div>
                            <div class="mt-2">
                                <code class="small text-break" style="word-break: break-all;">SHA-256: ${artifact.sha256}</code>
                                <c:if test="${not empty artifact.verifiedAt}">
                                    <span class="text-muted ms-2 small">
                                        <i class="bi bi-clock"></i> verify lúc
                                        <fmt:formatDate value="${artifact.verifiedAt}" pattern="dd/MM HH:mm:ss"/>
                                    </span>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:if>
            </c:if>

            <div class="d-flex gap-2">
                <c:choose>
                    <c:when test="${graded}">
                        <button class="btn btn-secondary" type="button" disabled>
                            <i class="bi bi-lock-fill"></i> Bài đã chấm — không thể chỉnh sửa
                        </button>
                    </c:when>
                    <c:otherwise>
                        <button class="btn btn-primary spirit-loading" type="submit" id="submitBtn">
                            <i class="bi bi-check2"></i> Lưu bài nộp
                        </button>
                    </c:otherwise>
                </c:choose>
                <a class="btn btn-outline-secondary"
                   href="${pageContext.request.contextPath}/app/assignments/detail?id=${assignment.assignmentId}">
                    <i class="bi bi-x-lg"></i> Huỷ
                </a>
            </div>
        </form>
    </div>
</div>

<script>
(function() {
    const form = document.getElementById('submitForm');
    const drop = document.getElementById('fileDrop');
    const input = document.getElementById('fileInput');
    const list = document.getElementById('fileList');
    const browse = document.getElementById('browseBtn');
    const btn = document.getElementById('submitBtn');

    // ---- Chống double-submit: khoá nút ngay khi submit ----
    if (form && btn) {
        let submitting = false;
        form.addEventListener('submit', function () {
            if (submitting) { return; }
            submitting = true;
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang nộp bài…';
        });
        // Nếu trình duyệt chặn submit (validation fail) -> mở lại nút
        window.setTimeout(function () {
            if (submitting && form.checkValidity && !form.checkValidity()) {
                submitting = false;
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-check2"></i> Lưu bài nộp';
            }
        }, 0);
    }

    if (!drop) return;
    browse.addEventListener('click', e => { e.preventDefault(); input.click(); });
    drop.addEventListener('click', e => { if (e.target.tagName !== 'A' && e.target.tagName !== 'BUTTON') input.click(); });
    ['dragenter','dragover'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.add('dragover'); }));
    ['dragleave','drop'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.remove('dragover'); }));
    drop.addEventListener('drop', e => { input.files = e.dataTransfer.files; render(); });
    input.addEventListener('change', render);
    function render() {
        list.innerHTML = '';
        const files = input.files;
        if (!files || files.length === 0) return;
        for (const f of files) {
            const li = document.createElement('li');
            li.className = 'file-item';
            li.innerHTML = '<div class="file-icon"><i class="bi bi-file-earmark"></i></div>'
                + '<div class="file-info"><span class="file-name"></span>'
                + '<div class="file-meta"><span class="sz"></span></div></div>';
            li.querySelector('.file-name').textContent = f.name;
            li.querySelector('.sz').textContent = (f.size / 1024).toFixed(1) + ' KB';
            list.appendChild(li);
        }
    }
})();
</script>

<jsp:include page="footer.jsp"/>
