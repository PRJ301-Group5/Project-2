# Spirit - Git Analytics Teamwork Assessor

## 🚀 Quick Start (đã test thành công trên máy local)

### Yêu cầu (đã cài)
- ✅ **JDK 8** tại `C:\Program Files\Java\jdk1.8.0_202`
- ✅ **Maven 3.9.9** tại `C:\Program Files\apache-maven-3.9.9`
- ✅ **sqlcmd** tại `C:\Program Files\SqlCmd\sqlcmd.exe`
- ✅ **SQL Server** (instance MAYAO, port 1433, đã cấu hình)
- ✅ **Git** cho demo repo tại `C:\repos\Spirit-demo`

### Connection SQL (đã verify)

```
Host:     localhost
Port:     1433
Database: Spirit_GitAnalytics
User:     spirit_user
Password: Spirit@2024!
```

### Cài đặt

**Bước 1: Tạo SQL login + database** (chỉ chạy 1 lần đầu)
```powershell
sqlcmd -S localhost -E -Q "CREATE LOGIN spirit_user WITH PASSWORD = 'Spirit@2024!'; ALTER SERVER ROLE [sysadmin] ADD MEMBER [spirit_user];"
sqlcmd -S localhost -E -i database\bootstrap.sql
sqlcmd -S localhost -E -Q "USE Spirit_GitAnalytics; CREATE USER [spirit_user] FOR LOGIN [spirit_user]; ALTER ROLE [db_owner] ADD MEMBER [spirit_user];"
```

**Bước 2: Tạo Git demo repo** (nếu chưa có)
```bash
# 9 commits mẫu với 5 author khác nhau
# Xem: C:\repos\Spirit-demo\.git
```

**Bước 3: Build & Run**
```powershell
mvn clean package -DskipTests
mvn jetty:run-war
```

**Bước 4: Mở browser**
- http://localhost:8080/gitanalytics/

### 📊 Demo flow
1. Mở `/projects` → thấy `PRJ301_G5` (1 project)
2. Click **⚙ Analyze** → JGit đọc 9 commits, save vào DB
3. Tự động redirect sang `/dashboard` → thấy 5 thành viên với Pie + Bar chart
4. Click **⬇ Export CSV** → download `contribution_1.csv`
5. Click **📝 Commits** → xem chi tiết 9 commits, badge ✓ cho commit đã map được member

### 🗄️ Đồng bộ SQL ↔ IDE

**Trong Cursor IDE:**
- Cài extension `ms-mssql.mssql`
- Mở **SQL Server** panel (icon database bên trái)
- Add connection:
  - Server: `localhost`
  - Auth: SQL Login
  - User: `spirit_user`
  - Password: `Spirit@2024!`
  - Database: `Spirit_GitAnalytics`
  - Encrypt: Optional (False)

**Trong SSMS (đã có sẵn trên máy):**
- Server name: `localhost`
- Authentication: SQL Server Authentication
- Login: `spirit_user`
- Password: `Spirit@2024!`

**Bằng sqlcmd (PowerShell):**
```powershell
sqlcmd -S localhost -E -d Spirit_GitAnalytics -Q "SELECT * FROM Project"
```

### Các URL

| URL | Mô tả |
|---|---|
| `/` | Trang chủ |
| `/projects` | Danh sách project |
| `/dashboard?projectId=1` | Dashboard Pie/Bar chart + Bảng điểm |
| `/commits?projectId=1` | Lịch sử commits chi tiết |
| `/export.csv?projectId=1` | Download CSV báo cáo |
| `POST /analyze?projectId=1` | Trigger phân tích Git → DB |

### Công thức chấm điểm

- `N` = tổng thành viên
- `fairShare = 100 / N`
- `contribution_pct_i = (lines_added_i / total_lines) * 100`
- `fairness_score_i = max(0, 100 - |pct_i - fairShare| * 1.5)`

**Status:**
- `LOW`   ← `pct < 10%`         (free-rider)
- `HIGH`  ← `pct > 2 * fairShare` (gánh team)
- `NORMAL` ← còn lại
