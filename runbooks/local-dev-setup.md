# Local Development Setup

## Prerequisites
- Git
- Docker + Docker Compose (Docker Desktop, Rancher Desktop, or Colima)
- Node.js 20+ (for running scripts outside containers if needed)
- gitleaks (`brew install gitleaks` on Mac)

## Setup

1. Clone all repos into a workspace directory:
```bash
   mkdir ~/wellsourced-workspace && cd ~/wellsourced-workspace
   git clone https://github.com/wellsourced-io/wellsourced.git
   git clone https://github.com/wellsourced-io/brand-data.git
   git clone https://github.com/wellsourced-io/infrastructure.git
```

2. Install pre-commit hooks (in each repo):
```bash
   cd wellsourced && ./scripts/setup-hooks.sh && cd ..
   cd brand-data && ./scripts/setup-hooks.sh && cd ..
   cd infrastructure && ./scripts/setup-hooks.sh && cd ..
```

3. Configure environment:
```bash
   cp infrastructure/docker/.env.example infrastructure/docker/.env
   # Edit .env with your API keys
```

4. Start the stack:
```bash
   cd infrastructure/docker
   docker compose up --build
```

5. App: http://localhost:3000
6. Meilisearch: http://localhost:7700

## Common Commands
- `docker compose up` — start app + meilisearch
- `docker compose --profile worker run sync-worker` — run Shopify sync
- `docker compose down` — stop everything
- `docker compose down -v` — stop + wipe Meilisearch data