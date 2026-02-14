CREATE TABLE edit_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_slug TEXT NOT NULL,
  field_name TEXT NOT NULL,
  current_value TEXT,
  suggested_value TEXT NOT NULL,
  source_url TEXT,
  submitter_id UUID REFERENCES contributors(id),
  submitter_email TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewer_id UUID REFERENCES contributors(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE edit_suggestions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Edit suggestions viewable by authenticated users"
  ON edit_suggestions FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone can create edit suggestions"
  ON edit_suggestions FOR INSERT WITH CHECK (true);