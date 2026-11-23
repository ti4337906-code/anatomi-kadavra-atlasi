#!/data/data/com.termux/files/usr/bin/bash
set -e

REPO_NAME="${1:-anatomi-kadavra-atlasi}"
echo "=== Kadavra Anatomisi Atlası — Otomatik GitHub Pages Kurulumu ==="
echo "Hedef repo adı: $REPO_NAME"

if ! command -v git >/dev/null 2>&1; then
  pkg install git -y
fi

if ! command -v gh >/dev/null 2>&1; then
  pkg install gh -y
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub girişi gerekiyor..."
  gh auth login
fi

git init -b main
git add index.html deploy_termux.sh
git commit -m "Kadavra Anatomisi Atlası (Anki + OSPE + Şifreli Kişisel Hafıza)" || true

GH_USER=$(gh api user -q .login)
if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
  git push -u origin main --force
else
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

# GitHub Pages'i main branch kök dizininden aktif et
gh api -X POST "repos/$GH_USER/$REPO_NAME/pages" \
  -f source[branch]=main -f source[path]=/ >/dev/null 2>&1 || true

echo ""
echo "Kurulum tamamlandı!"
echo "Canlı Site Adresin (1-2 dk içinde aktif olur):"
echo "https://$GH_USER.github.io/$REPO_NAME/"
