package com.Spirit.gitanalytics.filter;

import com.Spirit.gitanalytics.dao.SubmissionArtifactDAO;
import com.Spirit.gitanalytics.model.SubmissionArtifact;
import com.Spirit.gitanalytics.service.ArtifactService;
import com.Spirit.gitanalytics.util.FileUploadUtil;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * ArtifactFilter - Xác thực tính toàn vẹn (SHA-256) của file ZIP artifact
 * mỗi khi teacher tải về, để đảm bảo file không bị tamper trên server.
 *
 * Áp dụng cho URL: /app/artifact?submissionId=N (download ZIP)
 * Luồng:
 *   1) Đọc SubmissionArtifact từ DB
 *   2) Tính lại SHA-256 của file ZIP
 *   3) Nếu khớp -> VERIFIED, cho phép download
 *   4) Nếu lệch -> TAMPERED, trả 403
 *   5) Nếu file mất -> MISSING, trả 404
 *
 * Cấu hình trong web.xml (sau AuthFilter, cùng /* mapping).
 */
public class ArtifactFilter implements Filter {

    private final SubmissionArtifactDAO artifactDao = new SubmissionArtifactDAO();
    private final ArtifactService artifactService = new ArtifactService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpReq = (HttpServletRequest) req;
        HttpServletResponse httpResp = (HttpServletResponse) resp;
        String path = httpReq.getRequestURI().substring(httpReq.getContextPath().length());

        // Chỉ can thiệp khi URL là /app/artifact
        if (!path.startsWith("/app/artifact")) {
            chain.doFilter(req, resp);
            return;
        }

        String idStr = httpReq.getParameter("submissionId");
        if (idStr == null) { httpResp.sendError(400, "Thieu submissionId"); return; }
        int submissionId;
        try { submissionId = Integer.parseInt(idStr); }
        catch (NumberFormatException ex) { httpResp.sendError(400, "submissionId khong hop le"); return; }

        SubmissionArtifact a;
        try {
            a = artifactDao.findBySubmission(submissionId);
        } catch (Exception ex) {
            httpResp.sendError(500, "Khong doc duoc artifact: " + ex.getMessage());
            return;
        }
        if (a == null) {
            httpResp.sendError(404, "Submission chua co artifact (chua nop file).");
            return;
        }

        String uploadRoot = FileUploadUtil.getRootDir(httpReq);
        Path zipPath = Paths.get(uploadRoot, a.getZipPath());
        if (!Files.exists(zipPath)) {
            try { artifactDao.markVerified(submissionId, "MISSING"); } catch (Exception ignore) {}
            httpResp.sendError(404, "File ZIP khong con tren server.");
            return;
        }

        // Xác thực SHA-256
        String currentSha = ArtifactService.sha256Hex(zipPath);
        if (!currentSha.equalsIgnoreCase(a.getSha256())) {
            try { artifactDao.markVerified(submissionId, "TAMPERED"); } catch (Exception ignore) {}
            httpResp.sendError(HttpServletResponse.SC_FORBIDDEN,
                "PHAT HIEN FILE BI THAY DOI (TAMPERED). Hash khong khop. Vui long lien he admin.");
            return;
        }

        // OK
        try { artifactDao.markVerified(submissionId, "VERIFIED"); } catch (Exception ignore) {}
        httpReq.setAttribute("artifact", a);
        httpReq.setAttribute("verifiedSha256", currentSha);
        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {}
}
