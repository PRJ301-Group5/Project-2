package com.Spirit.gitanalytics.service;

import com.Spirit.gitanalytics.dao.SubmissionArtifactDAO;
import com.Spirit.gitanalytics.model.SubmissionArtifact;
import com.Spirit.gitanalytics.model.SubmissionFile;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * ArtifactService - Nén các file submission thành 1 file ZIP,
 * đồng thời tính SHA-256 hash của ZIP để xác thực tính toàn vẹn.
 *
 * Lưu metadata vào bảng SubmissionArtifact.
 *
 * Luồng:
 *   1) Sau khi SubmissionServlet save file xong
 *   2) Gọi ArtifactService.createArtifact(submissionId, files, uploadRootDir)
 *   3) Nó sẽ nén thành sub_{id}_{uuid}.zip, tính SHA-256, upsert row
 */
public class ArtifactService {

    private final SubmissionArtifactDAO dao = new SubmissionArtifactDAO();

    /**
     * Tạo artifact ZIP từ danh sách file submission.
     * Trả về SubmissionArtifact (có thể null nếu files rỗng).
     */
    public SubmissionArtifact createArtifact(int submissionId, List<SubmissionFile> files, String uploadRootDir)
            throws IOException {
        if (files == null || files.isEmpty()) return null;

        // 1) Tạo file ZIP
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        String storedName = "sub_" + submissionId + "_" + uuid + ".zip";
        String subDir = "artifacts";
        Path subDirPath = Paths.get(uploadRootDir, subDir);
        Files.createDirectories(subDirPath);
        Path zipPath = subDirPath.resolve(storedName);
        String relativePath = subDir + "/" + storedName;

        int fileCount = 0;
        try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zipPath.toFile()))) {
            for (SubmissionFile f : files) {
                Path src = Paths.get(uploadRootDir, f.getFilePath());
                if (!Files.exists(src)) continue; // skip missing file
                // Tên entry trong ZIP: file gốc
                String entryName = f.getFileName();
                ZipEntry entry = new ZipEntry(entryName);
                entry.setSize(Files.size(src));
                zos.putNextEntry(entry);
                Files.copy(src, zos);
                zos.closeEntry();
                fileCount++;
            }
        }

        long zipSize = Files.size(zipPath);

        // 2) Tính SHA-256
        String sha = sha256Hex(zipPath);

        // 3) Lưu metadata
        SubmissionArtifact a = new SubmissionArtifact();
        a.setSubmissionId(submissionId);
        a.setZipStoredName(storedName);
        a.setZipPath(relativePath);
        a.setZipSize(zipSize);
        a.setSha256(sha);
        a.setFileCount(fileCount);
        a.setVerificationStatus("PENDING");
        try {
            dao.upsert(a);
        } catch (Exception ex) {
            // Nếu lỗi DB thì xoá file ZIP vừa tạo để tránh rác
            try { Files.deleteIfExists(zipPath); } catch (IOException ignore) {}
            throw new IOException("Khong the luu SubmissionArtifact: " + ex.getMessage(), ex);
        }
        return a;
    }

    /**
     * Xác thực lại: tính SHA-256 của file ZIP hiện tại, so với SHA-256 lưu trong DB.
     * Trả về true nếu khớp. Đồng thời update verification_status.
     */
    public boolean verifyArtifact(int submissionId, String uploadRootDir) throws IOException {
        SubmissionArtifact a;
        try {
            a = dao.findBySubmission(submissionId);
        } catch (Exception ex) {
            throw new IOException("Khong the doc SubmissionArtifact: " + ex.getMessage(), ex);
        }
        if (a == null) return false;
        Path zipPath = Paths.get(uploadRootDir, a.getZipPath());
        if (!Files.exists(zipPath)) {
            try { dao.markVerified(submissionId, "MISSING"); } catch (Exception ignore) {}
            return false;
        }
        String currentSha = sha256Hex(zipPath);
        boolean ok = currentSha.equalsIgnoreCase(a.getSha256());
        try {
            dao.markVerified(submissionId, ok ? "VERIFIED" : "TAMPERED");
        } catch (Exception ignore) {}
        return ok;
    }

    public SubmissionArtifact find(int submissionId) throws Exception {
        return dao.findBySubmission(submissionId);
    }

    /** SHA-256 của 1 file -> hex lowercase 64 ký tự. */
    public static String sha256Hex(Path file) throws IOException {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            try (FileInputStream fis = new FileInputStream(file.toFile())) {
                byte[] buf = new byte[8192];
                int n;
                while ((n = fis.read(buf)) > 0) {
                    md.update(buf, 0, n);
                }
            }
            byte[] digest = md.digest();
            StringBuilder sb = new StringBuilder(64);
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException ex) {
            throw new IOException("Khong tim thay SHA-256 algorithm", ex);
        }
    }

    /** SHA-256 in-memory (cho string). */
    public static String sha256Hex(byte[] data) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(data);
            StringBuilder sb = new StringBuilder(64);
            for (byte b : digest) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException ex) {
            return null;
        }
    }
}
