package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.ContributionScore;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * ContributionScoreDAO - Persist và truy vấn điểm đóng góp.
 */
public class ContributionScoreDAO {

    public void upsert(ContributionScore s) throws SQLException, ClassNotFoundException {
        String sql = "MERGE ContributionScore AS target "
                   + "USING (SELECT ? AS project_id, ? AS team_member_id) AS source "
                   + "ON target.project_id = source.project_id AND target.team_member_id = source.team_member_id "
                   + "WHEN MATCHED THEN "
                   + "  UPDATE SET total_commits=?, total_lines_added=?, total_lines_deleted=?, "
                   + "             active_days=?, contribution_pct=?, fairness_score=?, status=?, last_analyzed=GETDATE() "
                   + "WHEN NOT MATCHED THEN "
                   + "  INSERT(project_id, team_member_id, total_commits, total_lines_added, total_lines_deleted, "
                   + "         active_days, contribution_pct, fairness_score, status, last_analyzed) "
                   + "  VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE());";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, s.getProjectId());
            ps.setInt(2, s.getTeamMemberId());
            ps.setInt(3, s.getTotalCommits());
            ps.setInt(4, s.getTotalLinesAdded());
            ps.setInt(5, s.getTotalLinesDeleted());
            ps.setInt(6, s.getActiveDays());
            ps.setDouble(7, s.getContributionPct());
            ps.setDouble(8, s.getFairnessScore());
            ps.setString(9, s.getStatus());
            ps.setInt(10, s.getProjectId());
            ps.setInt(11, s.getTeamMemberId());
            ps.setInt(12, s.getTotalCommits());
            ps.setInt(13, s.getTotalLinesAdded());
            ps.setInt(14, s.getTotalLinesDeleted());
            ps.setInt(15, s.getActiveDays());
            ps.setDouble(16, s.getContributionPct());
            ps.setDouble(17, s.getFairnessScore());
            ps.setString(18, s.getStatus());
            ps.executeUpdate();
        }
    }

    public List<ContributionScore> findByProject(int projectId)
            throws SQLException, ClassNotFoundException {
        List<ContributionScore> list = new ArrayList<>();
        String sql = "SELECT cs.score_id, cs.project_id, cs.team_member_id, cs.total_commits, "
                   + "       cs.total_lines_added, cs.total_lines_deleted, cs.active_days, "
                   + "       cs.contribution_pct, cs.fairness_score, cs.status, cs.last_analyzed, "
                   + "       tm.role, s.student_code, s.full_name "
                   + "FROM ContributionScore cs "
                   + "JOIN TeamMember tm ON cs.team_member_id = tm.team_member_id "
                   + "JOIN Student s    ON tm.student_id = s.student_id "
                   + "WHERE cs.project_id = ? "
                   + "ORDER BY cs.contribution_pct DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ContributionScore s = new ContributionScore();
                    s.setScoreId(rs.getInt("score_id"));
                    s.setProjectId(rs.getInt("project_id"));
                    s.setTeamMemberId(rs.getInt("team_member_id"));
                    s.setTotalCommits(rs.getInt("total_commits"));
                    s.setTotalLinesAdded(rs.getInt("total_lines_added"));
                    s.setTotalLinesDeleted(rs.getInt("total_lines_deleted"));
                    s.setActiveDays(rs.getInt("active_days"));
                    s.setContributionPct(rs.getDouble("contribution_pct"));
                    s.setFairnessScore(rs.getDouble("fairness_score"));
                    s.setStatus(rs.getString("status"));
                    s.setLastAnalyzed(rs.getTimestamp("last_analyzed"));
                    s.setRole(rs.getString("role"));
                    s.setStudentCode(rs.getString("student_code"));
                    s.setFullName(rs.getString("full_name"));
                    list.add(s);
                }
            }
        }
        return list;
    }
}
