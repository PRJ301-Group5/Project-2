package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.AssignmentFileDAO;
import com.Spirit.gitanalytics.dao.GradeDAO;
import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.dao.SubmissionFileDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.Notification;
import com.Spirit.gitanalytics.model.Submission;
import com.Spirit.gitanalytics.model.SubmissionFile;
import com.Spirit.gitanalytics.service.ArtifactService;
import com.Spirit.gitanalytics.util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * SubmissionServlet - Student nộp bài (POST) hoặc xem lại (GET).
 * Hỗ trợ multipart upload nhiều file bài làm.
 *
 * Quy tắc nghiệp vụ:
 *   - Sau khi giảng viên đã chấm (có bản ghi trong Grade) thì sinh viên
 *     KHÔNG được nộp lại hay chỉnh sửa bài nữa.
 *   - Chống double-submit: mỗi lần render form sinh 1 token, server chỉ
 *     nhận 1 request hợp lệ cho mỗi token.
 *   - Khi có lỗi, forward lại form KÈM toàn bộ dữ liệu đã nhập
 *     (content/filePath/submission/assignmentFiles) để sinh viên không phải
 *     nhập lại và nộp lần hai.
 *
 * URL: /app/submissions
 */
@WebServlet(name = "SubmissionServlet", urlPatterns = {"/app/submissions"})
@MultipartConfig(maxFileSize = 26 * 1024 * 1024, maxRequestSize = 200 * 1024 * 1024)
public class SubmissionServlet extends HttpServlet {

    private final SubmissionDAO subDao = new SubmissionDAO();
    private final AssignmentDAO asmDao = new AssignmentDAO();
    private final AssignmentFileDAO afDao = new AssignmentFileDAO();
    private final SubmissionFileDAO sfDao = new SubmissionFileDAO();
    private final GradeDAO gradeDao = new GradeDAO();
    private final NotificationDAO notiDao = new NotificationDAO();
    private final ArtifactService artifactService = new ArtifactService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!"STUDENT".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ sinh viên mới được nộp bài.");
            return;
        }

        int assignmentId = parseAssignmentId(req.getParameter("assignmentId"));
        if (assignmentId <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã bài tập.");
            return;
        }

        try {
            Assignment a = asmDao.findById(assignmentId);
            if (a == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Assignment không tồn tại.");
                return;
            }
            Submission s = subDao.findByAssignmentAndStudent(assignmentId, user.getUserId());
            populate(req, user, assignmentId, a, s);

            // Token chống double-submit cho form
            req.setAttribute("submitToken", newSubmitToken(session));

            req.getRequestDispatcher("/jsp/submit.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!"STUDENT".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ sinh viên mới được nộp bài.");
            return;
        }

        int assignmentId = parseAssignmentId(req.getParameter("assignmentId"));
        if (assignmentId <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã bài tập.");
            return;
        }

        // ---- Chống double-submit: token phải khớp và chưa dùng ----
        String token = trim(req.getParameter("submitToken"));
        if (!consumeSubmitToken(session, token)) {
            // Đã xử lý rồi (double-click / refresh) -> đưa về trang chi tiết
            resp.sendRedirect(req.getContextPath() + "/app/assignments/detail?id=" + assignmentId);
            return;
        }

        try {
            String content = req.getParameter("content");
            String filePath = req.getParameter("filePath");
            Assignment a = asmDao.findById(assignmentId);
            if (a == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Assignment không tồn tại.");
                return;
            }

            Submission existing = subDao.findByAssignmentAndStudent(assignmentId, user.getUserId());

            // ---- ĐÃ CHẤM -> khóa bài, không cho nộp/sửa nữa ----
            if (existing != null && gradeDao.findBySubmission(existing.getSubmissionId()) != null) {
                forwardError(req, resp, user, assignmentId, a, existing,
                        "Bài của bạn đã được giảng viên chấm. Bạn không thể nộp lại hoặc chỉnh sửa bài nữa.",
                        content, filePath);
                return;
            }

            // ---- Quá hạn ----
            if (a.getDueDate() != null && a.getDueDate().before(new java.util.Date())) {
                forwardError(req, resp, user, assignmentId, a, existing,
                        "Đã quá hạn nộp bài (deadline: " + a.getDueDate() + ").",
                        content, filePath);
                return;
            }

            // ---- Lưu file upload (nếu có) ----
            List<FileUploadUtil.UploadResult> uploaded;
            try {
                uploaded = FileUploadUtil.saveFiles(req, "attachments", "submissions");
            } catch (IllegalStateException | SecurityException ex) {
                forwardError(req, resp, user, assignmentId, a, existing,
                        ex.getMessage(), content, filePath);
                return;
            } catch (IOException ex) {
                forwardError(req, resp, user, assignmentId, a, existing,
                        "Lỗi khi lưu file: " + ex.getMessage(), content, filePath);
                return;
            }

            if (isBlank(content) && isBlank(filePath) && uploaded.isEmpty()) {
                forwardError(req, resp, user, assignmentId, a, existing,
                        "Vui lòng nhập nội dung, dán link hoặc upload ít nhất 1 file.",
                        content, filePath);
                return;
            }

            // ---- Insert hoặc update submission ----
            int submissionId;
            boolean isNew = (existing == null);
            if (isNew) {
                Submission s = new Submission();
                s.setAssignmentId(assignmentId);
                s.setStudentId(user.getUserId());
                s.setContent(content);
                s.setFilePath(filePath);
                subDao.insert(s);
                submissionId = s.getSubmissionId();

                Notification n = new Notification();
                n.setUserId(a.getCreatedBy());
                n.setTitle("Bài nộp mới: " + a.getTitle());
                n.setBody(user.getFullName() + " vừa nộp bài"
                        + (uploaded.isEmpty() ? "." : " với " + uploaded.size() + " file."));
                n.setLink("/app/assignments/detail?id=" + a.getAssignmentId());
                try { notiDao.insert(n); } catch (Exception ignore) {}
            } else {
                existing.setContent(content);
                existing.setFilePath(filePath);
                subDao.update(existing);
                submissionId = existing.getSubmissionId();
            }

            // ---- Lưu từng file ----
            for (FileUploadUtil.UploadResult r : uploaded) {
                sfDao.insert(r.toSubmissionFile(submissionId));
            }

            // ---- Nén ZIP + SHA-256 (4.4.1 + 4.4.2) ----
            if (!uploaded.isEmpty()) {
                try {
                    String uploadRoot = FileUploadUtil.getRootDir(req);
                    artifactService.createArtifact(submissionId, sfDao.findBySubmission(submissionId), uploadRoot);
                } catch (Exception ex) {
                    // Không fail cả request: bài đã lưu, chỉ báo warning
                    session.setAttribute("flash",
                            "Bài đã lưu nhưng tạo artifact thất bại: " + ex.getMessage());
                }
            }

            session.setAttribute("flash", isNew
                    ? "Đã nộp bài thành công" + (uploaded.isEmpty() ? "." : " với " + uploaded.size() + " file.")
                    : "Đã cập nhật bài nộp" + (uploaded.isEmpty() ? "." : " với " + uploaded.size() + " file."));
            resp.sendRedirect(req.getContextPath() + "/app/assignments/detail?id=" + assignmentId);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    /** Nạp đầy đủ dữ liệu cho trang submit.jsp (dùng cho cả GET và forward khi lỗi). */
    private void populate(HttpServletRequest req, AppUser user, int assignmentId,
                         Assignment a, Submission s) throws SQLException, ClassNotFoundException {
        req.setAttribute("assignment", a);
        req.setAttribute("assignmentFiles", afDao.findByAssignment(assignmentId));
        req.setAttribute("submission", s);
        if (s != null) {
            req.setAttribute("submissionFiles", sfDao.findBySubmission(s.getSubmissionId()));
            try {
                req.setAttribute("artifact", artifactService.find(s.getSubmissionId()));
            } catch (Exception ex) {
                req.setAttribute("artifact", null);
            }
        }
        // Cờ đã chấm -> JSP sẽ ẩn form nhập
        req.setAttribute("graded", s != null && gradeDao.findBySubmission(s.getSubmissionId()) != null);
    }

    /** Forward lại form kèm lỗi + toàn bộ dữ liệu người dùng đã nhập (không mất nội dung). */
    private void forwardError(HttpServletRequest req, HttpServletResponse resp, AppUser user,
                              int assignmentId, Assignment a, Submission existing,
                              String error, String content, String filePath)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        req.setAttribute("error", error);
        // Giữ lại nội dung người dùng vừa gõ
        req.setAttribute("formContent", content);
        req.setAttribute("formFilePath", filePath);
        populate(req, user, assignmentId, a, existing);
        // Sinh token mới để sinh viên sửa lỗi rồi nộp lại được
        req.setAttribute("submitToken", newSubmitToken(req.getSession(true)));
        req.getRequestDispatcher("/jsp/submit.jsp").forward(req, resp);
    }

    /**
     * Sinh token chống double-submit, gắn vào session.
     * Giữ nhiều token cùng lúc để sinh viên mở nhiều tab vẫn nộp được.
     */
    @SuppressWarnings("unchecked")
    private String newSubmitToken(HttpSession session) {
        String t = java.util.UUID.randomUUID().toString();
        java.util.List<String> tokens = validTokens(session);
        tokens.add(t);
        // Giới hạn số token tồn tại
        while (tokens.size() > 5) tokens.remove(0);
        session.setAttribute("submitTokens", tokens);
        return t;
    }

    @SuppressWarnings("unchecked")
    private java.util.List<String> validTokens(HttpSession session) {
        Object o = session.getAttribute("submitTokens");
        if (o instanceof java.util.List) return (java.util.List<String>) o;
        java.util.List<String> list = new java.util.ArrayList<>();
        session.setAttribute("submitTokens", list);
        return list;
    }

    /**
     * Kiểm tra token hợp lệ và vô hiệu hoá nó ngay (one-shot).
     * Trả về false nếu request bị trùng -> không xử lý lại.
     */
    private boolean consumeSubmitToken(HttpSession session, String token) {
        if (token == null || token.isEmpty()) {
            // Không có token (VD: client cũ) -> cho qua, chống trùng ở tầng DB
            return true;
        }
        java.util.List<String> tokens = validTokens(session);
        if (!tokens.remove(token)) {
            return false; // token đã dùng hoặc không khớp -> double submit
        }
        return true;
    }

    private static int parseAssignmentId(String raw) {
        if (raw == null || raw.trim().isEmpty()) return -1;
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
