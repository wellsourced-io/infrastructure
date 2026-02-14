CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submitter_id UUID REFERENCES contributors(id),
  brand_name TEXT NOT NULL,
  brand_url TEXT NOT NULL,
  shopify_domain TEXT,
  data JSONB NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'approved', 'needs_info', 'rejected')),
  reviewer_id UUID REFERENCES contributors(id),
  reviewer_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Submissions viewable by authenticated users"
  ON submissions FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone authenticated can create submissions"
  ON submissions FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Submitters can update own pending submissions"
  ON submissions FOR UPDATE USING (
    submitter_id IN (SELECT id FROM contributors WHERE github_id = auth.uid()::text)
    AND status = 'pending'
  );