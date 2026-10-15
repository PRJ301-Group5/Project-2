package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.service.AnalyticsService;
import org.eclipse.jgit.api.errors.GitAPIException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * AnalyzeServlet - Trigger 1 lần analyze cho project.
 *
 * POST /analyze?projectId=1
 * Redirect về Dashboard sau khi xong.
 */
@WebServlet(name = "AnalyzeServlet", urlPatterns = {"/analyze"})
public class AnalyzeServlet extends HttpServlet {

    private final AnalyticsService service = new AnalyticsService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int projectId = parseIntOrDefault(req.getParameter("projectId"), -1);
        if (projectId <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "projectId is required");
            return;
        }
        try {
            int commits = service.analyzeProject(projectId);
            req.getSession().setAttribute("flash", "Analyze thành công: " + commits + " commits.");
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", "Lỗi: " + ex.getMessage());
        } catch (SQLException | ClassNotFoundException | IOException | GitAPIException ex) {
            throw new ServletException(ex);
        }
        resp.sendRedirect(req.getContextPath() + "/dashboard?projectId=" + projectId);
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
