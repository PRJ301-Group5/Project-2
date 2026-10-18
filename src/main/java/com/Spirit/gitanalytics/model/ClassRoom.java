package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * ClassRoom - Lớp học (1 teacher dạy 1 subject trong 1 học kỳ).
 */
public class ClassRoom {
    private int classId;
    private int subjectId;
    private int teacherId;
    private String classCode;
    private String className;
    private String semester;
    private String description;
    private boolean joinEnabled = true;
    private Timestamp createdAt;

    // joined fields (optional, for display)
    private String subjectCode;
    private String subjectName;
    private String teacherName;
    private int studentCount;

    public ClassRoom() {}

    public int getClassId() { return classId; }
    public void setClassId(int classId) { this.classId = classId; }

    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public String getClassCode() { return classCode; }
    public void setClassCode(String classCode) { this.classCode = classCode; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isJoinEnabled() { return joinEnabled; }
    public void setJoinEnabled(boolean joinEnabled) { this.joinEnabled = joinEnabled; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getStudentCount() { return studentCount; }
    public void setStudentCount(int studentCount) { this.studentCount = studentCount; }

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
}
