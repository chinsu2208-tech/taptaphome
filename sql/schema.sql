-- ═══════════════════════════════════════════════════════════════
-- TAP STORE PORTAL — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════

-- 1. App Settings (shift leader, target, gemini key, etc.)
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed default settings
INSERT INTO app_settings (key, value) VALUES
  ('shift_leader', '"Mai"'),
  ('month_target', '{"month": 3, "target": 8000, "done": 5420}'),
  ('gemini_key', '""')
ON CONFLICT (key) DO NOTHING;

-- 2. Alerts (red notifications)
CREATE TABLE IF NOT EXISTS alerts (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO alerts (text) VALUES
  ('Flash sale 15/3 dự kiến x2 đơn – chuẩn bị gấp đôi nhân lực!'),
  ('Xe GHN đang đến sớm 15 phút, chuẩn bị hàng!')
ON CONFLICT DO NOTHING;

-- 3. Today Notes (Chú ý hôm nay)
CREATE TABLE IF NOT EXISTS today_notes (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('high', 'normal')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. News
CREATE TABLE IF NOT EXISTS news (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  tag TEXT DEFAULT 'Tin mới',
  body TEXT DEFAULT '',
  img TEXT DEFAULT '',
  can_signup BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. News interactions (read / signup tracking)
CREATE TABLE IF NOT EXISTS news_interactions (
  id BIGSERIAL PRIMARY KEY,
  news_id BIGINT REFERENCES news(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('read', 'signup')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(news_id, user_name, action)
);

-- 6. Tasks
CREATE TABLE IF NOT EXISTS tasks (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  assigned_by TEXT NOT NULL,
  assigned_to TEXT NOT NULL,
  due TEXT DEFAULT '',
  status TEXT DEFAULT 'todo' CHECK (status IN ('todo', 'doing', 'done')),
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('high', 'normal')),
  note TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. SKUs
CREATE TABLE IF NOT EXISTS skus (
  id BIGSERIAL PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  stock INTEGER DEFAULT 0,
  location TEXT DEFAULT '',
  price TEXT DEFAULT '',
  note TEXT DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed SKU data
INSERT INTO skus (sku, name, stock, location, price, note) VALUES
  ('XV-LAV-100', 'XV Lavender 100ml', 12, 'Kệ A1', '89k', 'Tồn thấp'),
  ('XV-ROS-100', 'XV Rose 100ml', 45, 'Kệ A2', '89k', ''),
  ('XV-VAN-100', 'XV Vanilla 100ml', 67, 'Kệ A3', '89k', ''),
  ('NC-PCH-50', 'NC Peach 50ml', 23, 'Kệ B1', '65k', ''),
  ('NC-BER-50', 'NC Berry 50ml', 8, 'Kệ B2', '65k', 'Tồn thấp'),
  ('TL-24A4', 'ToneLux Personal Color 24a4', 15, 'Gầm bàn PC', '120k', ''),
  ('TL-12A4', 'ToneLux Personal Color 12a4', 20, 'Gầm bàn PC', '95k', ''),
  ('SP-100-EMPTY', 'Chai spray 100ml (rỗng)', 180, 'Kệ C1', '—', 'Vật tư')
ON CONFLICT (sku) DO NOTHING;

-- 8. FAQ
CREATE TABLE IF NOT EXISTS faq (
  id BIGSERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  tag TEXT DEFAULT 'Quy trình',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed FAQ
INSERT INTO faq (question, answer, tag) VALUES
  ('NC24a4, 3a4, 6a4, 12a4, 16a4 ở đâu?', 'Tất cả tập Personal Color đặt dưới gầm bàn máy tính. Chưa rõ → nhắn nhóm.', 'ToneLux'),
  ('XV 200ml là gì?', 'Kho KHÔNG bán XV 200ml. Đây là đơn pre-order. Trưởng ca kiểm tra kỹ → báo pha chế.', 'Quan trọng'),
  ('Sản phẩm hết hàng?', 'Kiểm tra kỹ trong kho. Nếu hết → báo chị Quỳnh khóa SP + nhắn khách đổi SP khác.', 'Quy trình'),
  ('Còn nước không?', 'Trước khi dán mùi hương, kiểm tra can còn đủ nước & ước lượng số lượng hợp lý.', 'Quy trình'),
  ('Máy in hỏng', 'Báo trưởng ca → liên hệ chị Quỳnh. Dùng máy in dự phòng bàn số 2.', 'Sự cố')
ON CONFLICT DO NOTHING;

-- 9. Chat messages
CREATE TABLE IF NOT EXISTS chat_messages (
  id BIGSERIAL PRIMARY KEY,
  user_name TEXT NOT NULL,
  text TEXT NOT NULL,
  role TEXT DEFAULT 'staff' CHECK (role IN ('admin', 'staff')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Kudos
CREATE TABLE IF NOT EXISTS kudos (
  id BIGSERIAL PRIMARY KEY,
  from_user TEXT NOT NULL,
  to_user TEXT NOT NULL,
  message TEXT DEFAULT '',
  sticker TEXT DEFAULT '💛',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Moods
CREATE TABLE IF NOT EXISTS moods (
  id BIGSERIAL PRIMARY KEY,
  user_name TEXT NOT NULL,
  mood TEXT NOT NULL,
  date DATE DEFAULT CURRENT_DATE,
  UNIQUE(user_name, date)
);

-- ═══════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (allow all for now, tighten later)
-- ═══════════════════════════════════════════════════════════════
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE today_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE news ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE skus ENABLE ROW LEVEL SECURITY;
ALTER TABLE faq ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE kudos ENABLE ROW LEVEL SECURITY;
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;

-- Public read/write for all (internal tool, no public access)
CREATE POLICY "Allow all" ON app_settings FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON alerts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON today_notes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON news FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON news_interactions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON skus FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON faq FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON chat_messages FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON kudos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON moods FOR ALL USING (true) WITH CHECK (true);

-- Enable Realtime for chat
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE today_notes;
