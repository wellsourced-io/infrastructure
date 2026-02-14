#!/bin/sh
echo "Installing pre-commit hooks..."
cat > .git/hooks/pre-commit << 'HOOK'
#!/bin/sh
gitleaks protect --staged --verbose
HOOK
chmod +x .git/hooks/pre-commit
echo "Done. gitleaks will scan staged files before each commit."