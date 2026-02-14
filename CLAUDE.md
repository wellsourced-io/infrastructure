# WellSourced — Infrastructure Repository

> **Repo:** `wellsourced-io/infrastructure`
> **Role:** Docker Compose orchestration, Supabase database migrations, Meilisearch configuration, and operational runbooks.
> **This repo does not contain application code.** It wires the other repos together.

## Critical Rules

- **Never commit real credentials.** Only `.env.example` files with placeholder values. Real `.env` files are gitignored.
- **Docker Compose paths are relative.** The compose files expect sibling repos at `../../wellsourced` and `../../brand-data`. The workspace directory structure must be:
  ```
  ~/wellsourced-workspace/
  ├── wellsourced/
  ├── brand-data/
  ├── infrastructure/
  └── docs/
  ```
- **Supabase migrations are sequential.** Files in `supabase/migrations/` must be run in numeric order. Use the Supabase CLI: `supabase db push`.
- **Meilisearch index settings are the source of truth.** If you change search behavior, update `meilisearch/indexes/product-settings.json` — the sync-worker reads this.

## Repository Structure

```
infrastructure/
├── docker/
│   ├── docker-compose.yml          # Local dev stack (app + meilisearch + worker)
│   ├── docker-compose.prod.yml     # Production overrides (published images, resource limits)
│   ├── .env.example                # Template for all env vars
│   └── .gitignore                  # Ignores .env and volume data
├── supabase/migrations/
│   ├── 001_create_contributors.sql
│   ├── 002_create_submissions.sql
│   ├── 003_create_edit_suggestions.sql
│   └── 004_create_disputes.sql
├── meilisearch/indexes/
│   └── product-settings.json       # Searchable, filterable, sortable attribute config
├── runbooks/
│   └── local-dev-setup.md          # Quick-start for new developers
├── monitoring/                     # (Future) alerting and observability config
├── scripts/
│   └── setup-hooks.sh              # Install gitleaks pre-commit hook
├── .github/workflows/
│   └── secret-scan.yml             # Gitleaks scanning
└── .gitleaks.toml                  # Secret scanning config
```

## Docker Compose Services

### Local Development (`docker-compose.yml`)

| Service | Image | Port | Purpose |
|---|---|---|---|
| `app` | Built from `../../wellsourced/Dockerfile` (deps stage) | 3000 | Next.js dev server with hot reload |
| `meilisearch` | `getmeili/meilisearch:v1.12` | 7700 | Search engine |
| `sync-worker` | Built from `../../wellsourced/Dockerfile.worker` | — | Shopify sync + reindex (on-demand, `--profile worker`) |

```bash
# Start app + meilisearch
cd docker && docker compose up --build

# Run sync worker manually
docker compose --profile worker run sync-worker

# Stop everything
docker compose down

# Stop + wipe Meilisearch data
docker compose down -v
```

### Production (`docker-compose.prod.yml`)

Uses published images from GHCR instead of building locally:
- `ghcr.io/wellsourced-io/wellsourced:latest`
- `ghcr.io/wellsourced-io/sync-worker:latest`

Adds resource limits (512MB app, 1GB Meilisearch) and `restart: unless-stopped`.

## Supabase Database Schema

4 tables, all with Row Level Security enabled:

| Table | Purpose | Key Fields |
|---|---|---|
| `contributors` | GitHub OAuth accounts, trust levels | `github_id`, `trust_level` (new/established/moderator), `verified_edits_count` |
| `submissions` | Brand submission review queue | `brand_name`, `status` (pending/in_review/approved/needs_info/rejected) |
| `edit_suggestions` | Lightweight field-level edit suggestions | `brand_slug`, `field_name`, `suggested_value`, `source_url` |
| `disputes` | Brand owner corrections/challenges | `brand_slug`, `fields_disputed`, `is_brand_owner` |

### Running Migrations

```bash
# Using Supabase CLI (recommended)
cd ~/wellsourced-workspace/infrastructure
supabase link --project-ref YOUR_PROJECT_REF
supabase db push

# Or manually in Supabase SQL Editor — run each file in order
```

## Meilisearch Index Configuration

`meilisearch/indexes/product-settings.json` defines two indexes:

**products** — searchable: title, description, brand_name, tags, categories. Filterable: brand_slug, categories, price, ownership_type, certifications, country_manufactured, trust_tier_min, price_range, available.

**brands** — searchable: name, description, categories, certifications. Filterable: ownership_type, certifications, country_hq, country_manufactured, price_range, categories.

## Production Hosting (MVP)

| Service | Host | Cost |
|---|---|---|
| Next.js app | Vercel (free tier) | $0 |
| Meilisearch | Railway | ~$5/mo |
| Database + Auth | Supabase (free tier) | $0 |
| Container Registry | GHCR (free for public repos) | $0 |
| Domain | Vercel (wellsourced.io) | ~$3/mo |

## Migration Path: Vercel → Self-Hosted

Zero code changes needed:
1. Provision a VPS
2. Clone this repo
3. `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d`
4. Point DNS, add reverse proxy (Caddy/Traefik) for HTTPS
