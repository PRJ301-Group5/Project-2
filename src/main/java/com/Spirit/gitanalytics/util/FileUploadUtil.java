package com.Spirit.gitanalytics.util;

import com.Spirit.gitanalytics.model.AssignmentFile;
import com.Spirit.gitanalytics.model.SubmissionFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

/**
 * FileUploadUtil - Save uploaded files (multi-part) to /uploads directory.
 *
 * Layout on disk:
 *   /uploads/assignments/{uuid}_{originalName}
 *   /uploads/submissions/{uuid}_{originalName}
 *
 * Per-file size limit: 25 MB (configurable below).
 * Allowed extensions are checked against a whitelist to mitigate script uploads.
 */
public final class FileUploadUtil {

    /** Thư mục gốc dành cho upload — resolve từ app working dir. */
    public static final String UPLOAD_BASE_NAME = "uploads";

    /** 25 MB. */
    public static final long MAX_FILE_SIZE = 25L * 1024 * 1024;

    /** Whitelist (lowercase). Cho phép phổ biến các loại file bài tập. */
    public static final String[] ALLOWED_EXT = {
        "pdf","doc","docx","xls","xlsx","ppt","pptx",
        "txt","md","rtf","csv",
        "java","py","js","ts","html","css","scss","json","xml","yml","yaml",
        "c","cpp","cs","h","hpp","go","rs","kt","swift","m","mm","sh","bat",
        "zip","rar","7z","tar","gz","bz2",
        "png","jpg","jpeg","gif","bmp","webp","svg","ico",
        "mp3","mp4","wav","m4a","webm","ogg"
    };

    private FileUploadUtil() {}

    public static String getRootDir(HttpServletRequest req) {
        // 1) System property hoặc env (ưu tiên cao nhất)
        String custom = System.getProperty("SPIRIT_UPLOAD_ROOT", System.getenv("SPIRIT_UPLOAD_ROOT"));
        if (custom != null && !custom.isEmpty()) {
            File f = new File(custom);
            if (!f.exists()) f.mkdirs();
            return f.getAbsolutePath();
        }

        // 2) ServletContext real path (Jetty extracted WAR)
        //    Thường là: <project>/target/gitanalytics/
        //    Ta cần đi lên để ra project root.
        try {
            String realPath = req.getServletContext().getRealPath("");
            if (realPath != null && !realPath.isEmpty()) {
                File f = new File(realPath);
                // walk up: gitanalytics -> target -> ... -> tìm folder chứa database/
                File probe = f;
                for (int i = 0; i < 5 && probe != null; i++) {
                    File dbDir = new File(probe, "database");
                    if (dbDir.exists() && dbDir.isDirectory()) {
                        File up = new File(probe, UPLOAD_BASE_NAME);
                        if (!up.exists()) up.mkdirs();
                        return up.getAbsolutePath();
                    }
                    probe = probe.getParentFile();
                }
            }
        } catch (Exception ignore) {}

        // 3) Fallback: user.dir + /uploads
        File fallback = new File(System.getProperty("user.dir"), UPLOAD_BASE_NAME);
        if (!fallback.exists()) fallback.mkdirs();
        return fallback.getAbsolutePath();
    }

    /** Save all files in form field `fieldName` under `subDir` (e.g. "assignments"). */
    public static List<UploadResult> saveFiles(HttpServletRequest req, String fieldName, String subDir)
            throws IOException, IllegalStateException, SecurityException {
        List<UploadResult> results = new ArrayList<>();
        Collection<Part> parts;
        try {
            parts = req.getParts();
        } catch (Exception ex) {
            return results; // not multipart
        }
        String baseDir = getRootDir(req);
        File subDirFile = new File(baseDir, subDir);
        if (!subDirFile.exists()) subDirFile.mkdirs();

        for (Part part : parts) {
            if (!part.getName().equals(fieldName)) continue;
            if (part.getSize() == 0) continue;
            if (part.getSize() > MAX_FILE_SIZE) {
                throw new IllegalStateException("File vượt quá 25 MB: " + safeName(part.getSubmittedFileName()));
            }
            String origName = safeName(part.getSubmittedFileName());
            if (origName.isEmpty()) continue;
            String ext = extension(origName);
            if (!isAllowed(ext)) {
                throw new SecurityException("Định dạng ." + ext + " không được phép.");
            }

            String uuid = UUID.randomUUID().toString().substring(0, 8);
            String stored = uuid + "_" + origName;
            Path target = Paths.get(subDirFile.getAbsolutePath(), stored);

            try (InputStream in = part.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            UploadResult r = new UploadResult();
            r.originalName = origName;
            r.storedName = stored;
            r.relativePath = subDir + "/" + stored;
            r.size = part.getSize();
            r.contentType = part.getContentType();
            results.add(r);
        }
        return results;
    }

    public static boolean deleteFile(HttpServletRequest req, String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) return false;
        if (relativePath.contains("..")) return false; // path traversal guard
        Path p = Paths.get(getRootDir(req), relativePath);
        try {
            return Files.deleteIfExists(p);
        } catch (IOException e) {
            return false;
        }
    }

    public static String extension(String name) {
        int dot = name.lastIndexOf('.');
        if (dot < 0 || dot == name.length() - 1) return "";
        return name.substring(dot + 1).toLowerCase();
    }

    public static boolean isAllowed(String ext) {
        if (ext == null || ext.isEmpty()) return false;
        for (String a : ALLOWED_EXT) if (a.equals(ext)) return true;
        return false;
    }

    /** Strip any path components and dangerous chars. */
    public static String safeName(String raw) {
        if (raw == null) return "";
        String name = raw;
        // IE/Edge quirk: full path sent
        int slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
        if (slash >= 0) name = name.substring(slash + 1);
        // Reject control chars
        name = name.replaceAll("[\\x00-\\x1f]", "").trim();
        return name;
    }

    public static class UploadResult {
        public String originalName;
        public String storedName;
        public String relativePath;
        public long size;
        public String contentType;

        public AssignmentFile toAssignmentFile(int assignmentId, int uploaderId) {
            AssignmentFile f = new AssignmentFile();
            f.setAssignmentId(assignmentId);
            f.setFileName(originalName);
            f.setStoredName(storedName);
            f.setFilePath(relativePath);
            f.setFileSize(size);
            f.setContentType(contentType);
            f.setUploadedBy(uploaderId);
            return f;
        }

        public SubmissionFile toSubmissionFile(int submissionId) {
            SubmissionFile f = new SubmissionFile();
            f.setSubmissionId(submissionId);
            f.setFileName(originalName);
            f.setStoredName(storedName);
            f.setFilePath(relativePath);
            f.setFileSize(size);
            f.setContentType(contentType);
            return f;
        }
    }
}
