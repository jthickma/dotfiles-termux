#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_DIR="$HOME/dotfiles-termux"
OMZ_DIR="$HOME/.oh-my-zsh"

echo "[*] Installing Termux dotfiles from $REPO_DIR"

# --- Backup existing .zshrc ---
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  BACKUP="$HOME/.zshrc.bak.$(date +%s)"
  echo "[*] Backing up existing .zshrc to $BACKUP"
  cp "$HOME/.zshrc" "$BACKUP"
fi

# --- Install .zshrc (symlink) ---
echo "[*] Linking zshrc"
ln -sf "$REPO_DIR/zshrc" "$HOME/.zshrc"

# --- Ensure Oh My Zsh is installed ---
if [[ ! -d "$OMZ_DIR" ]]; then
  echo "[*] Oh My Zsh not found, cloning"
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
else
  echo "[*] Oh My Zsh already present"
fi

# --- Sync Oh My Zsh custom directory ---
echo "[*] Syncing Oh My Zsh custom files"
mkdir -p "$OMZ_DIR/custom"
rsync -a --delete \
  "$REPO_DIR/oh-my-zsh/custom/" \
  "$OMZ_DIR/custom/"

echo "[✓] Installation complete"
echo "→ Restart Termux or run: source ~/.zshrc"
