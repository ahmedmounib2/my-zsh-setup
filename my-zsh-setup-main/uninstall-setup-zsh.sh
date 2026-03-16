#!/bin/bash
# SAFE ZSH Environment Uninstaller (Zinit/FNM Edition)
set -euo pipefail
trap 'echo -e "\033[1;31m❌ Error on line $LINENO\033[0m"' ERR

echo -e "\033[1;31m🔥 Starting safe uninstall...\033[0m"

# Restore original shell if zsh was default
current_shell=$(basename "$SHELL")
if [[ "$current_shell" == "zsh" ]]; then
  echo -e "\033[1;33m🔄 Reverting to bash...\033[0m"
  chsh -s "$(which bash)" 2>/dev/null || true
fi

# Core components and tools to remove
declare -a components=(
  "$HOME/.oh-my-zsh"
  "$HOME/.zinit"
  "$HOME/.p10k.zsh"
  "$HOME/.cache/p10k"
  "$HOME/.local/share/fnm"
  "$HOME/.fonts/Meslo"
  "$HOME/.npm-global"
  "/usr/local/bin/lazygit"
  "/usr/local/bin/exa"
  "/usr/local/bin/fzf-tab"
  "/usr/local/bin/docker"
  "/usr/local/bin/docker-compose"
  "$HOME/.cache/zinit"
  "$HOME/.local/share/zinit"
)

# Function to safely remove files/directories
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

# Execute removals
safe_remove "${components[@]}"

# Restore original .zshrc if backup exists
find_backup() {
  ls -t "$HOME"/.zshrc.bak.* 2>/dev/null | head -n1
}

if latest_backup=$(find_backup); then
  echo -e "\033[1;35m⏪ Restoring .zshrc from ${latest_backup}\033[0m"
  mv -f "$latest_backup" "$HOME/.zshrc"
else
  if [ -f "$HOME/.zshrc" ]; then
    echo -e "\033[1;31m🗑️  Removing custom .zshrc\033[0m"
    rm -f "$HOME/.zshrc"
  fi
fi

# Remove FNM environment variables and PATH modifications from shell profiles
shell_profiles=(
  "$HOME/.bashrc"
  "$HOME/.zshrc"
  "$HOME/.profile"
)

for profile in "${shell_profiles[@]}"; do
  if [ -f "$profile" ]; then
    echo -e "\033[1;33m🧹 Cleaning FNM and PATH entries from ${profile}\033[0m"
    sed -i '/fnm/d' "$profile"
    sed -i '/FNM_PATH/d' "$profile"
    sed -i '/\.npm-global/d' "$profile"
    sed -i '/powerlevel10k/d' "$profile"
    sed -i '/ZINIT/d' "$profile"
  fi
done

# Optionally remove system packages installed (adjust as per install script)
read -p "Remove zsh and other installed packages (exa, lazygit, ripgrep, fd-find)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo apt remove -y --purge zsh fonts-powerline locales exa ripgrep fd-find lazygit
  sudo apt autoremove -y
fi

echo -e "\033[1;32m✅ Safe uninstall complete. Please start a new terminal session.\033[0m"
