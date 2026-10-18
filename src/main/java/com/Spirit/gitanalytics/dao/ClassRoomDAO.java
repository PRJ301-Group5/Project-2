package com.Spirit.gitanalytics.dao;

import com.Spirit.gitanalytics.model.ClassRoom;
import com.Spirit.gitanalytics.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClassRoomDAO {

    private static final String SELECT_JOIN =
        "SELECT c.class_id, c.subject_id, c.teacher_id, c.class_code, c.class_name, c.semester, "
      + "       c.description, c.join_enabled, c.created_at, "
      + "       s.subject_code, s.subject_name, u.full_name AS teacher_name, "
      + "       (SELECT COUNT(*) FROM Enrollment e WHERE e.class_id = c.class_id) AS student_count "
      + "FROM ClassRoom c "
      + "JOIN Subject s ON c.subject_id = s.subject_id "
      + "JOIN AppUser u ON c.teacher_id = u.user_id ";

    public List<ClassRoom> findAll() throws SQLException, ClassNotFoundException {
        List<ClassRoom> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_JOIN + "ORDER BY c.class_id DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<ClassRoom> findByTeacher(int teacherId) throws SQLException, ClassNotFoundException {
        List<ClassRoom> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_JOIN + "WHERE c.teacher_id = ? ORDER BY c.class_id DESC")) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<ClassRoom> findByStudent(int studentId) throws SQLException, ClassNotFoundException {
        List<ClassRoom> list = new ArrayList<>();
        String sql = SELECT_JOIN
                   + "JOIN Enrollment e ON c.class_id = e.class_id "
                   + "WHERE e.student_id = ? ORDER BY c.class_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public ClassRoom findById(int id) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_JOIN + "WHERE c.class_id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /** Tìm lớp theo class_code (dùng cho student join). */
    public ClassRoom findByCode(String code) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_JOIN + "WHERE UPPER(c.class_code) = UPPER(?)")) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public int insert(ClassRoom c) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO ClassRoom(subject_id, teacher_id, class_code, class_name, semester, description, join_enabled) "
                   + "VALUES(?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getSubjectId());
            ps.setInt(2, c.getTeacherId());
            ps.setString(3, c.getClassCode());
            ps.setString(4, c.getClassName());
            ps.setString(5, c.getSemester());
            ps.setString(6, c.getDescription());
            ps.setBoolean(7, c.isJoinEnabled());
            int n = ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) c.setClassId(keys.getInt(1));
            }
            return n;
        }
    }

    public int update(ClassRoom c) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE ClassRoom SET subject_id=?, class_code=?, class_name=?, semester=?, description=?, join_enabled=? "
                   + "WHERE class_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c.getSubjectId());
            ps.setString(2, c.getClassCode());
            ps.setString(3, c.getClassName());
            ps.setString(4, c.getSemester());
            ps.setString(5, c.getDescription());
            ps.setBoolean(6, c.isJoinEnabled());
            ps.setInt(7, c.getClassId());
            return ps.executeUpdate();
        }
    }

    public int delete(int id) throws SQLException, ClassNotFoundException {
        String sql = "DELETE FROM ClassRoom WHERE class_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        }
    }

    /** Enroll a student into a class. Returns 1 if newly enrolled, 0 if already enrolled. */
    public int enroll(int classId, int studentId) throws SQLException, ClassNotFoundException {
        String check = "SELECT 1 FROM Enrollment WHERE class_id = ? AND student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(check)) {
            ps.setInt(1, classId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return 0;
            }
        }
        String sql = "INSERT INTO Enrollment(class_id, student_id) VALUES(?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, classId);
            ps.setInt(2, studentId);
            return ps.executeUpdate();
        }
    }

    public int unenroll(int classId, int studentId) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "DELETE FROM Enrollment WHERE class_id = ? AND student_id = ?")) {
            ps.setInt(1, classId);
            ps.setInt(2, studentId);
            return ps.executeUpdate();
        }
    }

    public boolean isEnrolled(int classId, int studentId) throws SQLException, ClassNotFoundException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT 1 FROM Enrollment WHERE class_id = ? AND student_id = ?")) {
            ps.setInt(1, classId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private ClassRoom map(ResultSet rs) throws SQLException {
        ClassRoom c = new ClassRoom();
        c.setClassId(rs.getInt("class_id"));
        c.setSubjectId(rs.getInt("subject_id"));
        c.setTeacherId(rs.getInt("teacher_id"));
        c.setClassCode(rs.getString("class_code"));
        c.setClassName(rs.getString("class_name"));
        c.setSemester(rs.getString("semester"));
        c.setDescription(rs.getString("description"));
        c.setJoinEnabled(rs.getBoolean("join_enabled"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setSubjectCode(rs.getString("subject_code"));
        c.setSubjectName(rs.getString("subject_name"));
        c.setTeacherName(rs.getString("teacher_name"));
        c.setStudentCount(rs.getInt("student_count"));
        return c;
    }
}
