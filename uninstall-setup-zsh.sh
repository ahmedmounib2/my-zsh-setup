#!/bin/bash
# SAFE ZSH Environment Uninstaller (Full Removal)
set -euo pipefail
trap 'echo -e "\033[1;31m❌ Error on line $LINENO\033[0m"' ERR

echo -e "\033[1;31m🔥 Starting full uninstall...\033[0m"

# ========================
# Restore Default Shell
# ========================
current_shell=$(basename "$SHELL")
if [[ "$current_shell" == "zsh" ]]; then
  echo -e "\033[1;33m🔄 Reverting to bash...\033[0m"
  chsh -s "$(which bash)" 2>/dev/null || true
fi

# ========================
# Core Components Removal
# ========================
declare -a components=(
  "$HOME/.oh-my-zsh"
  "$HOME/.p10k.zsh"
  "$HOME/.cache/p10k"
  "$HOME/.nvm"
  "$HOME/.npm-completion"
  "$HOME/.mongodb-completion"
  "$HOME/.fonts/Meslo"  # Nerd Fonts
)

# ========================
# Plugin & Binary Removal
# ========================
declare -a plugins=(
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  "$HOME/.oh-my-zsh/custom/plugins/you-should-use"
  "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
  "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search"
  "$HOME/.oh-my-zsh/custom/plugins/alias-tips"
  "$HOME/.oh-my-zsh/custom/plugins/web-search"
  "/usr/local/bin/lazygit"  # Lazygit binary
)

# ========================
# Safe Removal Function
# ========================
safe_remove() {
  for path in "$@"; do
    if [ -e "$path" ]; then
      echo -e "\033[1;31m🗑️  Removing ${path}\033[0m"
      sudo rm -rf "$path"
    else
      echo -e "\033[1;35m⏩ Not found: ${path}\033[0m"
    fi
  done
}

# ========================
# Execute Removals
# ========================
safe_remove "${components[@]}"
safe_remove "${plugins[@]}"

# ========================
# Restore Original .zshrc
# ========================
find_backup() {
  ls -t "$HOME"/.zshrc.bak.* 2>/dev/null | head -n1
}

if latest_backup=$(find_backup); then
  echo -e "\033[1;35m⏪ Restoring .zshrc from ${latest_backup}\033[0m"
  mv -f "$latest_backup" "$HOME/.zshrc"
else
  [ -f "$HOME/.zshrc" ] && {
    echo -e "\033[1;31m🗑️  Removing custom .zshrc\033[0m"
    rm -f "$HOME/.zshrc"
  }
fi

# ========================
# System Package Removal
# ========================
read -p "❓ Remove system packages (zsh, fonts, tools)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "\033[1;33m♻️  Removing installed packages...\033[0m"
  sudo apt remove -y --purge \
    zsh fonts-powerline locales \
    exa ripgrep fd-find \
    docker.io docker-compose

  echo -e "\033[1;33m🧹 Cleaning up dependencies...\033[0m"
  sudo apt autoremove -y
  sudo apt clean
fi

# ========================
# Global NPM Cleanup
# ========================
if command -v npm >/dev/null; then
  read -p "❓ Remove global npm packages? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\033[1;33m♻️  Removing global npm packages...\033[0m"
    npm ls -g --depth=0 | awk -F ' ' '{print $2}' | grep -v '^npm@' | xargs -r npm remove -g
  fi
fi

# ========================
# Final Cleanup
# ========================
echo -e "\033[1;33m🧹 Cleaning caches...\033[0m"
rm -rf ~/.npm ~/.cache/npm ~/.local/share/lazygit

echo -e "\033[1;32m✅ Full uninstall complete! Start a new terminal session.\033[0m"