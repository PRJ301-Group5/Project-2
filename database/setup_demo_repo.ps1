-- =============================================================
-- Spirit - Setup demo Git repo (chỉ dùng trên Windows)
-- Chạy script này 1 LẦN để tạo local Git repo ở C:\repos\Spirit-demo
-- mà AnalyticsService sẽ đọc khi user bấm "Analyze".
-- =============================================================
-- Prerequisites: Git for Windows đã cài.
-- Chạy: powershell -ExecutionPolicy Bypass -File .\setup_demo_repo.ps1
-- =============================================================

$demoPath = "C:\repos\Spirit-demo"
if (Test-Path $demoPath) {
    Write-Host ">> Repo đã tồn tại: $demoPath"
    exit 0
}

New-Item -ItemType Directory -Force -Path $demoPath | Out-Null
Set-Location $demoPath
git init -b main | Out-Null
git config user.name  "Demo User"
git config user.email "demo@spirit.local"

# Commit 1 (initial)
"# Spirit Demo"                       | Set-Content "README.md"
"// entry point"                       | Set-Content "src\index.js"
git add . ; git commit -m "Initial commit" | Out-Null

# 6 commits giả lập 3 thành viên
$members = @(
    @{n="Nguyễn Văn An";       e="an.nguyenvan@email.com"},
    @{n="Trần Thị Bình";       e="binh.tran@email.com"},
    @{n="Lê Hoàng Cường";      e="cuong.le@email.com"},
    @{n="Phạm Thị Dung";       e="dung.pham@email.com"}
)
foreach ($m in $members) {
    git config user.name  $m.n
    git config user.email $m.e
    for ($k=1; $k -le 2; $k++) {
        Add-Content "src\index.js" "// Update by $($m.n) #$k"
        Add-Content "README.md"    "- Note by $($m.n) #$k"
        git add . ; git commit -m "Update by $($m.n) #$k" | Out-Null
    }
}

Write-Host ">> Created demo repo at $demoPath"
git log --oneline
