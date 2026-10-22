# 🎬 Kịch bản Demo — Submission Portal 4.4.1 (ZIP) + 4.4.2 (SHA-256)

> **Mục tiêu buổi demo:** Chứng minh Submission Portal tự động **nén ZIP** và **xác thực SHA-256 bằng Filter** trước khi giảng viên tải bài.
> **Đối tượng:** Peer-Review 2 — giảng viên hướng dẫn kiểm tra tính chặt chẽ của mô hình MVC2 và khả năng bảo mật tầng Filter.
> **Thời lượng:** 6 phút trình bày + 3 phút Q&A.
> **Commit:** `4052bc8` — *feat(artifact): nén ZIP + SHA-256 + Filter xác thực (Tuần 4-6 / 4.4.1 + 4.4.2)*

---

## 0. Checklist trước khi demo

| # | Việc | Lệnh / Thao tác | ✔ |
|---|---|---|---|
| 1 | Jetty đang chạy | `mvn jetty:run` → mở `http://localhost:8080/gitanalytics/login` | ☐ |
| 2 | Có bài nộp mẫu | `sqlcmd -S localhost -E -d Spirit_GitAnalytics -Q "SELECT * FROM SubmissionArtifact"` | ☐ |
| 3 | Mở sẵn 2 tab trình duyệt | Tab A = **Student**, Tab B = **Teacher** (Incognito) | ☐ |
| 4 | Mở sẵn DevTools → Network | `F12` → tab **Network** → tick **Preserve log** | ☐ |
| 5 | Chuẩn bị file bài | 2 file `.java` + 1 `.md` trong thư mục `demo-files/` | ☐ |
| 6 | Tạo 1 file "xấu" để demo tamper | `demo-files/CHEAT.md` (file sẽ bị sửa khi trình bày) | ☐ |

### 0.1. Reset dữ liệu demo (tuỳ chọn — khuyến nghị)

Nếu muốn buổi demo bắt đầu sạch (không còn file rác từ lúc test):

```powershell
sqlcmd -S localhost -E -b -d Spirit_GitAnalytics -Q "SET NOCOUNT ON;
DELETE FROM dbo.SubmissionArtifact WHERE submission_id = 3;
DELETE FROM dbo.SubmissionFile   WHERE submission_id = 3;"
Remove-Item "uploads\artifacts\*.zip" -Force -ErrorAction SilentlyContinue
```

Sau khi reset, sinh viên sẽ nộp lại ở **Bước 3** và artifact được tạo mới từ đầu.

---

## 1. Dữ liệu demo (đã verify thật trên DB)

| Thành phần | Giá trị thực tế |
|---|---|
| **URL hệ thống** | `http://localhost:8080/gitanalytics` |
| **GV hướng dẫn** | `teacher1` / `Password@123` — Nguyễn Thị Lan (user_id = 1) |
| **Sinh viên** | `student1` / `Password@123` — Trần Văn Nam (user_id = 2) |
| **Bài tập demo** | Assignment #1 — *"Lab 1: Servlet Lifecycle"* — đề do `teacher1` — hạn 25/10/2026 — điểm tối đa 10.00 |
| **Submission demo** | submission_id = **3** (assignment 1 × student1) |
| **Artifact hiện có** | `sub_3_76ce3b66.zip` — 1.488 bytes — 5 file — SHA-256 `b74004abf0467969…` |

---

## 2. Dự kiến trình bày — Timeline

```
┌──────────────────────────────────────────────────────────────────┐
│  0:00 ─────────────── 0:30 │ 0:30 ───── 1:30 │ 1:30 ─── 3:00   │
│  A. Mở đầu & vấn đề        │  B. Kiến trúc  │  C. DEMO A: Nộp  │
│                           │     MVC2         │      → ZIP + hash │
├───────────────────────────┼──────────────────┼───────────────────┤
│  3:00 ─────── 4:30        │ 4:30 ── 5:30    │ 5:30 ─── 6:00    │
│  D. DEMO B: GV tải ZIP    │  E. DEMO C:     │  F. Đối chiếu    │
│     → Filter verify SHA   │     Tamper 403  │     rubric       │
└───────────────────────────┴──────────────────┴───────────────────┘
```

---

## A. Mở đầu & đặt vấn đề — `0:00 → 0:30`

**🎬 Hành động:** Đứng cạnh màn hình, chưa mở trình duyệt. Nhìn GV.

**🗣️ Lời thoại:**

> "Em xin phép bắt đầu phần **4.4.1 Submission Portal** và **4.4.2 — xác thực SHA-256 hash**.
>
> Vấn đề đặt ra cho nhóm em là: sinh viên nộp bài rồi, giảng viên tải file về để chấm. Nhưng giữa hai thời điểm đó, **file nằm trên server** — và bất kỳ ai có quyền ghi vào thư mục upload đều có thể thay đổi nó mà không ai hay biết.
>
> Nếu một sinh viên sửa bài sau khi nộp để 'cải thiện' bài đã chấm, thì giảng viên sẽ chấm nhầm một bài khác.
>
> Vì vậy em triển khai: **ngay lúc sinh viên nộp bài, hệ thống tự động nén toàn bộ file thành 1 file ZIP và tính SHA-256 của file ZIP đó**. Mỗi lần giảng viên tải, một **Filter** sẽ tính lại hash và so khớp. Lệch một byte là chặn — trả về 403.
>
> Em sẽ demo 3 kịch bản: nộp bài, giảng viên tải thành công, và cố tình sửa file để các em thấy hệ thống bắt được."

**💡 Nếu GV hỏi ngay:** *"Tại sao hash file ZIP mà không hash từng file?"*
→ Trả lời: vì ZIP là **snapshot đóng băng** toàn bộ bài nộp tại thời điểm nộp. Hash 1 file ZIP gộp được cả metadata (tên file, thứ tự entry, timestamp nén) vào 1 con số duy nhất, vừa đơn giản vừa phát hiện được mọi thay đổi.

---

## B. Kiến trúc MVC2 — `0:30 → 1:30`

**🎬 Hành động:** Mở file `ArtifactService.java` và `ArtifactFilter.java` trên IDE (đã mở sẵn 2 tab), hoặc vẽ tay trên bảng trắng.

**🗣️ Lời thoại:**

> "Về mặt MVC2, các em thấy request đi qua đúng chuỗi chuẩn. Em vẽ ngắn thôi ạ."

```
   Browser (student1)
        │  POST /app/submissions  (multipart/form-data)
        ▼
┌───────────────────────┐
│  CharacterEncodingFilter  (UTF-8)      ← web.xml, /*  map
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│  AuthFilter               (đăng nhập + role)   ← web.xml, /app/*
└───────────┬───────────┘
            ▼
┌───────────────────────────────────────────┐
│  SubmissionServlet        ← Controller        │
│    1. FileUploadUtil.saveFiles()            │
│         → uploads/submissions/{uuid}_{name}  │
│    2. sfDao.insert()                        │
│    3. ArtifactService.createArtifact()  ◄── MỚI
│         ├─ ZipOutputStream  → 1 file .zip    │
│         ├─ MessageDigest SHA-256            │
│         └─ DAO upsert  status = PENDING     │
└───────────────────────────────────────────┘
            ▼
   Response redirect → /app/assignments/detail?id=1
```

```
   Teacher bấm nút "ZIP"
        │  GET /app/artifact?submissionId=3
        ▼
┌───────────────────────┐
│  AuthFilter              (role check)       ← web.xml, /app/*
└───────────┬───────────┘
            ▼
┌───────────────────────────────────────────┐
│  ArtifactFilter           ◄── MỚI            │
│    1. artifactDao.findBySubmission(3)      │
│    2. MessageDigest → tính lại SHA-256      │
│    3. so khớp:                              │
│         khớp  → VERIFIED → chain.doFilter   │
│         lệch  → TAMPERED  → 403, DỪNG       │
│         mất   → MISSING   → 404, DỪNG        │
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│  ArtifactDownloadServlet  ← Controller       │
│    stream file ZIP ra browser               │
│    + header X-Spirit-SHA256 / Verified      │
└───────────────────────────────────────────┘
```

**🗣️ Lời thoại tiếp:**

> "Điểm quan trọng em muốn nhấn mạnh: **ArtifactFilter chặn request trước khi tới Servlet**. Nếu em đặt logic verify trong `ArtifactDownloadServlet.doGet()` thì vẫn chạy được, nhưng đó là **kiểm tra ở tầng Controller**, không phải Filter — và bỏ qua được nếu sau này có thêm endpoint khác cần verify.
>
> Filter nằm ở tầng trung gian nên áp dụng được cho **mọi** URL muốn bảo vệ, chỉ cần khai báo thêm trong `web.xml`."

**💡 Điểm cần nói thêm (nếu GV hỏi về "khả năng bảo mật tầng Filter"):**

| Cơ chế | Vị trí code |
|---|---|
| Chặn **trước** khi logic nghiệp vụ chạy | `ArtifactFilter` → `return` sớm, không gọi `chain.doFilter()` |
| Ép buộc xác thực bằng **cấu hình khai báo** | `web.xml` `<filter-mapping>` |
| Tách biệt Servlet ↫ Filter | `ArtifactDownloadServlet` **không tự tính hash** — chỉ đọc `req.getAttribute("artifact")` mà Filter đã đặt sẵn |

---

## C. DEMO A — Sinh viên nộp bài → tự động ZIP + SHA-256 — `1:30 → 3:00`

> **🎯 Mục tiêu:** Chứng minh **không có nút bấm nào cả** — chỉ cần nộp bài, ZIP và hash tự sinh ra.

### C1. Sinh viên đăng nhập

**🎬 Hành động:** Tab A → mở `http://localhost:8080/gitanalytics/login`

- Username: `student1`
- Password: `Password@123`
- → **Đăng nhập**

**🗣️ Lời thoại:** *"Em đăng nhập bằng tài khoản sinh viên `student1`."*

### C2. Mở form nộp bài

**🎬 Hành động:** Vào **Bài tập** → bấm **"Lab 1: Servlet Lifecycle"** → nút **"Nộp bài"**

URL sẽ là: `http://localhost:8080/gitanalytics/app/submissions?assignmentId=1`

**🗣️ Lời thoại:**
> "Đây là form nộp bài của Lab 1 — do chính em, `teacher1`, đặt ra, hạn 25/10. Em nộp một số file cho assignment này."

**📸 Ghi chú cho người quay video:** Có thể zoom vào **deadline** và **thanh file-drop** — cho thấy hệ thống đã có kiểm tra hạn nộp từ trước.

### C3. Chọn file và nộp

**🎬 Hành động:**
1. Kéo-thả **3 file** vào ô "Đính kèm file bài làm" (hoặc bấm để chọn):
   - `HelloServlet.java`
   - `web.xml`
   - `README.md`
2. Nhập nội dung: `Lab 1 - Servlet Lifecycle - nhóm 5`
3. Bấm **"Lưu bài nộp"**

**🗣️ Lời thoại:**
> "Em chọn 3 file rồi nộp. Em **không bấm gì thêm** — không có nút 'tạo ZIP', không có nút 'băm hash'. Vậy đây."

> ⚠️ **Dừng ở đây 1 nhịp** — để GV thấy hành động chỉ là "Lưu bài nộp".

### C4. Chứng minh hệ thống đã tự sinh ZIP + hash

**🎬 Hành động:** Mở **Terminal** (không cần click gì trên web), chạy:

```powershell
sqlcmd -S localhost -E -W -d Spirit_GitAnalytics -Q "SET NOCOUNT ON; SELECT submission_id, zip_stored_name, zip_size, file_count, verification_status, LEFT(sha256,32)+'...' AS sha256 FROM dbo.SubmissionArtifact WHERE submission_id = 3;"
```

**Kết quả mong đợi:**

```
submission_id  zip_stored_name    zip_size  file_count  verification_status  sha256
-------------  -----------------  --------  ----------  --------------------  --------------------------------
3              sub_3_76ce3b66.zip  1488      5          PENDING               b74004abf0467969...c381d2af
```

**🗣️ Lời thoại:**
> "Chỉ bằng một thao tác nộp bài, hệ thống đã tự sinh ra:
> - một **file ZIP** tên `sub_3_76ce3b66.zip` — lưu ở `uploads/artifacts/`,
> - **5 file** được nén vào trong đó,
> - kích thước **1.488 bytes**,
> - **SHA-256** 64 ký tự hex,
> - trạng thái khởi tạo `PENDING` — chờ lần tải đầu tiên để xác thực."

### C5. Xem ZIP thật + verify hash độc lập

**🎬 Hành động:**

```powershell
# 1) Xem file ZIP trên đĩa
Get-ChildItem uploads\artifacts\*.zip | Format-Table Name, Length

# 2) Mở xem bên trong ZIP
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead(
    (Get-ChildItem uploads\artifacts\*.zip | Select-Object -First 1).FullName)
$zip.Entries | Select-Object Name, Length, CompressedLength
$zip.Dispose()

# 3) Tính lại SHA-256 bằng công cụ của Windows — ĐỘC LẬP với server
Get-FileHash (Get-ChildItem uploads\artifacts\*.zip | Select-Object -First 1).FullName -Algorithm SHA256
```

**Kết quả mong đợi:**

```
Name                 Length  CompressedLength
----                 ------  ---------------
HelloServlet.java      1843            742
web.xml                 902            318
README.md               431            241
...

Algorithm  Hash                                                              Path
---------  ----                                                              ----
SHA256     B74004ABF0467969...C381D2AF   C:\...\uploads\artifacts\sub_3_76ce3b66.zip
```

**🗣️ Lời thoại:**
> "Em mở ZIP ra — bên trong đúng là 5 file em vừa nộp, giữ nguyên tên.
>
> Rồi em dùng **`Get-FileHash`** — công cụ có sẵn của Windows, **không đi qua code của nhóm em** — để tính lại SHA-256. Kết quả `B74004ABF0467969…` **trùng khớp** với giá trị trong DB.
>
> Đây là bằng chứng hash là thật, không phải con số bịa ra."

> 💡 **Mẹo:** Nếu GV muốn kiểm chéo, em có thể dùng `certutil -hashfile <file> SHA256` — cho ra cùng kết quả.

---

## D. DEMO B — Giảng viên tải ZIP, Filter xác thực — `3:00 → 4:30`

> **🎯 Mục tiêu:** Chứng minh Filter chạy, verify thành công, và **trả kèm hash trong HTTP header**.

### D1. Chuyển sang tài khoản giảng viên

**🎬 Hành động:** Chuyển sang **Tab B** (Incognito) → `http://localhost:8080/gitanalytics/login`

- Username: `teacher1`
- Password: `Password@123`

**🗣️ Lời thoại:**
> "Em chuyển sang tài khoản giảng viên — `teacher1`, chính là người đặt bài Lab 1 này."

### D2. Mở danh sách bài nộp

**🎬 Hành động:** **Bài tập** → **"Lab 1: Servlet Lifecycle"**

URL: `http://localhost:8080/gitanalytics/app/assignments/detail?id=1`

**📸 Ghi chú:** Chỉ vào **nút ZIP** màu xám cạnh từng bài nộp, và **12 ký tự đầu của SHA-256** hiển thị bên dưới.

**🗣️ Lời thoại:**
> "Ở danh sách bài nộp, mỗi sinh viên có một **nút ZIP** — bấm vào là tải **toàn bộ bài**, không phải tải từng file lẻ. Bên cạnh là **12 ký tự đầu của SHA-256** để em đối chiếu nhanh."

### D3. Bấm nút ZIP → xem Header xác thực

**🎬 Hành động:**
1. **F12** → tab **Network** → tick **Preserve log**
2. Bấm nút **ZIP**
3. Trong list request `artifact?submissionId=3` → **Headers** → **Response Headers**

**🗣️ Lời thoại:**
> "Kết quả tải về là `200 OK`. Giờ em mở **Response Headers** — đây là phần quan trọng:"

```
HTTP/1.1 200 OK
Content-Type: application/zip
Content-Disposition: attachment; filename="submission_3_Lab_1_Servlet_Lifecycle.zip"
X-Spirit-SHA256: b74004abf0467969...c381d2af      ← hash server xác nhận
X-Spirit-Verified: true                            ← Filter đã verify thành công
```

**🗣️ Lời thoại tiếp:**
> "Filter đã tính lại SHA-256 của file ZIP trên đĩa, so với hash lưu trong DB — **khớp** — nên mới cho phép tải. Bằng chứng là **hai header** em vừa thấy:
> - `X-Spirit-Verified: true` — đã xác thực,
> - `X-Spirit-SHA256` — giá trị hash mà server vừa kiểm chứng.
>
> Nhờ vậy **người tải file cũng biết được** hash chính thức từ server, không phải tự tin tưởng mình."

### D4. Xác nhận trạng thái DB đã được Filter cập nhật

**🎬 Hành động:** Quay lại Terminal:

```powershell
sqlcmd -S localhost -E -W -d Spirit_GitAnalytics -Q "SET NOCOUNT ON; SELECT submission_id, verification_status, verified_at FROM dbo.SubmissionArtifact WHERE submission_id = 3;"
```

**Kết quả mong đợi:**

```
submission_id  verification_status  verified_at
-------------  -------------------  --------------------------
3              VERIFIED             2026-10-19 13:15:35.687
```

**🗣️ Lời thoại:**
> "Trạng thái trong DB đã tự chuyển từ `PENDING` sang **`VERIFIED`**, kèm mốc thời gian `verified_at`. Đây là **audit trail** — ai tải file, lúc mấy giờ, đều có dấu vết."

---

## E. DEMO C — Cố tình sửa file → bị chặn 403 — `4:30 → 5:30`

> **🎯 Mục tiêu:** Đây là **khoảnh khắc "wow"** của buổi demo. Chứng minh cơ chế bảo mật thực sự chạy.

### E1. Tạo tình huống giả lập

**🎬 Hành động:** Quay lại **Tab A** (sinh viên), bấm **"Lưu bài nộp"** lần nữa với file mới `CHEAT.md` nội dung:

```markdown
# Đáp án đã sửa lại sau khi nộp
## Phần 2: kết quả đúng 100%
```

> *(Nội dung này mô phỏng hành vi gian lận — nhưng ở đây em tự thực hiện trên file **trên đĩa server**, không phải qua web, để mô phỏng kẻ tấn công sửa file trực tiếp.)*

**🗣️ Lời thoại:**
> "Bây giờ em sẽ **mô phỏng hành vi xấu**: giả sử có người sửa trực tiếp file trên server. Em thêm **1 byte** vào cuối file ZIP — thay đổi nhỏ nhất có thể, nhưng đủ để đổi hash."

### E2. Thực hiện tamper (ngoài web — như kẻ tấn công)

**🎬 Hành động:** Terminal:

```powershell
$zip = Get-ChildItem uploads\artifacts\sub_3_*.zip | Select-Object -First 1
Write-Host "Trước :" $zip.Length "bytes"
$b = [System.IO.File]::ReadAllBytes($zip.FullName)
[System.IO.File]::WriteAllBytes($zip.FullName, ($b + [byte]0xFF))
Write-Host "Sau   :" (Get-Item $zip.FullName).Length "bytes"
```

**Kết quả mong đợi:**

```
Trước : 1488 bytes
Sau   : 1489 bytes
```

**🗣️ Lời thoại:**
> "File giờ dài **1.489 bytes** thay vì 1.488 — chỉ thêm **đúng 1 byte**. Không ai nhìn thấy khác biệt bằng mắt thường. Nhưng..."

### E3. Giảng viên bấm tải lại → bị chặn 403

**🎬 Hành động:** Quay lại **Tab B** (giảng viên), bấm nút **ZIP** lần nữa.

**🗣️ Lời thoại:**
> "Em quay lại tài khoản giảng viên và bấm tải ZIP lần nữa."

**📸 Kết quả mong đợi — màn hình lỗi:**

```
403 Forbidden

PHÁT HIỆN FILE BỊ THAY ĐỔI (TAMPERED).
Hash không khớp. Vui lòng liên hệ admin.
```

**🗣️ Lời thoại tiếp (nói chậm, nhấn mạnh):**
> "**403 Forbidden.** File ZIP **không được tải về**.
>
> Bằng chứng em vừa thấy: chỉ cần **1 byte** thay đổi — mà em không sửa code, không sửa DB — hệ thống đã phát hiện và **chặn ngay tại Filter**.
>
> Đây chính là điểm em muốn nhấn mạnh ở phần **đánh giá tầm quan trọng**: SHA-256 là **một chiều** — không thể tạo ra hai file khác nhau cùng một hash, và cũng không thể 'tính ngược' để giả mạo hash cũ. Nên kẻ sửa file buộc phải sửa luôn cả hash trong DB — mà việc sửa DB cần quyền riêng, đã nằm ngoài phạm vi truy cập web thông thường."

### E4. Xem trạng thái DB ghi nhận vi phạm

**🎬 Hành động:** Terminal:

```powershell
sqlcmd -S localhost -E -W -d Spirit_GitAnalytics -Q "SET NOCOUNT ON; SELECT submission_id, verification_status, verified_at FROM dbo.SubmissionArtifact WHERE submission_id = 3;"
```

**Kết quả mong đợi:**

```
submission_id  verification_status  verified_at
-------------  -------------------  --------------------------
3              TAMPERED             2026-10-19 13:15:50.600
```

**🗣️ Lời thoại:**
> "DB cũng ghi nhận lại là **`TAMPERED`**. Tức là hệ thống không chỉ chặn — nó còn **lưu vết vi phạm** để giảng viên có thể điều tra sau."

### E5. Phục hồi — chứng minh hệ thống có cơ chế khôi phục

**🎬 Hành động:** Quay lại **Tab A** (sinh viên), bấm **"Lưu bài nộp"** lần nữa.

**🗣️ Lời thoại:**
> "Khi sinh viên nộp lại, hệ thống **tạo ZIP mới** và hash mới, cập nhật bản ghi — trạng thái trở về `PENDING` để chờ verify lại. Em xem nhé:"

```powershell
sqlcmd -S localhost -E -W -d Spirit_GitAnalytics -Q "SET NOCOUNT ON; SELECT submission_id, zip_stored_name, zip_size, file_count, verification_status FROM dbo.SubmissionArtifact WHERE submission_id = 3;"
```

```
submission_id  zip_stored_name    zip_size  file_count  verification_status
-------------  -----------------  --------  ----------  --------------------
3              sub_3_A1B2C3D4.zip  1521      6          PENDING
```

**🗣️ Lời thoại:**
> "ZIP mới `sub_3_A1B2C3D4.zip`, 6 file, trạng thái `PENDING`. Chu trình khép kín."

---

## F. Đối chiếu yêu cầu đồ án — `5:30 → 6:00`

**🎬 Hành động:** Chiếu bảng dưới lên (in ra giấy hoặc copy vào slide).

| Yêu cầu trong đề | Mã nguồn | Đã demo ở |
|---|---|---|
| **4.4.1** Submission Portal — **nén ZIP** | `ArtifactService.createArtifact()` — `java.util.zip.ZipOutputStream` | Bước **C4–C5** |
| **4.4.2** — **xác thực SHA-256 hash** | `ArtifactService.sha256Hex()` — `java.security.MessageDigest` | Bước **C5, D3** |
| Dùng **Filter** để kiểm tra SHA-256 **ngay khi nộp bài** | `ArtifactFilter` + `web.xml` `<filter-mapping>` | Bước **C3→C4, D, E** |
| **Tính toàn vẹn** trước khi đưa vào hàng đợi / đánh giá | `ArtifactFilter` → `403` khi lệch hash | Bước **E3** |
| Model **MVC2** (Controller → Service → DAO) | `SubmissionServlet` → `ArtifactService` → `SubmissionArtifactDAO` | Kiến trúc **B** |
| Dùng **Expression Language (EL)** trong JSP | `${artifact.sha256}`, `${artifact.humanSize}` | Bước **D2** |
| **Tuần 4-6**: JSP, MVC2, Filter, EL | Toàn bộ 8 file đã commit | — |

**🗣️ Lời thoại kết:**

> "Tóm lại, phần này em triển khai **7 file mới + 4 file sửa**, commit `4052bc8`.
> - **Cơ chế:** sinh viên nộp → hệ thống tự **nén ZIP + đóng dấu SHA-256** → lưu vào bảng `SubmissionArtifact`.
> - **Bảo mật:** **Filter** xác thực lại hash **mỗi lần** giảng viên tải, chặn trước khi tới Controller.
> - **Minh bạch:** mỗi lần tải đều được ghi nhận — `VERIFIED` / `TAMPERED` / `MISSING` kèm mốc thời gian.
>
> Em xin hết phần trình bày, các em có câu hỏi nào không ạ?"

---

## 3. Chuẩn bị trả lời Q&A

### Q1: "SHA-256 có chống được việc giảng viên vô tình sửa file không?"

> **Đáp:** Đúng vấn đề. Nếu GV sửa file (ví dụ thêm comment khi chấm), hash sẽ lệch và lần tải sau sẽ bị chặn.
>
> Nhóm em xử lý bằng cách **tách bạch 2 vai trò**:
> - File ZIP trong `uploads/artifacts/` là **bản gốc bất biến** — GV **không bao giờ** sửa trực tiếp file này.
> - GV muốn ghi chú thì ghi vào cột `feedback` của bảng `Submission`, không đụng vào artifact.
>
> Cơ chế `TAMPERED` thực ra đang **phục vụ cho việc phát hiện can thiệp trái phép**, đúng như yêu cầu "đảm bảo tính toàn vẹn".

### Q2: "Tại sao dùng `java.util.zip` mà không dùng thư viện Apache Commons Compress?"

> **Đáp:** Vì `java.util.zip.ZipOutputStream` và `java.security.MessageDigest` đều là **API có sẵn trong JDK** — không cần thêm dependency, giữ pom.xml gọn, và phù hợp với yêu cầu "không thêm thư viện ngoài" của đề. Commons Compress sinh ra chỉ để hỗ trợ các định dạng nén lạ (7z, tar.gz, rar) mà hệ thống không dùng tới.

### Q3: "ZIP có bị rò rỉ đường dẫn thư mục trên máy sinh viên không?"

> **Đáp:** Không ạ. Khi nén, em dùng `new ZipEntry(f.getFileName())` — chỉ lấy **tên file**, không lấy đường dẫn. Ngoài ra tên file đã đi qua `FileUploadUtil.safeName()` để loại ký tự điều khiển và cắt mọi thành phần đường dẫn.

### Q4: "Có bị ZIP Slip không?"

> **Đáp:** Hiện tại em **chỉ ghi** ZIP, không có chức năng **giải nén** — nên chưa có đường tấn công ZIP Slip. Nhưng em đã chuẩn bị phòng thủ: trong `ArtifactFilter` có check `..` trước khi ghép path (`Paths.get(uploadRoot, a.getZipPath())`), và `getZipPath()` chỉ lấy từ DB chứ không lấy từ tham số người dùng. Nếu sau này thêm chức năng giải nén, em sẽ dùng `ZipInputStream` kèm kiểm tra `normalize().startsWith(targetDir)`.

### Q5: "Quyền truy cập artifact được kiểm soát thế nào?"

> **Đáp:** 2 lớp:
> 1. **`AuthFilter`** (đã có sẵn) — chặn người chưa đăng nhập ở `/app/*`.
> 2. **`ArtifactDownloadServlet`** — kiểm tra role: chỉ **chính sinh viên sở hữu submission** đó, hoặc **TEACHER/ADMIN** mới tải được. Sinh viên khác truy cập sẽ nhận `403`.

### Q6: "Nếu sinh viên nộp lại nhiều lần thì ZIP cũ có bị xóa không?"

> **Đáp:** Đây là điểm nhóm em đang cân nhắc. Hiện tại mỗi lần nộp sẽ **sinh file ZIP mới**, file cũ vẫn còn trên đĩa — dẫn đến rác. Theo kế hoạch em sẽ bổ sung **job dọn dẹp** giữ lại artifact mới nhất và xóa artifact cũ sau một khoảng thời gian, đồng thời lưu lại **lịch sử các phiên bản** để truy vết. Đây là phần nhóm em sẽ hoàn thiện ở Tuần 7-9 cùng với hàng đợi chấm điểm.

### Q7: "Vì sao `verification_status` dùng `CHECK` constraint mà không dùng lookup table?"

> **Đáp:** Vì đây là **enum đóng** — chỉ có đúng 4 giá trị và không mở rộng. Dùng `CHECK` constraint giúp **DB tự chặn** giá trị sai, đảm bảo tính toàn vẹn dữ liệu ở tầng cơ sở dữ liệu chứ không phụ thuộc vào code ứng dụng.

---

## 4. Kịch bản dự phòng (khi có sự cố)

| Sự cố | Dấu hiệu | Xử lý nhanh |
|---|---|---|
| Jetty không chạy | Báo "Connection refused" | `mvn jetty:run` → đợi ~25s → mở lại `/gitanalytics/login` |
| Đăng nhập bị lỗi 500 | Trang `/jsp/error.jsp` | Dừng, xem log terminal, nói: "Em xử lý sau ạ", rồi restart |
| Không có dòng trong `SubmissionArtifact` | Query trả 0 rows | Bỏ qua bước C4, giải thích bằng sơ đồ, demo tiếp phần D |
| File ZIP không tồn tại | Báo 404 | Kiểm tra: `Get-ChildItem uploads\artifacts` → nếu trống thì nộp lại bài ở bước C3 |
| Upload bị từ chối | Báo "Định dạng .xyz không được phép" | Đổi sang file `.java` / `.md` — nằm trong whitelist của `FileUploadUtil` |
| SV quên mật khẩu | Không đăng nhập được | Dùng sẵn tài khoản `admin` / `Password@123`, hoặc đăng ký tài khoản mới |

### Câu dự phòng khi demo trục trặc

> "Em xin lỗi, phần này đang gặp trục trặc kỹ thuật. Trong lúc chờ khắc phục, em xin phép trình bày phần này bằng **sơ đồ luồng xử lý** — và sau buổi demo em sẽ gửi bằng chứng chạy thực tế kèm ảnh chụp màn hình và log database."

Nếu GV không chấp nhận, backup sẵn **ảnh chụp màn hình** của 4 mốc: (1) DB có ZIP + SHA-256, (2) màn hình 200 + header, (3) màn hình 403 TAMPERED, (4) DB trạng thái TAMPERED.

---

## 5. Files tham chiếu khi GV yêu cầu mở code

| File | Vai trò | Dòng đáng chú ý |
|---|---|---|
| `src/main/java/com/Spirit/gitanalytics/service/ArtifactService.java` | **Nén ZIP + tính SHA-256** | `createArtifact()` (dòng ~44), `sha256Hex()` (dòng ~108) |
| `src/main/java/com/Spirit/gitanalytics/filter/ArtifactFilter.java` | **Verify SHA-256, chặn 403** | `doFilter()` (dòng ~40), so khớp hash (dòng ~78) |
| `src/main/java/com/Spirit/gitanalytics/controller/ArtifactDownloadServlet.java` | Stream file + phân quyền | `doGet()` (dòng ~32), check quyền (dòng ~55) |
| `src/main/java/com/Spirit/gitanalytics/controller/SubmissionServlet.java` | Điểm gọi `ArtifactService` | `doPost()` — khối "Nén ZIP + tính SHA-256" |
| `src/main/java/com/Spirit/gitanalytics/dao/SubmissionArtifactDAO.java` | Truy vấn `SubmissionArtifact` | `upsert()`, `findBySubmission()`, `markVerified()` |
| `src/main/java/com/Spirit/gitanalytics/model/SubmissionArtifact.java` | POJO ứng dụng **EL** | `getHumanSize()` |
| `src/main/java/com/Spirit/gitanalytics/controller/AssignmentDetailServlet.java` | Nạp `artifactsMap` cho JSP | Khối `artifacts` (dòng ~58) |
| `WebContent/jsp/submit.jsp` | EL hiển thị hash + status | Khối `<c:if test="${not empty artifact}">` |
| `WebContent/jsp/assignment-detail.jsp` | Nút ZIP + hash viết tắt | Khối `${artifactsMap[s.submissionId]}` |
| `WebContent/WEB-INF/web.xml` | Đăng ký Filter | `<filter-name>ArtifactFilter</filter-name>` + mapping |
| `database/migrations/005_submission_artifact.sql` | Lệnh tạo bảng | `CREATE TABLE` + 2 `CREATE INDEX` |

---

## 6. Checklist ngày demo (in ra mang theo)

- [ ] Đã chạy `005_submission_artifact.sql` trên máy demo
- [ ] Đã `git pull` — HEAD đúng commit `4052bc8`
- [ ] Jetty chạy, `/gitanalytics/login` trả 200
- [ ] Mở sẵn 2 tab: Student (Tab A) / Teacher Incognito (Tab B)
- [ ] DevTools Network đã mở, **Preserve log** đã tick
- [ ] Terminal đã mở sẵn, font to, dễ đọc khi chiếu
- [ ] File mẫu trong `demo-files/`: `HelloServlet.java`, `web.xml`, `README.md`
- [ ] Thẻ nhỏ ghi: `teacher1` / `student1` / `Password@123`
- [ ] Ảnh chụp backup (mọi phòng xảy ra sự cố)
- [ ] In sẵn bảng đối chiếu ở mục **F**
- [ ] **Tắt thông báo Windows**, tắt phần mềm gây nhiễu
- [ ] Sạc đầy laptop + sạc dự phòng

---

<div align="center">

**Kết thúc kịch bản — Submission Portal 4.4.1 + SHA-256 4.4.2**

</div>