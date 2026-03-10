# 🚀 Hướng Dẫn Deploy TAP Store Portal

## Tổng quan kiến trúc

```
Người dùng (Mobile/PC)
        ↓
   Vercel (Hosting)
     ├── index.html (Frontend)
     └── /api/gemini.js (Serverless function - giấu API key)
        ↓
   Supabase (Database + Realtime)
     ├── PostgreSQL (lưu data)
     └── Realtime (chat, task sync live)
```

---

## Bước 1: Setup Supabase (5 phút)

1. Vào **[supabase.com](https://supabase.com)** → Đăng nhập
2. **New Project** → đặt tên `tap-portal` → chọn region `Southeast Asia`
3. Đợi project tạo xong (~2 phút)
4. Vào **SQL Editor** → **New Query**
5. Copy toàn bộ nội dung file `sql/schema.sql` → Paste vào → **Run**
6. Vào **Settings** → **API** → Copy 2 giá trị:
   - `Project URL` (ví dụ: `https://abc123.supabase.co`)
   - `anon public` key (chuỗi dài bắt đầu bằng `eyJ...`)

## Bước 2: Cập nhật config vào code (1 phút)

Mở file `index.html`, tìm dòng `SUPABASE CONFIG` ở gần đầu script, thay 2 giá trị:

```javascript
const SUPABASE_URL = 'https://YOUR-PROJECT.supabase.co';  // ← thay URL
const SUPABASE_KEY = 'eyJhbGci...YOUR-ANON-KEY';          // ← thay key
```

## Bước 3: Push lên GitHub (3 phút)

```bash
# Tạo repo mới trên github.com (tên: tap-portal)
# Rồi chạy:

cd tap-portal-project
git init
git add .
git commit -m "TAP Store Portal v5"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/tap-portal.git
git push -u origin main
```

## Bước 4: Deploy lên Vercel (2 phút)

1. Vào **[vercel.com](https://vercel.com)** → Đăng nhập bằng GitHub
2. **Import Project** → Chọn repo `tap-portal`
3. Settings:
   - **Framework Preset**: `Other`
   - **Root Directory**: `.` (mặc định)
   - **Build Command**: để trống
   - **Output Directory**: `public`
4. **Environment Variables** (thêm nếu dùng Gemini qua serverless):
   - `GEMINI_API_KEY` = key của bạn
5. **Deploy** → Đợi ~30 giây
6. Vercel sẽ cho bạn URL, ví dụ: `https://tap-portal.vercel.app`

## Bước 5: (Tuỳ chọn) Custom domain

Trong Vercel → Settings → Domains → thêm domain riêng, ví dụ:
- `portal.tapstore.vn`

---

## Cấu trúc file

```
tap-portal-project/
├── public/
│   └── index.html          ← Frontend (HTML + CSS + JS tất cả trong 1 file)
├── api/
│   └── gemini.js            ← Serverless function (giấu Gemini API key)
├── sql/
│   └── schema.sql           ← Database schema (chạy 1 lần trên Supabase)
├── vercel.json               ← Vercel config
├── package.json              ← Project info
├── README.md                 ← File này
└── .gitignore
```

## Cách hoạt động

| Tính năng | Lưu ở đâu | Realtime? |
|-----------|-----------|-----------|
| Trưởng ca, Target | Supabase `app_settings` | ✅ |
| Thông báo đỏ | Supabase `alerts` | ✅ |
| Chú ý hôm nay | Supabase `today_notes` | ✅ |
| Task công việc | Supabase `tasks` | ✅ |
| Chat nội bộ | Supabase `chat_messages` | ✅ |
| Tin tức | Supabase `news` | Khi refresh |
| Đã đọc / Đăng ký | Supabase `news_interactions` | Khi refresh |
| SKU hàng hoá | Supabase `skus` | Khi refresh |
| FAQ | Supabase `faq` | Khi refresh |
| Kudos | Supabase `kudos` | Khi refresh |
| Mood | Supabase `moods` | Khi refresh |
| Trợ lý AI | Gemini API (qua Vercel serverless) | — |

## Bảo mật

- Supabase `anon key` chỉ cho phép đọc/ghi theo RLS policy
- Gemini API key được giấu trong Vercel environment variable
- Hiện tại RLS cho phép tất cả (vì là tool nội bộ)
- Sau này muốn thêm đăng nhập: dùng Supabase Auth + tighten RLS

## Sau khi deploy, muốn update?

1. Sửa code trên máy
2. `git add . && git commit -m "update" && git push`
3. Vercel tự động redeploy trong 30 giây

---

💡 **Tip**: Bookmark URL Vercel trên điện thoại → "Add to Home Screen" → trở thành app icon y hệt native app!
