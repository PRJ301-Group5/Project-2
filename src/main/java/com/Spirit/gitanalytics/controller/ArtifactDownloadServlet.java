package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.SubmissionDAO;
import com.Spirit.gitanalytics.dao.SubmissionFileDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.Submission;
import com.Spirit.gitanalytics.model.SubmissionArtifact;
import com.Spirit.gitanalytics.util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * ArtifactDownloadServlet - Tải file ZIP đã được nén + verify SHA-256.
 *
 * ArtifactFilter chạy trước (mapping /app/artifact) đã verify hash;
 * tới đây chỉ cần stream file.
 *
 * URL: /app/artifact?submissionId=N
 * Quyền: chỉ teacher/admin của lớp đó (mới xem được).
 */
@WebServlet(name = "ArtifactDownloadServlet", urlPatterns = {"/app/artifact"})
public class ArtifactDownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        AppUser user = (AppUser) session.getAttribute("currentUser");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        SubmissionArtifact a = (SubmissionArtifact) req.getAttribute("artifact");
        if (a == null) {
            // Filter không chạy hoặc attribute bị mất
            resp.sendError(500, "Artifact chua duoc verify (filter khong chay?).");
            return;
        }

        int submissionId = a.getSubmissionId();
        SubmissionDAO sDao = new SubmissionDAO();
        SubmissionFileDAO sfDao = new SubmissionFileDAO();
        AssignmentDAO aDao = new AssignmentDAO();
        Submission s;
        try {
            s = sDao.findById(submissionId);
        } catch (Exception ex) { throw new ServletException(ex); }
        if (s == null) { resp.sendError(404, "Submission khong ton tai."); return; }

        // Phân quyền: chỉ teacher/admin hoặc chính student đó
        Assignment assignment = null;
        try { assignment = aDao.findById(s.getAssignmentId()); } catch (Exception ignore) {}
        boolean isOwner = "STUDENT".equals(user.getRole()) && s.getStudentId() == user.getUserId();
        boolean isTeacher = "TEACHER".equals(user.getRole()) || "ADMIN".equals(user.getRole());
        if (!isOwner && !isTeacher) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Ban khong co quyen tai artifact nay.");
            return;
        }

        // Stream file ZIP
        String uploadRoot = FileUploadUtil.getRootDir(req);
        Path zipPath = Paths.get(uploadRoot, a.getZipPath());
        if (!Files.exists(zipPath)) { resp.sendError(404, "File khong con tren server."); return; }

        String originalName = "submission_" + submissionId + "_" + (assignment == null ? "" : assignment.getTitle().replaceAll("[^A-Za-z0-9._-]", "_")) + ".zip";
        resp.setContentType("application/zip");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + originalName + "\"");
        resp.setHeader("X-Spirit-SHA256", a.getSha256());
        resp.setHeader("X-Spirit-Verified", "true");
        resp.setContentLengthLong(Files.size(zipPath));
        Files.copy(zipPath, resp.getOutputStream());
    }
}
