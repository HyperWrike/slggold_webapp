-- ============================================================
-- SLG GOLDS - Complete Database Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1. PROFILES TABLE (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL DEFAULT '',
  username TEXT,
  phone TEXT,
  aadhaar TEXT,
  dob TEXT,
  gender TEXT,
  father_name TEXT,
  birth_place TEXT,
  address TEXT,
  nominee_name TEXT,
  nominee_relationship TEXT,
  pin_hash TEXT,
  pin_length TEXT DEFAULT '4',
  role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'manager')),
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. SCHEMES TABLE
CREATE TABLE IF NOT EXISTS schemes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  metal_type TEXT NOT NULL DEFAULT 'gold' CHECK (metal_type IN ('gold', 'silver', 'combo')),
  monthly_amount NUMERIC NOT NULL DEFAULT 500,
  min_amount NUMERIC DEFAULT 100,
  tenure_months INT NOT NULL DEFAULT 12,
  benefit TEXT,
  gold_benefit_percent NUMERIC DEFAULT 0,
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  is_popular BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. ENROLLMENTS TABLE
CREATE TABLE IF NOT EXISTS enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  scheme_id UUID NOT NULL REFERENCES schemes(id),
  monthly_amount NUMERIC NOT NULL DEFAULT 500,
  tenure_months INT NOT NULL DEFAULT 12,
  paid_months INT DEFAULT 0,
  total_gold_grams NUMERIC DEFAULT 0,
  paid_amount NUMERIC DEFAULT 0,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled', 'paused')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. TRANSACTIONS TABLE
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  enrollment_id UUID REFERENCES enrollments(id) ON DELETE SET NULL,
  type TEXT NOT NULL DEFAULT 'credit' CHECK (type IN ('credit', 'debit')),
  amount NUMERIC NOT NULL DEFAULT 0,
  net_amount NUMERIC,
  gst NUMERIC,
  gold_grams NUMERIC,
  silver_grams NUMERIC,
  description TEXT,
  status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'pending', 'failed', 'refunded')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. METAL PRICES TABLE
CREATE TABLE IF NOT EXISTS metal_prices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gold_price NUMERIC NOT NULL,
  silver_price NUMERIC NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  icon TEXT DEFAULT 'notifications',
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'payment', 'alert', 'promo', 'system')),
  is_read BOOLEAN DEFAULT false,
  is_global BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. ADMIN TABLE (separate admin accounts)
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'manager', 'viewer')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_enrollments_user ON enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_enrollment ON transactions(enrollment_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_metal_prices_time ON metal_prices(created_at DESC);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Allow insert for registration" ON profiles FOR INSERT WITH CHECK (true);

-- Schemes
ALTER TABLE schemes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active schemes" ON schemes FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage schemes" ON schemes FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Enrollments
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own enrollments" ON enrollments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own enrollments" ON enrollments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can view all enrollments" ON enrollments FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
);

-- Transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can view all transactions" ON transactions FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
);

-- Metal Prices
ALTER TABLE metal_prices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read metal prices" ON metal_prices FOR SELECT USING (true);

-- Notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT 
  USING (auth.uid() = user_id OR is_global = true);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE 
  USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage notifications" ON notifications FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Default schemes
INSERT INTO schemes (name, description, metal_type, monthly_amount, min_amount, tenure_months, benefit, gold_benefit_percent, is_popular) VALUES
('Classic Gold Savings Plan', 'Secure your future with systematic purchases. SLG pays the 13th month''s equivalent as a loyalty bonus on successful completion.', 'gold', 500, 100, 12, 'SLG pays the 13th month', 8.33, true),
('Silver Sterling SIP', 'Pure 999 Silver accumulation with locked-in prices.', 'silver', 1200, 500, 24, 'Bonus 2g silver on completion', 0, false),
('Gold Plus Premium', 'Premium gold accumulation with higher monthly commitment and exclusive benefits.', 'gold', 2000, 1000, 24, '10% bonus gold at maturity', 10, false),
('Festival Gold Combo', 'Gold and Silver combo plan for festive savings.', 'combo', 1500, 500, 18, 'Special festival bonus', 5, false)
ON CONFLICT DO NOTHING;

-- Admin account (password: admin123)
-- Note: In production, create admin via Supabase Auth, not direct insert
-- This is a placeholder - actual admin should be created through auth signup
INSERT INTO admins (email, password_hash, name, role) VALUES
('admin@slggolds.com', '$2a$10$placeholder_hash_for_admin123', 'SLG Admin', 'admin')
ON CONFLICT (email) DO NOTHING;

-- Sample notifications
INSERT INTO notifications (user_id, title, message, icon, type, is_global) VALUES
(NULL, 'Welcome to SLG Golds', 'Start your gold investment journey today!', 'star', 'promo', true),
(NULL, 'Gold Price Update', 'Gold prices have increased by 1.2% this week.', 'trending_up', 'alert', true),
(NULL, 'New Scheme Available', 'Check out our new Silver Sterling SIP plan!', 'workspace_premium', 'info', true)
ON CONFLICT DO NOTHING;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- AUTO-PROFILE CREATION TRIGGER
-- This creates a profile row automatically when a user signs up via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, username, role, created_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer'),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to get user portfolio summary
CREATE OR REPLACE FUNCTION get_portfolio_summary(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'totalGoldGrams', COALESCE(SUM(total_gold_grams), 0),
    'totalValue', COALESCE(SUM(paid_amount), 0),
    'activeEnrollments', COUNT(*) FILTER (WHERE status = 'active')
  ) INTO result
  FROM enrollments
  WHERE user_id = p_user_id;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to get admin stats
CREATE OR REPLACE FUNCTION get_admin_stats()
RETURNS JSON AS $$
DECLARE
  total_customers INT;
  active_schemes INT;
  today_collection NUMERIC;
  total_aum NUMERIC;
BEGIN
  SELECT COUNT(*) INTO total_customers FROM profiles WHERE role = 'customer';
  SELECT COUNT(*) INTO active_schemes FROM schemes WHERE is_active = true;
  SELECT COALESCE(SUM(amount), 0) INTO today_collection 
    FROM transactions 
    WHERE created_at >= CURRENT_DATE AND type = 'credit';
  SELECT COALESCE(SUM(paid_amount), 0) INTO total_aum FROM enrollments;
  
  RETURN json_build_object(
    'totalCustomers', total_customers,
    'activeSchemes', active_schemes,
    'todayCollection', today_collection,
    'totalAUM', total_aum
  );
END;
$$ LANGUAGE plpgsql;
