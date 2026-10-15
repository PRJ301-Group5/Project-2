# Kiến trúc hệ thống - Spirit Group 5

## 1. Tổng quan
Module **Git Analytics Teamwork Assessor** thuộc dự án Spirit (PRJ301 - Group 5).
Đóng góp điểm để chống **free-riding** trong dự án nhóm thông qua phân tích lịch sử Git.

## 2. Use-Case Diagram
```
                     ┌─────────────────────┐
                     │     Lecturer         │
                     └──────────┬──────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
   Create Project         Run Analyze            View Dashboard
        │                       │                       │
        ▼                       ▼                       ▼
   ProjectDAO          AnalyticsService          DashboardServlet
                              │
                              │ (JGit)
                              ▼
                          ┌──────┐
                          │  Git  │
                          │ Repo  │
                          └──────┘
```

## 3. ERD
```
┌──────────────┐         ┌────────────────┐         ┌──────────────┐
│   Project    │ 1     N │   TeamMember   │ N     1 │   Student    │
└──────────────┘─────────└────────────────┘─────────└──────────────┘
                              │
                              │ 1
                              ▼ N
                       ┌────────────────┐         ┌─────────────────┐
                       │ CommitRecord   │  N   1  │ ContributionSco.│
                       └────────────────┘─────────└─────────────────┘
```

## 4. Flow Analyze (Moulinette-style)

```
[Lecturer click "Analyze"]
        │
        ▼
[AnalyzeServlet.doPost]
        │
        ▼
[AnalyticsService.analyzeProject]
        │
        ├─→ ProjectDAO.findById
        ├─→ GitAnalyzer.openRepository   (JGit)
        ├─→ GitAnalyzer.fetchCommits     (loop RevCommit)
        │       └─ linesAdded/deleted via DiffFormatter
        ├─→ TeamMemberDAO.findByProject   (map email → member)
        ├─→ CommitRecordDAO.saveBatch    (batch 100)
        ├─→ Aggregate per-member (commits, lines, activeDays)
        ├─→ Compute:
        │      • contribution_pct  = lines / total * 100
        │      • fairness_score    = 100 - |pct - fairShare|*1.5
        │      • status: LOW < 10% < NORMAL < 2x fairShare = HIGH
        └─→ ContributionScoreDAO.upsert   (MERGE)
                              │
                              ▼
                     [DashboardServlet → dashboard.jsp]
                              │
                              ▼
                     Chart.js pie + bar
```

## 5. Công thức chấm điểm

- `N` = tổng số thành viên trong team
- `fairShare = 100 / N`
- `commitLines_i` = tổng `lines_added` của member `i`
- `totalLines = Σ commitLines_i` (trên tất cả members)

```
contribution_pct_i = (commitLines_i / totalLines) * 100      // %
fairness_score_i  = max(0, 100 - |contribution_pct_i - fairShare| * 1.5)
```

**Status logic:**
- `LOW`: `contribution_pct < 10%`  → có thể free-riding
- `HIGH`: `contribution_pct > 2 * fairShare` → gánh team
- `NORMAL`: còn lại

## 6. Bảo mật

- SQL Server: dùng stored procedure account riêng
- Passwords: BCrypt với salt rounds = 10
- Filter: `CharacterEncodingFilter` ép UTF-8
- Shell-injection: không chạy shell, JGit API chỉ đọc metadata

## 7. Tham khảo

- JGit docs: https://.eclipse-jgit.github.io/jgit/
- MVC2 pattern: PRJ301 syllabus
- Spirit syllabus (RBL §42 philosophy)
