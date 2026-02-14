CREATE TABLE contributors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  github_id TEXT UNIQUE NOT NULL,
  github_username TEXT NOT NULL,
  display_name TEXT,
  email TEXT,
  trust_level TEXT DEFAULT 'new' CHECK (trust_level IN ('new', 'established', 'moderator')),
  verified_edits_count INT DEFAULT 0,
  affiliated_brands TEXT[],
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Row Level Security
ALTER TABLE contributors ENABLE ROW LEVEL SECURITY;

-- Anyone can read contributor profiles
CREATE POLICY "Contributors are viewable by everyone"
  ON contributors FOR SELECT USING (true);

-- Contributors can update their own profile
CREATE POLICY "Contributors can update own profile"
  ON contributors FOR UPDATE USING (auth.uid()::text = github_id);