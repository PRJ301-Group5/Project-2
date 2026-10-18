package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.AssignmentFileDAO;
import com.Spirit.gitanalytics.dao.ClassRoomDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.dao.SubmissionFileDAO;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.AssignmentFile;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.ClassRoom;
import com.Spirit.gitanalytics.model.Submission;
import com.Spirit.gitanalytics.model.SubmissionFile;
import com.Spirit.gitanalytics.util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * FileDownloadServlet - Serve uploaded files (assignment + submission).
 * URL: /app/files?type=assignment&id={fileId} | type=submission&id={fileId}
 *
 * Authorization:
 *   - Assignment files: any logged-in user enrolled in that class can download.
 *   - Submission files: only the owning student, the class teacher, or admin.
 */
@WebServlet(name = "FileDownloadServlet", urlPatterns = {"/app/files"})
public class FileDownloadServlet extends HttpServlet {

    private final AssignmentFileDAO afDao = new AssignmentFileDAO();
    private final SubmissionFileDAO sfDao = new SubmissionFileDAO();
    private final AssignmentDAO aDao = new AssignmentDAO();
    private final SubmissionDAO sDao = new SubmissionDAO();
    private final ClassRoomDAO cDao = new ClassRoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String type = req.getParameter("type");
        String idStr = req.getParameter("id");
        if (type == null || idStr == null) { resp.sendError(400); return; }
        int id;
        try { id = Integer.parseInt(idStr); } catch (NumberFormatException e) { resp.sendError(400); return; }

        try {
            if ("assignment".equalsIgnoreCase(type)) {
                AssignmentFile f = afDao.findById(id);
                if (f == null) { resp.sendError(404, "File không tồn tại."); return; }
                Assignment a = aDao.findById(f.getAssignmentId());
                if (a == null) { resp.sendError(404); return; }
                if (!canAccessAssignmentFile(user, a)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn chưa tham gia lớp này.");
                    return;
                }
                streamFile(req, resp, f.getFileName(), f.getContentType(), f.getFilePath());
            } else if ("submission".equalsIgnoreCase(type)) {
                SubmissionFile f = sfDao.findById(id);
                if (f == null) { resp.sendError(404, "File không tồn tại."); return; }
                Submission s = sDao.findById(f.getSubmissionId());
                if (s == null) { resp.sendError(404); return; }
                Assignment a = aDao.findById(s.getAssignmentId());
                if (!canAccessSubmissionFile(user, s, a)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền tải file này.");
                    return;
                }
                streamFile(req, resp, f.getFileName(), f.getContentType(), f.getFilePath());
            } else {
                resp.sendError(400, "type không hợp lệ.");
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private boolean canAccessAssignmentFile(AppUser user, Assignment a) throws Exception {
        if ("ADMIN".equals(user.getRole())) return true;
        ClassRoom c = cDao.findById(a.getClassId());
        if (c == null) return false;
        if ("TEACHER".equals(user.getRole()) && c.getTeacherId() == user.getUserId()) return true;
        if ("STUDENT".equals(user.getRole())) {
            return cDao.isEnrolled(c.getClassId(), user.getUserId());
        }
        return false;
    }

    private boolean canAccessSubmissionFile(AppUser user, Submission s, Assignment a) throws Exception {
        if ("ADMIN".equals(user.getRole())) return true;
        if ("STUDENT".equals(user.getRole()) && s.getStudentId() == user.getUserId()) return true;
        if ("TEACHER".equals(user.getRole())) {
            ClassRoom c = cDao.findById(a.getClassId());
            return c != null && c.getTeacherId() == user.getUserId();
        }
        return false;
    }

    private void streamFile(HttpServletRequest req, HttpServletResponse resp, String originalName,
                            String contentType, String relativePath) throws IOException {
        // Path traversal guard
        if (relativePath == null || relativePath.isEmpty() || relativePath.contains("..")) {
            resp.sendError(400); return;
        }
        String baseDir = FileUploadUtil.getRootDir(req);
        Path p = Paths.get(baseDir, relativePath).normalize();
        if (!p.startsWith(Paths.get(baseDir).normalize())) { resp.sendError(400); return; }
        if (!Files.exists(p)) { resp.sendError(404, "File không còn trên server."); return; }

        String safeName = FileUploadUtil.safeName(originalName);
        if (contentType == null || contentType.isEmpty()) {
            contentType = Files.probeContentType(p);
            if (contentType == null) contentType = "application/octet-stream";
        }

        // Inline cho PDF/image, attachment cho còn lại
        boolean inline = contentType.startsWith("image/") || contentType.equals("application/pdf") || contentType.startsWith("text/");
        String disposition = (inline ? "inline" : "attachment") + "; filename=\"" + encodeFilename(safeName) + "\"";

        resp.setContentType(contentType);
        resp.setHeader("Content-Disposition", disposition);
        resp.setContentLengthLong(Files.size(p));
        Files.copy(p, resp.getOutputStream());
    }

    private String encodeFilename(String name) {
        // RFC 5987 cho unicode
        try {
            return java.net.URLEncoder.encode(name, "UTF-8").replace("+", "%20");
        } catch (Exception e) {
            return name;
        }
    }
}
