# Spirit — AI Grading Tool for Lecturers

> Module Nhóm 5 (Spirit Project) — mở rộng từ Git Analytics Teamwork Assessor.
> Hệ thống hỗ trợ **giảng viên tạo bài tập → sinh viên nộp bài → giảng viên chấm điểm**,
> kèm thông báo deadline tự động và phân tích Git cho dự án nhóm.

---

## 🏃 Chạy nhanh

```powershell
# 1. Khởi động SQL Server (đã có instance MAYAO chạy sẵn)
# 2. Tạo DB + schema + sample data
sqlcmd -S localhost -E -b -i database\bootstrap.sql
sqlcmd -S localhost -E -b -i database\grading_schema.sql

# 3. Cập nhật password hash thật cho tài khoản demo
# (đã chạy 1 lần - hash BCrypt của "Password@123")
# SELECT username, password_hash FROM AppUser;

# 4. Build + chạy Jetty
mvn clean package -DskipTests
mvn jetty:run-war
```

Truy cập: **http://localhost:8080/gitanalytics/**

### 🔑 Tài khoản demo

| Role    | Username  | Password       |
|---------|-----------|----------------|
| Teacher | `teacher1`| `Password@123` |
| Student | `student1`| `Password@123` |
| Student | `student2`| `Password@123` |
| Student | `student3`| `Password@123` |

---

## 📋 Module Chấm điểm — Mapping 100 tiêu chí

### A. UX/UI (1-20)

| #   | Tiêu chí | Triển khai |
|-----|----------|------------|
| 1   | Homepage works | `index.jsp` redirect về `/login` hoặc `/app/dashboard` |
| 2   | Logo displays | Spirit mortarboard icon trên navbar |
| 3   | Navbar works | `header.jsp` — navbar với Bootstrap 5 |
| 4   | Footer is complete | `footer.jsp` |
| 5   | No broken links | Tất cả links dùng `${pageContext.request.contextPath}` |
| 6   | Buttons work | Form POST + JS confirm |
| 7   | Forms display correctly | Bootstrap form-control classes |
| 8   | Consistent fonts | `'Segoe UI', Tahoma, sans-serif` trong `app.css` |
| 9   | Consistent colors | Palette: primary `#2c3e50`, accent `#667eea → #764ba2` |
| 10  | Reasonable spacing | Bootstrap utility classes + CSS spacing |
| 11  | No screen overflow | Container max-width, `overflow-x: hidden` |
| 12  | Responsive on laptop | Bootstrap grid (md/lg) |
| 13  | Responsive on mobile | `@media (max-width: 768px)` trong `app.css` |
| 14  | Responsive on tablet | `@media (max-width: 576px)` |
| 15  | Images not distorted | Sử dụng Bootstrap icon fonts (không dùng ảnh) |
| 16  | Loading indicator | (Có thể thêm spinner component) |
| 17  | Success notifications | `alert-success` cho flash messages |
| 18  | Error notifications | `alert-danger` cho error messages |
| 19  | Empty state | Hiển thị icon + "Chưa có dữ liệu" khi list rỗng |
| 20  | Confirmation on data deletion | `onsubmit="return confirm(...)"` trong form xoá |

### B. Authentication (21-30)

| #   | Tiêu chí | Triển khai |
|-----|----------|------------|
| 21  | Register | `RegisterServlet` + `register.jsp` |
| 22  | Login | `LoginServlet` + `login.jsp` |
| 23  | Logout | `LogoutServlet` invalidate session |
| 24  | Password is encrypted | `SecurityUtil.hashPassword()` — BCrypt cost 10 |
| 25  | No plaintext password | `AppUser.password_hash` lưu BCrypt, không lưu plain |
| 26  | Valid email check | Regex `^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$` trong `RegisterServlet` |
| 27  | Password validation | `minlength="6"` HTML5 + server-side check |
| 28  | Prevent login with incorrect info | `LoginServlet` check hash, hiển thị "Sai mật khẩu" |
| 29  | Session/token works | HttpSession với timeout 30 phút |
| 30  | Prevent unauthenticated access | `AuthFilter` redirect `/app/*` về `/login` |

### C. Authorization (31-36)

| #   | Tiêu chí | Triển khai |
|-----|----------|------------|
| 31  | Roles exist | `AppUser.role` ∈ {TEACHER, STUDENT, ADMIN} |
| 32  | Admin has specific permissions | (Có role ADMIN, có thể truy cập `/app/teacher/*`) |
| 33  | User has specific permissions | Student chỉ thấy assignment của lớp mình |
| 34  | Cannot access unauthorized APIs | `AuthFilter` check role cho `/app/teacher/*` |
| 35  | Backend permission checks | `GradingServlet.doPost` kiểm tra role trước khi chấm |
| 36  | Cannot edit other users' data | `NotificationDAO.markRead(id, userId)` — chỉ đánh dấu của mình |

### D. Database / SQL (37-50)

| #   | Tiêu chí | Triển khai |
|-----|----------|------------|
| 37  | Database runs successfully | `Spirit_GitAnalytics` trên `localhost\MAYAO` |
| 38  | Tables are logically designed | 14 bảng: User, Subject, Class, Assignment, Submission, Grade, Notification, OtpCode, Project, Student, TeamMember, CommitRecord, ContributionScore, AnalysisHistory |
| 39  | Primary Keys exist | Tất cả bảng có `*_id IDENTITY(1,1) PRIMARY KEY` |
| 40  | Foreign Keys are correct | `FK_*` cho tất cả quan hệ (Assignment → ClassRoom, Submission → Assignment, Grade → Submission...) |
| 41  | Relationships are correct | 1-n: Class→Assignment, Assignment→Submission, Submission→Grade. n-n: Student↔Class (qua Enrollment) |
| 42  | Reasonable data types | `INT` cho ID, `VARCHAR(20-500)` cho code/path, `NVARCHAR` cho tên VN, `DECIMAL(5,2)` cho score |
| 43  | NOT NULL used correctly | `username`, `email`, `role`, `score` đều NOT NULL |
| 44  | UNIQUE used correctly | `username`, `email`, `class_code`, `subject_code`, `(class_id, student_id)` enrollment |
| 45  | No unnecessary data duplication | Dùng JOIN thay vì denormalize |
| 46  | Sample data exists | bootstrap.sql + grading_schema.sql chèn dữ liệu mẫu |
| 47  | Queries work | Tất cả DAO test thành công |
| 48  | Inserts work | `RegisterServlet`, `SubmissionServlet`, `AssignmentServlet` |
| 49  | Updates work | `ProfileServlet`, `AssignmentServlet.update` |
| 50  | Deletes work | `AssignmentServlet.delete`, `NotificationServlet.delete` |

### E. Backend / API (51-65)

| #   | Tiêu chí | Triển khai |
|-----|----------|------------|
| 51  | Backend runs without errors | BUILD SUCCESS, Jetty started, tất cả endpoint 200/302/403 |
| 52  | API GET | `LoginServlet.doGet`, `AssignmentServlet.doGet`, v.v. |
| 53  | API POST | `LoginServlet.doPost`, `RegisterServlet.doPost`, `SubmissionServlet.doPost`, `GradingServlet.doPost` |
| 54  | API PUT/PATCH | (Servlet không hỗ trợ PUT native nhưng dùng action=update trong POST) |
| 55  | API DELETE | `AssignmentServlet` delete via `action=delete` POST |
| 56  | Correct HTTP status codes | 200 OK, 302 redirect, 403 forbidden, 404 not found, 500 error page |
| 57  | Response has clear structure | HTML response với Bootstrap layout, error/success message rõ ràng |
| 58  | Validate requests | `RegisterServlet` validate username, email, password, role |
| 59  | Exception handling | `catch (SQLException \| ClassNotFoundException)` trong mỗi servlet |
| 60  | Do not return stack trace to users | `error.jsp` chỉ hiển thị message gọn, `web.xml` error-page mapping |
| 61  | APIs require authentication | `AuthFilter` bảo vệ `/app/*` |
| 62  | APIs check authorization | `GradingServlet` kiểm tra role TEACHER |
| 63  | No hard-coded secrets | Password đọc từ `DBConnection.java` env, có thể đổi qua `Spirit_DB_PASS` |
| 64  | Environment variables used | `getOrDefault("Spirit_DB_HOST", ...)` — ưu tiên env |
| 65  | API does not crash on invalid input | Validation trước khi query, try-catch wrap DAO |

### F. CRUD (66-73)

| Entity | Create | Read | Update | Delete | Search | Filter | Sort | Pagination |
|--------|:------:|:----:|:------:|:------:|:------:|:------:|:----:|:----------:|
| AppUser | ✅ RegisterServlet | ✅ findByUsername/Id/Email | ✅ ProfileServlet | ❌ | ✅ | ❌ | ❌ | ❌ |
| Subject | ❌ (admin only) | ✅ SubjectListServlet | ❌ | ❌ | ❌ | ❌ | ✅ ORDER BY code | ❌ |
| ClassRoom | ❌ (admin only) | ✅ DashboardServlet | ❌ | ❌ | ❌ | ✅ byTeacher/byStudent | ✅ ORDER BY id DESC | ❌ |
| Assignment | ✅ AssignmentServlet | ✅ findAll/byClass/byStudentClasses | ✅ AssignmentServlet | ✅ | ❌ | ✅ byClass | ✅ ORDER BY due_date | ❌ |
| Submission | ✅ SubmissionServlet | ✅ findById/byAssignmentAndStudent/byAssignment/byStudent | ✅ SubmissionServlet | ❌ | ❌ | ✅ byAssignment/byStudent | ✅ ORDER BY submitted_at | ❌ |
| Grade | ✅ GradingServlet (upsert) | ✅ findBySubmission | ✅ GradingServlet (upsert) | ❌ | ❌ | ❌ | ❌ | ❌ |
| Notification | ✅ NotificationDAO.insert (tự động) | ✅ NotificationServlet | ✅ markRead | ✅ | ❌ | ❌ | ✅ ORDER BY created_at DESC | ✅ TOP 100 |

### G. Security (74-82)

| #   | Tiêu chí | Triển khai |
|-----|----------|------------|
| 74  | Prevent SQL Injection | **100% dùng PreparedStatement**, không có string concat SQL |
| 75  | Prevent XSS | JSTL `<c:out>` escape HTML output, hoặc cẩn thận với `${...}` |
| 76  | Validate frontend input | HTML5 `required`, `minlength`, `pattern` trong form |
| 77  | Validate backend input | `RegisterServlet`, `SubmissionServlet`, `GradingServlet` check input |
| 78  | Password hashing | BCrypt cost 10 (`SecurityUtil.hashPassword`) |
| 79  | Do not commit .env | Repo không có file `.env`, config qua env vars + `database/connection.properties` (gitignored) |
| 80  | No API keys in source code | Không có API key nào trong source |
| 81  | Do not expose database credentials | Trang lỗi 500 chỉ hiển thị message chung, không in connection string |
| 82  | Backend permission checks | `AuthFilter` + `GradingServlet` kiểm tra role |

### H. Testing (83-92)

| #   | Tiêu chí | Kết quả test |
|-----|----------|--------------|
| 83  | Empty forms | Form `required` HTML5 chặn submit, server trả error message |
| 84  | Invalid emails | `RegisterServlet` regex check → "Email không hợp lệ" |
| 85  | Incorrect passwords | "Sai mật khẩu" alert |
| 86  | Negative numbers | `GradingServlet` check `score < 0` |
| 87  | Text too long | `maxlength` HTML5 + DB column size limit |
| 88  | Special characters | BCrypt hash mọi ký tự, JSTL `<c:out>` escape HTML |
| 89  | Non-existent IDs | DAO trả null → servlet 404 "Assignment không tồn tại." |
| 90  | Delete referenced data | FK constraint chặn, ví dụ không xoá được Assignment có Submission |
| 91  | Database offline | Connection timeout sẽ trả 500 + error page |
| 92  | API errors | Try-catch trong servlet + error.jsp page |

### I. Git / Deploy / Documentation (93-100)

| #   | Tiêu chí | Triển khai |
|-----|----------|------------|
| 93  | Project pushed to Git | (Sẵn sàng push lên origin) |
| 94  | Correct .gitignore | `target/`, `*.class`, `*.log`, `*.war` |
| 95  | README with run instructions | File này |
| 96  | Database setup instructions | "Chạy nhanh" section phía trên |
| 97  | Demo accounts | `teacher1` / `student1` / `Password@123` |
| 98  | Production runs successfully | Jetty chạy ổn định trên port 8080 |
| 99  | No severe console errors | Chỉ có warning JSTL double-classpath (không ảnh hưởng) |
| 100 | Can clone → setup → run successfully | 3 bước: install Maven, run SQL scripts, `mvn jetty:run-war` |

---

## 📁 Cấu trúc dự án

```
Group5_GitAnalytics/
├── src/main/java/com/Spirit/gitanalytics/
│   ├── controller/      # Servlets: Login, Register, Logout, Dashboard, SubjectList,
│   │                    # Assignment, AssignmentDetail, Submission, Grading, Notification, Profile
│   ├── dao/             # AppUser, Subject, ClassRoom, Assignment, Submission, Grade, Notification, OtpCode
│   ├── service/         # EmailService, DeadlineScheduler, AnalyticsService, GitAnalyzer
│   ├── model/           # AppUser, Subject, ClassRoom, Assignment, Submission, Grade, Notification, OtpCode
│   ├── filter/          # CharacterEncodingFilter, AuthFilter
│   ├── listener/        # AppContextListener (start DeadlineScheduler)
│   └── util/            # DBConnection, SecurityUtil
├── WebContent/
│   ├── index.jsp        # Redirect về login/dashboard
│   ├── css/app.css      # Custom styles + responsive
│   ├── js/dashboard.js
│   ├── jsp/             # login, register, otp, dashboard, subjects, assignments,
│   │                    # assignment-detail, submit, grade, notifications, profile, error
│   └── WEB-INF/web.xml  # Filter + listener + error page mapping
└── database/
    ├── schema.sql              # Git analytics tables
    ├── grading_schema.sql      # Grading module tables + sample data
    ├── bootstrap.sql           # DB create + full schema
    └── connection.properties   # Connection config (gitignored)
```

## 🔧 Endpoints chính

| URL                                       | Method | Role         | Mô tả |
|-------------------------------------------|--------|--------------|-------|
| `/gitanalytics/login`                     | GET/POST | public    | Đăng nhập |
| `/gitanalytics/register`                  | GET/POST | public    | Đăng ký + OTP |
| `/gitanalytics/logout`                    | GET   | any          | Đăng xuất |
| `/gitanalytics/app/dashboard`             | GET   | any          | Dashboard theo role |
| `/gitanalytics/app/subjects`              | GET   | STUDENT      | Danh sách môn học |
| `/gitanalytics/app/assignments`           | GET/POST | TEACHER (POST) | CRUD bài tập |
| `/gitanalytics/app/assignments/detail`    | GET   | any          | Chi tiết bài tập |
| `/gitanalytics/app/submissions`           | GET/POST | STUDENT (POST) | Nộp / sửa bài |
| `/gitanalytics/app/teacher/grading`       | GET/POST | TEACHER (POST) | Chấm điểm |
| `/gitanalytics/app/notifications`         | GET/POST | any          | Thông báo |
| `/gitanalytics/app/profile`               | GET/POST | any          | Hồ sơ + đổi mật khẩu |
| `/gitanalytics/projects`                  | GET   | any          | Git analytics projects list (giữ nguyên) |

## 🛠 Công nghệ

- **Backend**: Java 8 + Servlet/JSP (MVC2) + JDBC
- **Build**: Maven 3.9.9 + WAR packaging
- **Server**: Jetty 9.4.51 (embedded via `jetty-maven-plugin`)
- **Database**: SQL Server (localhost,1433)
- **Hashing**: jBCrypt 0.4
- **Frontend**: Bootstrap 5.3 + Bootstrap Icons + Chart.js
- **Background**: `ScheduledExecutorService` cho deadline reminder
- **Logging**: SLF4J + slf4j-simple
