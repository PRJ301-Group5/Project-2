package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.ProjectDAO;
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
 * ProjectListServlet - Trang danh sách project.
 * URL: /projects
 */
@WebServlet(name = "ProjectListServlet", urlPatterns = {"/projects"})
public class ProjectListServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Project> projects = projectDAO.findAll();
            req.setAttribute("projects", projects);
            req.getRequestDispatcher("/jsp/projects.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
