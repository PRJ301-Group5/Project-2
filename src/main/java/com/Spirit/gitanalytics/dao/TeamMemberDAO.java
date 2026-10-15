package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.TeamMember;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * TeamMemberDAO - Truy vấn các thành viên trong 1 project, kèm thông tin student.
 */
public class TeamMemberDAO {

    /**
     * Lấy tất cả thành viên của 1 project, join với Student để có tên + MSSV.
     */
    public List<TeamMember> findByProject(int projectId) throws SQLException, ClassNotFoundException {
        List<TeamMember> list = new ArrayList<>();
        String sql = "SELECT tm.team_member_id, tm.project_id, tm.student_id, tm.git_email, tm.role, "
                   + "       s.student_code, s.full_name "
                   + "FROM TeamMember tm JOIN Student s ON tm.student_id = s.student_id "
                   + "WHERE tm.project_id = ? "
                   + "ORDER BY tm.team_member_id";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeamMember m = new TeamMember();
                    m.setTeamMemberId(rs.getInt("team_member_id"));
                    m.setProjectId(rs.getInt("project_id"));
                    m.setStudentId(rs.getInt("student_id"));
                    m.setGitEmail(rs.getString("git_email"));
                    m.setRole(rs.getString("role"));
                    m.setStudentCode(rs.getString("student_code"));
                    m.setFullName(rs.getString("full_name"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    /**
     * Tìm 1 member bằng git_email (lowercase compare).
     */
    public TeamMember findByEmail(int projectId, String email) throws SQLException, ClassNotFoundException {
        String sql = "SELECT tm.team_member_id, tm.project_id, tm.student_id, tm.git_email, tm.role, "
                   + "       s.student_code, s.full_name "
                   + "FROM TeamMember tm JOIN Student s ON tm.student_id = s.student_id "
                   + "WHERE tm.project_id = ? AND LOWER(tm.git_email) = LOWER(?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TeamMember m = new TeamMember();
                    m.setTeamMemberId(rs.getInt("team_member_id"));
                    m.setProjectId(rs.getInt("project_id"));
                    m.setStudentId(rs.getInt("student_id"));
                    m.setGitEmail(rs.getString("git_email"));
                    m.setRole(rs.getString("role"));
                    m.setStudentCode(rs.getString("student_code"));
                    m.setFullName(rs.getString("full_name"));
                    return m;
                }
            }
        }
        return null;
    }
}
