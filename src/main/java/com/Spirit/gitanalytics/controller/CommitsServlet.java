package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.CommitRecordDAO;
import com.Spirit.gitanalytics.dao.ProjectDAO;
import com.Spirit.gitanalytics.model.CommitRecord;
import com.Spirit.gitanalytics.model.Project;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * CommitsServlet - Xem danh sách commits của 1 project.
 * URL: /commits?projectId=1
 */
@WebServlet(name = "CommitsServlet", urlPatterns = {"/commits"})
public class CommitsServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final CommitRecordDAO commitDAO = new CommitRecordDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int projectId = parseIntOrDefault(req.getParameter("projectId"), -1);
        if (projectId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/projects");
            return;
        }
        try {
            Project project = projectDAO.findById(projectId);
            List<CommitRecord> commits = commitDAO.findByProject(projectId);
            req.setAttribute("project", project);
            req.setAttribute("commits", commits);
            req.getRequestDispatcher("/jsp/commits.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
