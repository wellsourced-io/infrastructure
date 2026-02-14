CREATE TABLE disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_slug TEXT NOT NULL,
  reported_by_email TEXT NOT NULL,
  is_brand_owner BOOLEAN DEFAULT false,
  fields_disputed JSONB NOT NULL,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_review', 'resolved', 'escalated')),
  resolver_id UUID REFERENCES contributors(id),
  resolution_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Disputes viewable by authenticated users"
  ON disputes FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone can create disputes"
  ON disputes FOR INSERT WITH CHECK (true);