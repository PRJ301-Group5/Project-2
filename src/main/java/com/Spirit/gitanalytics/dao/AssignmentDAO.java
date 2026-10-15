package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class AssignmentDAO {

    private static final String SELECT_BASE =
        "SELECT a.assignment_id, a.class_id, a.title, a.description, a.prompt_file, a.due_date, "
      + "a.max_score, a.created_by, a.created_at, c.class_code, c.class_name, "
      + "(SELECT COUNT(*) FROM Submission s WHERE s.assignment_id = a.assignment_id) AS submission_count "
      + "FROM Assignment a JOIN ClassRoom c ON a.class_id = c.class_id ";

    public List<Assignment> findAll() throws SQLException, ClassNotFoundException {
        List<Assignment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BASE + "ORDER BY a.due_date DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<Assignment> findByClass(int classId) throws SQLException, ClassNotFoundException {
        List<Assignment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BASE + "WHERE a.class_id = ? ORDER BY a.due_date DESC")) {
            ps.setInt(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Assignment> findByStudentClasses(List<Integer> classIds) throws SQLException, ClassNotFoundException {
        if (classIds == null || classIds.isEmpty()) return new ArrayList<>();
        StringBuilder sb = new StringBuilder(SELECT_BASE).append("WHERE a.class_id IN (");
        for (int i = 0; i < classIds.size(); i++) sb.append(i == 0 ? "?" : ",?");
        sb.append(") ORDER BY a.due_date DESC");
        List<Assignment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {
            for (int i = 0; i < classIds.size(); i++) ps.setInt(i + 1, classIds.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public Assignment findById(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BASE + "WHERE a.assignment_id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public int insert(Assignment a) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO Assignment(class_id, title, description, prompt_file, due_date, max_score, created_by) "
                   + "VALUES(?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, a.getClassId());
            ps.setString(2, a.getTitle());
            ps.setString(3, a.getDescription());
            if (a.getPromptFile() == null) ps.setNull(4, Types.VARCHAR); else ps.setString(4, a.getPromptFile());
            ps.setTimestamp(5, a.getDueDate());
            ps.setDouble(6, a.getMaxScore());
            ps.setInt(7, a.getCreatedBy());
            int n = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) a.setAssignmentId(keys.getInt(1));
            }
            return n;
        }
    }

    public int update(Assignment a) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Assignment SET title=?, description=?, prompt_file=?, due_date=?, max_score=? "
                   + "WHERE assignment_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getDescription());
            if (a.getPromptFile() == null) ps.setNull(3, Types.VARCHAR); else ps.setString(3, a.getPromptFile());
            ps.setTimestamp(4, a.getDueDate());
            ps.setDouble(5, a.getMaxScore());
            ps.setInt(6, a.getAssignmentId());
            return ps.executeUpdate();
        }
    }

    public int delete(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM Assignment WHERE assignment_id = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        }
    }

    private Assignment map(ResultSet rs) throws SQLException {
        Assignment a = new Assignment();
        a.setAssignmentId(rs.getInt("assignment_id"));
        a.setClassId(rs.getInt("class_id"));
        a.setTitle(rs.getString("title"));
        a.setDescription(rs.getString("description"));
        a.setPromptFile(rs.getString("prompt_file"));
        a.setDueDate(rs.getTimestamp("due_date"));
        a.setMaxScore(rs.getDouble("max_score"));
        a.setCreatedBy(rs.getInt("created_by"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setClassCode(rs.getString("class_code"));
        a.setClassName(rs.getString("class_name"));
        a.setSubmissionCount(rs.getInt("submission_count"));
        return a;
    }
}
