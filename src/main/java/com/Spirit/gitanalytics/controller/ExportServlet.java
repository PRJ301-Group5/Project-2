package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.ExportHistoryDAO;
import com.Spirit.gitanalytics.model.ContributionScore;
import com.Spirit.gitanalytics.model.ExportHistory;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.service.AnalyticsService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * ExportServlet - Export kết quả đóng góp ra CSV cho giảng viên download.
 * URL: /export.csv?projectId=1
 *
 * Luồng mới (Option 1):
 *   1. Build CSV vào StringBuilder
 *   2. Lưu file vật lý vào C:\gitanalytics-exports\contribution_{projectId}_{timestamp}.csv
 *   3. INSERT vào ExportHistory (audit + pointer)
 *   4. Stream file xuống response để user download
 */
@WebServlet(name = "ExportServlet", urlPatterns = {"/export.csv"})
public class ExportServlet extends HttpServlet {

    private static final String EXPORT_DIR = "C:" + File.separator + "gitanalytics-exports";

    private final AnalyticsService service = new AnalyticsService();
    private final ExportHistoryDAO historyDAO = new ExportHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int projectId = parseIntOrDefault(req.getParameter("projectId"), -1);
        if (projectId <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "projectId is required");
            return;
        }

        try {
            // 1. Build CSV trong memory
            StringBuilder csv = new StringBuilder();
            csv.append("MSSV,Full Name,Role,Commits,Lines Added,Active Days,Contribution %,Fairness Score,Status\r\n");
            List<ContributionScore> scores = service.getScores(projectId);
            for (ContributionScore s : scores) {
                csv.append(String.format("%s,%s,%s,%d,%d,%d,%.2f,%.2f,%s%n",
                        s.getStudentCode(),
                        csvEscape(s.getFullName()),
                        csvEscape(s.getRole()),
                        s.getTotalCommits(),
                        s.getTotalLinesAdded(),
                        s.getActiveDays(),
                        s.getContributionPct(),
                        s.getFairnessScore(),
                        s.getStatus()));
            }
            String csvContent = csv.toString();
            int rowCount = scores.size();
            byte[] csvBytes = csvContent.getBytes(StandardCharsets.UTF_8);

            // 2. Lưu file vật lý (UTF-8 BOM để Excel mở đúng tiếng Việt)
            File dir = new File(EXPORT_DIR);
            if (!dir.exists() && !dir.mkdirs()) {
                throw new IOException("Cannot create export dir: " + EXPORT_DIR);
            }
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String fileName = "contribution_" + projectId + "_" + timestamp + ".csv";
            Path filePath = Paths.get(EXPORT_DIR, fileName);
            byte[] bom = new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF};
            try (FileOutputStream fos = new FileOutputStream(filePath.toFile())) {
                fos.write(bom);
                fos.write(csvBytes);
            }

            // 3. Ghi audit + pointer vào DB
            HttpSession session = req.getSession(false);
            String exportedBy = "anonymous";
            if (session != null) {
                AppUser user = (AppUser) session.getAttribute("currentUser");
                if (user != null && user.getUsername() != null) {
                    exportedBy = user.getUsername();
                }
            }
            ExportHistory history = new ExportHistory();
            history.setProjectId(projectId);
            history.setExportedBy(exportedBy);
            history.setFileName(fileName);
            history.setFilePath(filePath.toString());
            history.setFileBytes(csvBytes.length + 3); // +3 for BOM
            history.setRowCount(rowCount);
            int historyId = historyDAO.insert(history);

            // 4. Stream file xuống response
            resp.setContentType("text/csv; charset=UTF-8");
            resp.setHeader("Content-Disposition", "attachment; filename=\"contribution_" + projectId + ".csv\"");
            resp.setHeader("X-Export-Id", String.valueOf(historyId));
            resp.setContentLength(csvBytes.length + 3);
            resp.getOutputStream().write(bom);
            resp.getOutputStream().write(csvBytes);
            resp.getOutputStream().flush();

        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    private String csvEscape(String s) {
        if (s == null) return "";
        if (s.contains(",") || s.contains("\"")) {
            return "\"" + s.replace("\"", "\"\"") + "\"";
        }
        return s;
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
