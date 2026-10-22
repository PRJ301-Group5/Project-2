# Spirit — Hướng dẫn cập nhật Database

Chạy theo thứ tự với **Windows Auth** (Trusted connection):

```powershell
sqlcmd -S localhost -E -b -i database\bootstrap.sql
sqlcmd -S localhost -E -b -i database\grading_schema.sql
sqlcmd -S localhost -E -b -i database\migrations\002_file_upload_and_classes.sql
sqlcmd -S localhost -E -b -i database\migrations\003_full_seed.sql
sqlcmd -S localhost -E -b -i database\migrations\004_per_subject_assignments.sql
sqlcmd -S localhost -E -b -i database\migrations\005_submission_artifact.sql
sqlcmd -S localhost -E -b -i database\migrations\006_login_history.sql
```

> **Lưu ý:** `004_per_subject_assignments.sql` có `DELETE` cứng ở đầu script (wipe assignment + submission + grade để re-seed).
> **Không chạy lại** trên DB đang có dữ liệu demo. Nếu cần khôi phục dữ liệu demo đã bị wipe, chạy:
> ```powershell
> sqlcmd -S localhost -E -b -d Spirit_GitAnalytics -i database\migrations\007_restore_demo_data.sql
> ```

Sau khi chạy, **bắt buộc đổi mật khẩu demo** vì `003_full_seed.sql` chèn hash BCrypt placeholder. Chạy lệnh này để set đúng hash cho `Password@123`:

```sql
-- 1) Generate hash: chạy GenHash.java trong C:\tmp (BCrypt.gensalt(10) + "Password@123")
-- 2) Copy hash rồi chạy:
USE Spirit_GitAnalytics;
UPDATE AppUser SET password_hash = '<paste hash vào đây>'
WHERE username IN ('admin','teacher1','teacher2','student1','student2','student3','student4','student5','student6');
```

> Hoặc đăng ký tài khoản mới qua `/register` rồi set role bằng SQL.

## Trạng thái DB sau khi chạy hết

| Table | Rows |
|---|---|
| AppUser | 9 (admin + 2 teachers + 6 students) |
| Subject | 6 (PRJ301, ANC111, ABC222, LAB211, CSD201, SWR302) |
| ClassRoom | 3 (PRJ301_G5_S2026, CSD201_G1_S2026, SWR302_G1_S2026) |
| Enrollment | 9 |
| Assignment | 9 (3 / lớp × 3 lớp) |
| AssignmentFile | 27 (3 / bài × 9 bài) |
| Submission | 0 |
| SubmissionFile | 0 |
| Grade | 0 |
| Project (git analytics) | 1 |
| Student (git analytics) | 5 |
| TeamMember | 5 |
| CommitRecord | 7 |
| ContributionScore | 5 |
| AnalysisHistory | 0 |
| ExportHistory | 3 |
| SubmissionArtifact | 0 (tự sinh khi sinh viên nộp bài) |
| LoginHistory | 0 (tự sinh khi có đăng nhập) |

## Tài khoản demo

Password: **`Password@123`** (sau khi đã update hash ở bước trên)

| Username | Role | Lớp phụ trách / tham gia |
|---|---|---|
| `admin` | ADMIN | Tất cả |
| `teacher1` | TEACHER | PRJ301, SWR302 |
| `teacher2` | TEACHER | CSD201 |
| `student1`, `student2`, `student3` | STUDENT | PRJ301 + CSD201 |
| `student4`, `student5`, `student6` | STUDENT | SWR302 |

## Mã lớp để student join

- `PRJ301_G5_S2026`
- `CSD201_G1_S2026`
- `SWR302_G1_S2026`

## Connection string

`database/connection.properties` đã trỏ về:
```
server=localhost
port=1433
auth=sql
user=spirit_user
password=Spirit@2024!
database=Spirit_GitAnalytics
```

JDBC URL (trong code):
```
jdbc:sqlserver://localhost:1433;databaseName=Spirit_GitAnalytics;encrypt=false;trustServerCertificate=true;
```
