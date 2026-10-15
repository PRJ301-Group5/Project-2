package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.Subject;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SubjectDAO {

    public List<Subject> findAll() throws SQLException, ClassNotFoundException {
        List<Subject> list = new ArrayList<>();
        String sql = "SELECT subject_id, subject_code, subject_name, semester, description, created_at "
                   + "FROM Subject ORDER BY subject_code";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<Subject> findBySemester(String semester) throws SQLException, ClassNotFoundException {
        List<Subject> list = new ArrayList<>();
        String sql = "SELECT subject_id, subject_code, subject_name, semester, description, created_at "
                   + "FROM Subject WHERE semester = ? ORDER BY subject_code";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, semester);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public Subject findById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT subject_id, subject_code, subject_name, semester, description, created_at "
                   + "FROM Subject WHERE subject_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public int insert(Subject s) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO Subject(subject_code, subject_name, semester, description) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, s.getSubjectCode());
            ps.setString(2, s.getSubjectName());
            ps.setString(3, s.getSemester());
            ps.setString(4, s.getDescription());
            int n = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) s.setSubjectId(keys.getInt(1));
            }
            return n;
        }
    }

    public int update(Subject s) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE Subject SET subject_code=?, subject_name=?, semester=?, description=? WHERE subject_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getSubjectCode());
            ps.setString(2, s.getSubjectName());
            ps.setString(3, s.getSemester());
            ps.setString(4, s.getDescription());
            ps.setInt(5, s.getSubjectId());
            return ps.executeUpdate();
        }
    }

    public int delete(int id) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM Subject WHERE subject_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        }
    }

    private Subject map(ResultSet rs) throws SQLException {
        Subject s = new Subject();
        s.setSubjectId(rs.getInt("subject_id"));
        s.setSubjectCode(rs.getString("subject_code"));
        s.setSubjectName(rs.getString("subject_name"));
        s.setSemester(rs.getString("semester"));
        s.setDescription(rs.getString("description"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }
}
