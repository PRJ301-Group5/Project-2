# Database Operations Map — Spirit Git Analytics

Tài liệu này liệt kê **mọi thao tác ghi/đọc database** trong code, ánh xạ theo luồng người dùng.

> **Mặc định tất cả DAO đều mở connection qua `util/DBConnection.getConnection()`**
> → `jdbc:sqlserver://localhost:1433;databaseName=Spirit_GitAnalytics;…` (SQL auth, user `spirit_user`).

---

## 🔐 1. Đăng nhập

**URL:** `POST /login`
**File:** `controller/LoginServlet.java`
**DAO:** `AppUserDAO`

```sql
-- AppUserDAO.findByUsername (line 20)
SELECT user_id, username, password_hash, full_name, email, phone, role, is_active, created_at
FROM AppUser WHERE username = ?
```

**Flow:**
1. Đọc `AppUser` theo `username`
2. Verify `password_hash` bằng BCrypt (`SecurityUtil.verifyPassword`)
3. Lưu user vào `HttpSession` (KHÔNG ghi `last_login` xuống DB)
4. Session timeout: 30 phút

> ⚠️ **Đề xuất:** thêm cột `last_login_at` + cập nhật mỗi lần login thành công (hiện chưa có).

---

## 📝 2. Đăng ký (OTP 2 bước)

**URL:** `POST /register` (action=verify để confirm OTP, mặc định = gửi OTP)
**File:** `controller/RegisterServlet.java`
**DAO:** `OtpCodeDAO`, `AppUserDAO`, `EmailService`

### Bước 1 — gửi OTP
```sql
-- OtpCodeDAO.insert (line 15)
INSERT INTO OtpCode(target, purpose, code, expires_at) VALUES(?,?,?,?)
-- purpose = 'REGISTER', expires_at = NOW + 5 min
```
- Mã 6 số random → `EmailService.sendOtp()` → in ra console (chưa gắn SMTP thật)
- Check trùng trước khi gửi:
  ```sql
  SELECT user_id FROM AppUser WHERE username = ?   -- AppUserDAO.findByUsername
  SELECT user_id FROM AppUser WHERE email    = ?   -- AppUserDAO.findByEmail
  ```

### Bước 2 — xác thực OTP và tạo user
```sql
-- OtpCodeDAO.findValid (line 35)
SELECT TOP 1 otp_id, target, purpose, code, expires_at, is_used, created_at
FROM OtpCode
WHERE target = ? AND purpose = ? AND code = ?
  AND is_used = 0 AND expires_at > GETDATE()
ORDER BY created_at DESC

-- AppUserDAO.insert (line 87)
INSERT INTO AppUser(username, password_hash, full_name, email, phone, role)
VALUES(?,?,?,?,?,?)
-- role: 'TEACHER' hoặc 'STUDENT' (ADMIN không cho tự đăng ký)

-- OtpCodeDAO.markUsed (line 60)
UPDATE OtpCode SET is_used = 1 WHERE otp_id = ?
```

---

## 👤 3. Cập nhật hồ sơ & đổi mật khẩu

**URL:** `POST /app/profile` (action=`updateInfo` | `changePassword`)
**File:** `controller/ProfileServlet.java`
**DAO:** `AppUserDAO`

```sql
-- AppUserDAO.updateInfo (line 118)
UPDATE AppUser SET full_name = ?, phone = ? WHERE user_id = ?

-- AppUserDAO.updatePassword (line 107)
UPDATE AppUser SET password_hash = ? WHERE user_id = ?
```

> 🐛 **BUG phát hiện ở `ProfileServlet.java` line 39:**
> ```java
> userDAO.updatePassword(user.getUserId(), user.getPasswordHash()); // placeholder
> userDAO.updateInfo(user);
> ```
> Dòng `updatePassword` thừa và ghi đè hash cũ bằng chính nó (không đổi). Cần xoá dòng này.

---

## 📚 4. Tạo / sửa / xoá lớp học (Teacher)

**URL:** `POST /app/classes` (action=`create` | `update` | `delete`)
**File:** `controller/ClassRoomServlet.java`
**DAO:** `ClassRoomDAO`, `SubjectDAO`

```sql
-- ClassRoomDAO.insert (line 84)
INSERT INTO ClassRoom(subject_id, teacher_id, class_code, class_name, semester, description, join_enabled)
VALUES(?,?,?,?,?,?,?)

-- ClassRoomDAO.update (line 102)
UPDATE ClassRoom
SET subject_id=?, class_code=?, class_name=?, semester=?, description=?, join_enabled=?
WHERE class_id=?

-- ClassRoomDAO.delete (line 120)
DELETE FROM ClassRoom WHERE class_id = ?
```

**GET (form):**
```sql
-- ClassRoomDAO.findById, findByCode, findByTeacher, findAll
SELECT c.*, s.subject_code, s.subject_name, u.full_name AS teacher_name,
       (SELECT COUNT(*) FROM Enrollment e WHERE e.class_id = c.class_id) AS student_count
FROM ClassRoom c
JOIN Subject s ON c.subject_id = s.subject_id
JOIN AppUser u ON c.teacher_id = u.user_id
WHERE …
```

---

## 👥 5. Student join/leave lớp

**URL:** `POST /app/enroll` (action=`join` | `leave`), `GET /app/enroll?action=search&code=…`
**File:** `controller/EnrollmentServlet.java`
**DAO:** `ClassRoomDAO`, `NotificationDAO`

```sql
-- 1. Tìm lớp theo class_code
SELECT … FROM ClassRoom c JOIN Subject s … JOIN AppUser u …
WHERE UPPER(c.class_code) = UPPER(?)

-- 2. Check đã enroll chưa
SELECT 1 FROM Enrollment WHERE class_id = ? AND student_id = ?

-- 3. Insert enrollment
INSERT INTO Enrollment(class_id, student_id) VALUES(?,?)

-- 4. Leave
DELETE FROM Enrollment WHERE class_id = ? AND student_id = ?
```

**Sau khi join thành công → 1 row Notification cho teacher:**
```sql
-- NotificationDAO.insert (line 43)
INSERT INTO Notification(user_id, title, body, link) VALUES(?,?,?,?)
-- title: "Sinh viên mới vào lớp"
```

---

## ✏️ 6. CRUD bài tập (Teacher)

**URL:** `POST /app/assignments` (action=`create` | `update` | `delete`)
**File:** `controller/AssignmentServlet.java`
**DAO:** `AssignmentDAO`, `AssignmentFileDAO`, `FileUploadUtil`

```sql
-- AssignmentDAO.insert (line 75)
INSERT INTO Assignment(class_id, title, description, prompt_file, due_date, max_score, created_by)
VALUES(?,?,?,?,?,?,?)
-- created_at auto = GETDATE()

-- AssignmentDAO.update (line 90)
UPDATE Assignment
SET title=?, description=?, prompt_file=?, due_date=?, max_score=?
WHERE assignment_id=?

-- AssignmentDAO.delete (line 108)
DELETE FROM Assignment WHERE assignment_id = ?
```

**Upload file đính kèm (multi-file):**
```sql
-- AssignmentFileDAO.insert (line 18)
INSERT INTO AssignmentFile(assignment_id, file_name, stored_name, file_path, file_size, content_type, uploaded_by)
VALUES(?,?,?,?,?,?,?)
```

**File vật lý** lưu ở `uploads/assignments/{uuid}_{originalName}` — xem `util/FileUploadUtil.java:102`

---

## 📤 7. Nộp bài (Student)

**URL:** `POST /app/submissions?assignmentId={id}`
**File:** `controller/SubmissionServlet.java`
**DAO:** `SubmissionDAO`, `SubmissionFileDAO`, `NotificationDAO`, `AssignmentFileDAO`

```sql
-- 1. Check deadline (đọc Assignment)
SELECT a.due_date, a.class_id, a.title FROM Assignment a WHERE assignment_id = ?

-- 2. Insert submission (lần đầu)
INSERT INTO Submission(assignment_id, student_id, content, file_path)
VALUES(?,?,?,?)
-- submitted_at auto = GETDATE()

-- Hoặc UPDATE nếu đã nộp rồi:
UPDATE Submission SET content=?, file_path=? WHERE submission_id=?
```

**Upload file bài làm:**
```sql
-- SubmissionFileDAO.insert (line 18)
INSERT INTO SubmissionFile(submission_id, file_name, stored_name, file_path, file_size, content_type)
VALUES(?,?,?,?,?,?)
```

**Sau khi nộp lần đầu → 1 Notification cho teacher:**
```sql
INSERT INTO Notification(user_id, title, body, link) VALUES(?,?,?,?)
-- title: "Bài nộp mới: {assignment title}"
```

**File vật lý** lưu ở `uploads/submissions/{uuid}_{name}`.

---

## 💯 8. Chấm điểm (Teacher)

**URL:** `POST /app/teacher/grading?submissionId={id}`
**File:** `controller/GradingServlet.java`
**DAO:** `GradeDAO`, `NotificationDAO`, `AppUserDAO`, `EmailService`

```sql
-- GradeDAO.upsert (line 41) — INSERT nếu chưa có
INSERT INTO Grade(submission_id, grader_id, score, feedback) VALUES(?,?,?,?)

-- Hoặc UPDATE nếu đã chấm
UPDATE Grade
SET grader_id=?, score=?, feedback=?, graded_at=GETDATE()
WHERE grade_id=?
```

**Sau khi lưu điểm → Notification cho student + email:**
```sql
INSERT INTO Notification(user_id, title, body, link) VALUES(?,?,?,?)
-- title: "Đã có điểm: {assignment title}"
```
+ `EmailService.sendGradeNotice(student.email, title, score)` (console log, chưa SMTP thật).

---

## 🔔 9. Thông báo (Notification)

**URL:** `GET /app/notifications`, `POST /app/notifications` (action=`read` | `readAll` | `delete`)
**File:** `controller/NotificationServlet.java`
**DAO:** `NotificationDAO`

```sql
-- List
SELECT TOP (?) notification_id, user_id, title, body, link, is_read, created_at
FROM Notification WHERE user_id = ? ORDER BY created_at DESC

-- Đếm chưa đọc (badge top-bar)
SELECT COUNT(*) FROM Notification WHERE user_id = ? AND is_read = 0

-- Đánh dấu đã đọc
UPDATE Notification SET is_read = 1 WHERE notification_id = ? AND user_id = ?
UPDATE Notification SET is_read = 1 WHERE user_id = ?

-- Xoá
DELETE FROM Notification WHERE notification_id = ? AND user_id = ?
```

**Các nơi TỰ ĐỘNG insert Notification (6 chỗ):**

| Trigger | File | Title |
|---|---|---|
| Student join lớp | `EnrollmentServlet.java:99` | "Sinh viên mới vào lớp" → teacher |
| Student nộp bài lần đầu | `SubmissionServlet.java:103` | "Bài nộp mới: …" → teacher |
| Teacher chấm điểm | `GradingServlet.java:94` | "Đã có điểm: …" → student |
| Deadline sắp tới (<24h) | `DeadlineScheduler.java:73` | "Sắp đến hạn: …" → student |
| (Reserved) | — | — |

---

## 🐙 10. Phân tích Git (Analyze)

**URL:** `POST /analyze?projectId={id}`
**File:** `controller/AnalyzeServlet.java` → `service/AnalyticsService.java`
**DAO:** `ProjectDAO`, `TeamMemberDAO`, `CommitRecordDAO`, `ContributionScoreDAO`, `GitAnalyzer`

**Flow:**

### Step 1 — đọc project config
```sql
-- ProjectDAO.findById
SELECT project_id, repo_url, local_path, default_branch, created_at, last_analyzed_at
FROM Project WHERE project_id = ?
```

### Step 2 — mở repo bằng JGit, lấy commits (không đụng DB)
`GitAnalyzer.openRepository(localPath)` + `gitAnalyzer.fetchCommits(repo)`

### Step 3 — map author_email → team_member_id
```sql
-- TeamMemberDAO.findByProject
SELECT team_member_id, project_id, student_id, git_email, role
FROM TeamMember WHERE project_id = ?
```

### Step 4 — batch insert commits
```sql
-- CommitRecordDAO.saveBatch (line 22), batch=100
INSERT INTO CommitRecord(project_id, team_member_id, commit_hash, author_name, author_email,
                         commit_date, message, files_changed, lines_added, lines_deleted)
VALUES(?,?,?,?,?,?,?,?,?,?)
```

### Step 5 — tính score, MERGE
```sql
-- ContributionScoreDAO.upsert (line 19) — SQL Server MERGE
MERGE ContributionScore AS target
USING (SELECT ? AS project_id, ? AS team_member_id) AS source
ON target.project_id = source.project_id AND target.team_member_id = source.team_member_id
WHEN MATCHED THEN
  UPDATE SET total_commits=?, total_lines_added=?, total_lines_deleted=?,
             active_days=?, contribution_pct=?, fairness_score=?, status=?, last_analyzed=GETDATE()
WHEN NOT MATCHED THEN
  INSERT(project_id, team_member_id, total_commits, total_lines_added, total_lines_deleted,
         active_days, contribution_pct, fairness_score, status, last_analyzed)
  VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE());
```

**Công thức tính điểm (trong `AnalyticsService.java`):**
- `contribution_pct = (lines_added_member / total_lines) * 100`
- `fairness_score = 100 - |pct - 100/N| * 1.5` (clamp 0-100)
- `status`: LOW nếu pct < 10% · HIGH nếu pct > 2×(100/N) · NORMAL còn lại

---

## 📊 11. Export CSV + ExportHistory

**URL:** `GET /export.csv?projectId={id}`
**File:** `controller/ExportServlet.java`
**DAO:** `ExportHistoryDAO`, `AnalyticsService`

**Flow:**
1. Build CSV từ `ContributionScore` (gọi `AnalyticsService.getScores`)
2. Lưu file vật lý `C:\gitanalytics-exports\contribution_{id}_{ts}.csv` (UTF-8 BOM)
3. Ghi audit row:

```sql
-- ExportHistoryDAO.insert (line 19)
INSERT INTO ExportHistory (project_id, exported_by, file_name, file_path, file_bytes, row_count, exported_at)
VALUES (?, ?, ?, ?, ?, ?, GETDATE());
SELECT SCOPE_IDENTITY() AS id;
```

4. Stream file xuống response (`Content-Disposition: attachment`)

**Xem lịch sử export:**
**URL:** `GET /exports`
```sql
-- ExportHistoryDAO.listRecent (line 39)
SELECT … FROM ExportHistory
ORDER BY exported_at DESC
OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY
```

---

## ⏰ 12. Deadline Scheduler (background job)

**Khởi động:** `listener/AppContextListener.java` → `contextInitialized` → `DeadlineScheduler.start()`
**File:** `service/DeadlineScheduler.java`
**DAO:** `AssignmentDAO`, `ClassRoomDAO`, `NotificationDAO`, `EmailService`, `AppUserDAO`

**Loop:** chạy mỗi **60 phút** (delay đầu 30s).

**Mỗi vòng:**
```sql
-- 1. Lấy tất cả assignment
SELECT a.* FROM Assignment a ORDER BY a.due_date DESC

-- 2. Lọc deadline: 0 < hoursLeft < 24

-- 3. Lấy SV trong từng lớp
SELECT u.* FROM AppUser u
JOIN Enrollment e ON u.user_id = e.student_id
WHERE e.class_id = ?

-- 4. Insert notification mỗi SV
INSERT INTO Notification(user_id, title, body, link) VALUES(?,?,?,?)

-- 5. Gửi email nhắc nhở
EmailService.sendDeadlineReminder(email, title, deadline)
```

> ⚠️ **Code smell:** `DeadlineScheduler.java:90-110` đọc `AppUser` bằng raw JDBC thay vì gọi `AppUserDAO.findStudentsInClass()` — nên refactor.

---

## 📂 13. Download file đính kèm

**URL:** `GET /app/files?type=assignment&id={fileId}` hoặc `type=submission&id={fileId}`
**File:** `controller/FileDownloadServlet.java`
**DAO:** `AssignmentFileDAO`, `SubmissionFileDAO`

```sql
-- Tìm metadata
SELECT * FROM AssignmentFile WHERE file_id = ?
SELECT * FROM SubmissionFile  WHERE file_id = ?

-- Sau đó stream file từ disk, KHÔNG đụng DB thêm
```

**Authorization check** (không thêm SQL, chỉ check trong code):
- Assignment file: admin · teacher (của lớp đó) · student (đã enroll lớp đó)
- Submission file: admin · chính student đó · teacher (của lớp đó)

---

## 📋 Tổng kết: 16 bảng, 14 DAO

| Bảng | DAO chính | Hành động ghi | Hành động đọc |
|---|---|---|---|
| `AppUser` | `AppUserDAO` | INSERT (register), UPDATE (profile/pass) | SELECT (login, profile, list student) |
| `OtpCode` | `OtpCodeDAO` | INSERT (gửi), UPDATE `is_used` | SELECT (xác thực) |
| `Subject` | `SubjectDAO` | — | SELECT (form lớp) |
| `ClassRoom` | `ClassRoomDAO` | INSERT, UPDATE, DELETE | SELECT (find by id/code/teacher/all) |
| `Enrollment` | `ClassRoomDAO.enroll` | INSERT, DELETE | SELECT (isEnrolled, count) |
| `Assignment` | `AssignmentDAO` | INSERT, UPDATE, DELETE | SELECT (find by id/class/studentClasses/all) |
| `AssignmentFile` | `AssignmentFileDAO` | INSERT, DELETE | SELECT (find by id/assignment) |
| `Submission` | `SubmissionDAO` | INSERT, UPDATE, DELETE | SELECT (find by id/assignment+student/all) |
| `SubmissionFile` | `SubmissionFileDAO` | INSERT, DELETE | SELECT (find by id/submission) |
| `Grade` | `GradeDAO` | INSERT, UPDATE (upsert), DELETE | SELECT (find by submission) |
| `Notification` | `NotificationDAO` | INSERT (6 chỗ), UPDATE `is_read`, DELETE | SELECT (find by user, count unread) |
| `Project` | `ProjectDAO` | UPDATE `last_analyzed_at` | SELECT (find by id) |
| `TeamMember` | `TeamMemberDAO` | — | SELECT (find by project) |
| `CommitRecord` | `CommitRecordDAO` | BATCH INSERT | SELECT (find by project) |
| `ContributionScore` | `ContributionScoreDAO` | MERGE upsert | SELECT (find by project) |
| `ExportHistory` | `ExportHistoryDAO` | INSERT | SELECT (recent, by project) |

---

## 🐛 Issues tìm được khi rà code

| # | Vị trí | Vấn đề | Đề xuất |
|---|---|---|---|
| 1 | `ProfileServlet.java:39` | Gọi thừa `userDAO.updatePassword(userId, user.getPasswordHash())` với hash cũ | Xoá dòng đó |
| 2 | `LoginServlet.java` | Không ghi `last_login_at` | Thêm cột + UPDATE sau verify OK |
| 3 | `DeadlineScheduler.java:90-110` | Raw JDBC bỏ qua DAO layer | Refactor dùng `AppUserDAO.findStudentsInClass` |
| 4 | `ExportHistoryServlet.java:55-70` | Download cũ quét toàn bộ list 1000 row | Thêm `findById(int)` trong `ExportHistoryDAO` |
| 5 | `AnalyzeServlet` (không có) | Không tạo row `AnalysisHistory` | Thêm INSERT vào bảng `AnalysisHistory` (đã có schema) |
