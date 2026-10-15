package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.model.ContributionScore;
import com.Spirit.gitanalytics.service.AnalyticsService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

/**
 * ExportServlet - Export kết quả đóng góp ra CSV cho giảng viên download.
 * URL: /export.csv?projectId=1
 */
@WebServlet(name = "ExportServlet", urlPatterns = {"/export.csv"})
public class ExportServlet extends HttpServlet {

    private final AnalyticsService service = new AnalyticsService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int projectId = parseIntOrDefault(req.getParameter("projectId"), -1);
        if (projectId <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "projectId is required");
            return;
        }
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"contribution_" + projectId + ".csv\"");

        try (PrintWriter out = resp.getWriter()) {
            out.println("MSSV,Full Name,Role,Commits,Lines Added,Active Days,Contribution %,Fairness Score,Status");
            List<ContributionScore> scores = service.getScores(projectId);
            for (ContributionScore s : scores) {
                out.printf("%s,%s,%s,%d,%d,%d,%.2f,%.2f,%s%n",
                    s.getStudentCode(),
                    csvEscape(s.getFullName()),
                    csvEscape(s.getRole()),
                    s.getTotalCommits(),
                    s.getTotalLinesAdded(),
                    s.getActiveDays(),
                    s.getContributionPct(),
                    s.getFairnessScore(),
                    s.getStatus());
            }
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
