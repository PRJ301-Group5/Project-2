package com.Spirit.gitanalytics.controller;

import com.Spirit.gitanalytics.dao.ExportHistoryDAO;
import com.Spirit.gitanalytics.model.ExportHistory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.List;

/**
 * ExportHistoryServlet - Xem lịch sử export CSV + download lại file cũ.
 * URL: /exports            (list mới nhất)
 *       /exports?download=1&id=42  (stream file từ disk)
 */
@WebServlet(name = "ExportHistoryServlet", urlPatterns = {"/exports"})
public class ExportHistoryServlet extends HttpServlet {

    private final ExportHistoryDAO historyDAO = new ExportHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String download = req.getParameter("download");
        if ("1".equals(download)) {
            int id = parseIntOrDefault(req.getParameter("id"), -1);
            if (id <= 0) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "id is required");
                return;
            }
            doDownload(req, resp, id);
            return;
        }

        try {
            List<ExportHistory> history = historyDAO.listRecent(50);
            req.setAttribute("history", history);
            req.getRequestDispatcher("/jsp/exports.jsp").forward(req, resp);
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }

    private void doDownload(HttpServletRequest req, HttpServletResponse resp, int historyId)
            throws IOException {
        try {
            List<ExportHistory> list = historyDAO.listRecent(1000);
            for (ExportHistory h : list) {
                if (h.getHistoryId() == historyId) {
                    Path p = Paths.get(h.getFilePath());
                    if (!Files.exists(p)) {
                        resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                                "File không tồn tại trên disk: " + h.getFileName());
                        return;
                    }
                    resp.setContentType("text/csv; charset=UTF-8");
                    resp.setHeader("Content-Disposition",
                            "attachment; filename=\"" + h.getFileName() + "\"");
                    Files.copy(p, resp.getOutputStream());
                    return;
                }
            }
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Export id not found");
        } catch (SQLException | ClassNotFoundException ex) {
            throw new IOException(ex);
        }
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
