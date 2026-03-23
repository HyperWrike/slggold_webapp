-- Enable Row Level Security (RLS) on tables

-- Example for 'users' table
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view own data" ON users FOR SELECT USING (auth.uid() = id);
-- CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);

-- Example for 'schemes' table (Public read-only)
-- ALTER TABLE schemes ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Schemes are readable by everyone" ON schemes FOR SELECT USING (true);
-- CREATE POLICY "Schemes insertable by admin only" ON schemes FOR INSERT WITH CHECK (auth.raw_user_meta_data()->>'role' = 'admin');

-- Example for 'transactions' table
-- ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);

-- Note: Ensure these tables exist in your Supabase schema and run this script in the Supabase SQL Editor.
