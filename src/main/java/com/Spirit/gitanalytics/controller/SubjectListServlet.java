package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.SubjectDAO;
import com.Spirit.gitanalytics.model.Subject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * SubjectListServlet - Trang danh sách môn học (cho Student).
 * URL: /app/subjects
 */
@WebServlet(name = "SubjectListServlet", urlPatterns = {"/app/subjects"})
public class SubjectListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Subject> subjects = new SubjectDAO().findAll();
            req.setAttribute("subjects", subjects);
            req.getRequestDispatcher("/jsp/subjects.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
