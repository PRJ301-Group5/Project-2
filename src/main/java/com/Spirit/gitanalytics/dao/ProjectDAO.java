package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.Project;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * ProjectDAO - Data Access Object cho bảng Project.
 */
public class ProjectDAO {

    public List<Project> findAll() throws SQLException, ClassNotFoundException {
        List<Project> list = new ArrayList<>();
        String sql = "SELECT project_id, project_code, project_name, repo_url, local_path, "
                   + "start_date, end_date, created_at FROM Project ORDER BY project_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Project p = new Project();
                p.setProjectId(rs.getInt("project_id"));
                p.setProjectCode(rs.getString("project_code"));
                p.setProjectName(rs.getString("project_name"));
                p.setRepoUrl(rs.getString("repo_url"));
                p.setLocalPath(rs.getString("local_path"));
                p.setStartDate(rs.getTimestamp("start_date"));
                p.setEndDate(rs.getTimestamp("end_date"));
                p.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(p);
            }
        }
        return list;
    }

    public Project findById(int id) throws SQLException, ClassNotFoundException {
        String sql = "SELECT project_id, project_code, project_name, repo_url, local_path, "
                   + "start_date, end_date FROM Project WHERE project_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Project p = new Project();
                    p.setProjectId(rs.getInt("project_id"));
                    p.setProjectCode(rs.getString("project_code"));
                    p.setProjectName(rs.getString("project_name"));
                    p.setRepoUrl(rs.getString("repo_url"));
                    p.setLocalPath(rs.getString("local_path"));
                    p.setStartDate(rs.getTimestamp("start_date"));
                    p.setEndDate(rs.getTimestamp("end_date"));
                    return p;
                }
            }
        }
        return null;
    }

    public int insert(Project p) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO Project(project_code, project_name, repo_url, local_path) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getProjectCode());
            ps.setString(2, p.getProjectName());
            ps.setString(3, p.getRepoUrl());
            ps.setString(4, p.getLocalPath());
            return ps.executeUpdate();
        }
    }
}
