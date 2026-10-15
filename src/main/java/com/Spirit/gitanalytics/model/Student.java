package com.Spirit.gitanalytics.model;

/**
 * Student - POJO cho sinh viên.
 */
public class Student {
    private int studentId;
    private String studentCode;
    private String fullName;
    private String email;

    public Student() {}

    public Student(int studentId, String studentCode, String fullName, String email) {
        this.studentId = studentId;
        this.studentCode = studentCode;
        this.fullName = fullName;
        this.email = email;
    }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
