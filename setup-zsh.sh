#!/bin/bash
set -euo pipefail
trap 'echo -e "\033[1;31m❌ Error on line $LINENO\033[0m"' ERR

echo -e "\033[1;34m🔧 Professional ZSH Environment Setup (MERN Stack Optimized)\033[0m"

# ========================
# Dependency Installation
# ========================
echo -e "\033[1;34m🛠️  Installing system dependencies...\033[0m"
sudo apt update && sudo apt install -y \
  zsh git curl wget unzip fonts-powerline locales gpg \
  docker.io docker-compose exa ripgrep fd-find

# ========================
# UTF-8 Locale Configuration
# ========================
echo -e "\033[1;34m🌐 Configuring locales...\033[0m"
sudo locale-gen en_US.UTF-8
export LANG=en_US.UTF-8

# ========================
# Security Functions
# ========================
verify_checksum() {
  local file=$1
  local expected=$2
  actual=$(sha256sum "$file" | cut -d' ' -f1)
  if [[ "$actual" != "$expected" ]]; then
    echo -e "\033[1;31m❌ Checksum mismatch for ${file}\033[0m"
    echo -e "Expected: ${expected}"
    echo -e "Actual:   ${actual}"
    exit 1
  fi
}

# ========================
# Nerd Font Installation
# ========================
install_nerd_fonts() {
  local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip"
  local font_sha="7c0e13415b8b2b3e35a3a6625bb8f1f9b9a45e5c27eb9d1171540f41049a05b2"

  echo -e "\033[1;34m🔠 Installing Meslo Nerd Font...\033[0m"
  wget -q "$font_url" -O Meslo.zip
  verify_checksum Meslo.zip "$font_sha"
  unzip -q Meslo.zip -d ~/.fonts/
  fc-cache -fv >/dev/null
  rm Meslo.zip
}

install_nerd_fonts

# ========================
# Oh My Zsh Installation
# ========================
install_oh_my_zsh() {
  echo -e "\033[1;34m📦 Installing Oh My Zsh...\033[0m"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo -e "\033[1;35m✅ Oh My Zsh already installed\033[0m"
  fi
}

install_oh_my_zsh

# ========================
# Powerlevel10k Installation
# ========================
install_powerlevel10k() {
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  echo -e "\033[1;34m✨ Installing Powerlevel10k...\033[0m"
  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  else
    echo -e "\033[1;35m✅ Powerlevel10k already installed\033[0m"
  fi
}

install_powerlevel10k

# ========================
# Web-Search Plugin Fix
# ========================
fix_web_search_plugin() {
  local plugin_path="$ZSH/plugins/web-search/web-search.plugin.zsh"

  echo -e "\033[1;34m🔧 Fixing web-search plugin...\033[0m"
  if [ -f "$plugin_path" ]; then
    sed -i 's/declare -A urls=/declare -A urls=([DUCKDUCKGO]="https:\/\/duckduckgo.com\/?q=")/g' "$plugin_path"
  else
    echo -e "\033[1;33m⚠️ web-search plugin not found\033[0m"
  fi
}

fix_web_search_plugin

# ========================
# ZSH Plugins Installation
# ========================
declare -A plugins=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
  [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions"
  [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
  [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search"
  [alias-tips]="https://github.com/djui/alias-tips"
)

install_zsh_plugins() {
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  echo -e "\033[1;34m🔌 Installing ZSH plugins...\033[0m"
  for plugin in "${!plugins[@]}"; do
    target="$ZSH_CUSTOM/plugins/$plugin"
    if [ ! -d "$target" ]; then
      echo -e "\033[1;34m📦 Installing ${plugin}...\033[0m"
      git clone --depth=1 "${plugins[$plugin]}" "$target" || echo -e "\033[1;33m⚠️ Failed to install ${plugin}\033[0m"
    else
      echo -e "\033[1;35m✅ ${plugin} already installed\033[0m"
    fi
  done
}

install_zsh_plugins

# ========================
# Node.js Environment Setup
# ========================
install_node_environment() {
  echo -e "\033[1;34m⬢ Installing Node.js environment...\033[0m"
  if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install --lts
  else
    echo -e "\033[1;35m✅ Node.js environment already configured\033[0m"
  fi
}

install_node_environment

# ========================
# Lazygit Installation
# ========================
install_lazygit() {
  echo -e "\033[1;34m📦 Installing Lazygit...\033[0m"
  if ! command -v lazygit &>/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
  else
    echo -e "\033[1;35m✅ Lazygit already installed\033[0m"
  fi
}

install_lazygit

# ========================
# ZSH Configuration
# ========================
configure_zshrc() {
  echo -e "\033[1;34m⚙️  Configuring .zshrc...\033[0m"
  local zshrc_backup="$HOME/.zshrc.bak.$(date +%s)"

  [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$zshrc_backup"

  cat > "$HOME/.zshrc" <<'EOF'
# ========================
# Powerlevel10k Instant Prompt
# ========================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========================
# PATH Configuration
# ========================
export PATH="$HOME/.npm-global/bin:$PATH"

# ========================
# Oh My Zsh Configuration
# ========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# ========================
# Plugin Configuration
# ========================
plugins=(
 git
  npm
  node
  docker
  docker-compose
  zsh-autosuggestions
  zsh-syntax-highlighting
  you-should-use
  zsh-completions
  command-not-found
  fzf-tab
  z
  zsh-history-substring-search
  alias-tips
  web-search
  safe-paste
  copybuffer
)

# ========================
# Performance Optimizations
# ========================
DISABLE_AUTO_UPDATE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_AUTOSUGGEST_MANUAL_REBIND="1"
ZSH_HIGHLIGHT_MAXLENGTH="300"
HIST_IGNORE_SPACE="true"
autoload -Uz compinit && compinit -u

# ========================
# Source Oh My Zsh
# ========================
source $ZSH/oh-my-zsh.sh

# ========================
# Development Aliases
# ========================

# MERN Development Shortcuts
alias nr="npm run"
alias nrd="npm run dev"
alias nrb="npm run build"
alias nrt="npm test"
alias npx="npx --no-install"
alias npmi="npm install"
alias npms="npm start"
alias clean-node="rm -rf node_modules package-lock.json && npm cache clean --force && echo '\033[1;32m✓ Node modules and cache cleaned\033[0m'"
alias clean-logs="find . -maxdepth 3 -name '*.log' -type f -delete && echo '\033[1;32m✓ Log files deleted\033[0m'"

# Git Aliases
alias gac="git add . && git commit -m"
alias gpf="git push --force-with-lease"
alias gpr="git pull --rebase"

# Docker Aliases
alias dc="docker-compose"
alias dcb="docker-compose build"
alias dcu="docker-compose up"

# Cleanup & Debugging Aliases
alias clean-node="rm -rf node_modules package-lock.json && npm cache clean --force && echo 'Node cache cleaned'"
alias clean-logs="find . -name '*.log' -type f -delete && echo 'Logs deleted'"

# CLI Helpers
alias lg="lazygit"
alias tl="tldr"
alias ll='exa -l --group-directories-first --icons --git --no-permissions --no-user'

# Quick cd to Dev directory alias
alias dev='cd ~/Dev && ls'

# ========================
# CI/CD Automation
# ========================
ci() {
  if [ -f ./.github/workflows/main.yml ]; then
    gh workflow run main.yml
  elif [ -f ./.gitlab-ci.yml ]; then
    gitlab-runner exec docker test
  else
    echo "No CI config found"
  fi
}

# ========================
# WSL Path Conversion
# ========================
cdw() {
  local win_path=${(Q)${(z)@}}
  local wsl_path=$(wslpath -u "${win_path}" 2>/dev/null)
  if [ -d "$wsl_path" ]; then
    cd "$wsl_path" && ll
  else
    echo "Invalid path: $win_path"
  fi
}

# ========================
# Powerlevel10k Finalization
# ========================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ========================
# Node Version Manager
# ========================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Add ZSH hook to check for .nvmrc on directory change
autoload -U add-zsh-hook

# Define function to auto-load the correct Node version
load-nvmrc() {
  # Prevent recursion and check nvm availability
  [[ -n "$NVMRC_ACTIVE" ]] && return
  NVMRC_ACTIVE=true
  (( EPOCHSECONDS - ${_NVMRC_CACHE_TIME:-0} > 1 )) && unset _NVMRC_PATH_CACHE

  if ! command -v nvm >/dev/null 2>&1; then
    echo -e "\033[0;31m✗ nvm not loaded\033[0m" >&2
    unset NVMRC_ACTIVE
    return 1
  fi

  # Cache nvmrc discovery for performance
  local current_node=$(nvm version)
  local nvmrc_path=${_NVMRC_PATH_CACHE:-$(nvm_find_nvmrc)}
  local desired_node

  if [[ -n "$nvmrc_path" ]]; then
    desired_node=$(<"$nvmrc_path")
    desired_node=${desired_node//[$'\t\r\n']/}  # Sanitize newlines

    if [[ -z "$desired_node" || "$desired_node" =~ [^a-zA-Z0-9./*-] ]]; then
      echo -e "\033[0;31m✗ Invalid .nvmrc: ${desired_node:-empty}\033[0m" >&2
      unset NVMRC_ACTIVE _NVMRC_PATH_CACHE
      return 1
    fi

    if [[ "$desired_node" != "$current_node" ]]; then
      if ! nvm ls "$desired_node" &>/dev/null; then
        echo -e "\033[1;36m⌛ Installing Node $desired_node...\033[0m"
        nvm install "$desired_node" >/dev/null 2>&1 || {
          echo -e "\033[0;31m✗ Install failed\033[0m" >&2
          unset NVMRC_ACTIVE _NVMRC_PATH_CACHE
          return 1
        }
      fi

      nvm use "$desired_node" >/dev/null 2>&1 && \
        echo -e "\033[1;32m✓ Node ${desired_node}\033[0m"
    else
      echo -e "\033[1;33mℹ Node ${desired_node} active\033[0m"
    fi

    _NVMRC_PATH_CACHE=$nvmrc_path
    _NVMRC_CACHE_TIME=$EPOCHSECONDS

  elif [[ "$current_node" != "system" ]]; then
    if nvm ls system | grep -q '(not installed)'; then
      echo -e "\033[0;33m⚠ System Node unavailable\033[0m" >&2
      unset NVMRC_ACTIVE
      return 1
    fi

    nvm use system >/dev/null 2>&1 && \
      echo -e "\033[1;34m↩ System Node activated\033[0m"
  fi

  unset NVMRC_ACTIVE
}


# Attach the function to directory change
add-zsh-hook chpwd load-nvmrc
# Run immediately on terminal start
load-nvmrc
EOF
}

configure_zshrc

# ========================
# Final System Configuration
# ========================
set_default_shell() {
  echo -e "\033[1;34m💻 Setting ZSH as default shell...\033[0m"
  if [ "$(basename "$SHELL")" != "zsh" ]; then
    sudo chsh -s "$(which zsh)" "$USER" || echo -e "\033[1;33m⚠️ Shell change failed - manually run 'exec zsh'\033[0m"
  fi
}

set_default_shell

# Last line should be:
echo -e "\n\033[1;32m✅ Professional development environment setup complete!\n➡️  Start a new terminal session or run 'exec zsh'\033[0m"