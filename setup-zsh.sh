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
# Zinit Installation
# ========================
install_zinit() {
  echo -e "\033[1;34m📦 Installing Zinit...\033[0m"
  ZINIT_HOME="${HOME}/.zinit"
  if [ ! -d "${ZINIT_HOME}/bin" ]; then
    mkdir -p "${ZINIT_HOME}"
    git clone https://github.com/zdharma-continuum/zinit "${ZINIT_HOME}/bin"
  else
    echo -e "\033[1;35m✅ Zinit already installed\033[0m"
  fi
}

install_zinit

# ========================
# FNM Installation (Fast Node Manager)
# ========================
install_fnm() {
  echo -e "\033[1;34m⬢ Installing FNM (Fast Node Manager)...\033[0m"
  if ! command -v fnm &>/dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
  else
    echo -e "\033[1;35m✅ FNM already installed\033[0m"
  fi
}

install_fnm

# ========================
# NVM Installation (Node Version Manager) - fallback if fnm unavailable
# ========================
install_nvm() {
  echo -e "\033[1;34m⬢ Installing NVM (Node Version Manager)...\033[0m"
  if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    # Load nvm immediately
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  else
    echo -e "\033[1;35m✅ NVM already installed\033[0m"
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi
}

install_nvm

# ========================
# Install Node.js LTS via fnm and nvm
# ========================
install_node() {
  echo -e "\033[1;34m⬢ Installing Node.js LTS (stable) via fnm...\033[0m"
  if command -v fnm &>/dev/null; then
    fnm install --lts --skip-default-packages
    fnm use --lts
  else
    echo -e "\033[1;33m⚠️ fnm not found, skipping fnm Node.js install\033[0m"
  fi

  echo -e "\033[1;34m⬢ Installing Node.js LTS (stable) via nvm as fallback...\033[0m"
  if command -v nvm &>/dev/null; then
    nvm install --lts
    nvm alias default lts/*
  else
    echo -e "\033[1;33m⚠️ nvm not found, skipping nvm Node.js install\033[0m"
  fi
}

install_node

# ========================
# Yarn Package Manager Installation (recommended)
# ========================
install_yarn() {
  echo -e "\033[1;34m📦 Installing or updating Yarn package manager...\033[0m"
  if ! command -v yarn &>/dev/null; then
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install -y yarn
  else
    echo -e "\033[1;35m✅ Yarn already installed, upgrading...\033[0m"
    sudo apt update && sudo apt install --only-upgrade -y yarn
  fi
}

install_yarn

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
# Zinit Plugins Installation
# ========================
install_zinit_plugins() {
  echo -e "\033[1;34m🔌 Installing Zinit plugins...\033[0m"
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # List of all plugins to clone
  declare -A plugins=(
    ["romkatv/zsh-defer"]="light"
    ["zsh-users/zsh-completions"]="light"
    ["zsh-users/zsh-autosuggestions"]="ice wait1 silent; light"
    ["zsh-users/zsh-syntax-highlighting"]="ice wait2 silent; light"
    ["zsh-users/zsh-history-substring-search"]="light"
    ["Aloxaf/fzf-tab"]="light"
    ["rupa/z"]="light"
    ["djui/alias-tips"]="light"
    ["MichaelAquilina/zsh-you-should-use"]="light"
  )

  # Snippets for Oh My Zsh plugins via Zinit
  declare -a omz_snippets=(
    "OMZ::plugins/docker"
    "OMZ::plugins/docker-compose"
    "OMZ::plugins/command-not-found"
    "OMZ::plugins/web-search"
    "OMZ::plugins/safe-paste"
    "OMZ::plugins/copybuffer"
  )

  ZINIT_BIN="$HOME/.zinit/bin"
  [ -f "$ZINIT_BIN/zinit.zsh" ] || { echo -e "\033[1;31m❌ Zinit not installed, cannot install plugins\033[0m"; return 1; }
  source "$ZINIT_BIN/zinit.zsh"

  for repo in "${!plugins[@]}"; do
    local ice_opts="${plugins[$repo]}"
    # Split ice options if exists
    if [[ "$ice_opts" == ice* ]]; then
      eval "zinit $ice_opts; zinit light $repo"
    else
      zinit light "$repo"
    fi
  done

  for snippet in "${omz_snippets[@]}"; do
    zinit snippet "$snippet"
  done
  echo -e "\033[1;32m✅ Zinit plugins installed or updated\033[0m"
}

install_zinit_plugins


# ZSH Configuration
configure_zshrc() {
  echo -e "\033[1;34m⚙️  Configuring .zshrc...\033[0m"
  local zshrc_backup="$HOME/.zshrc.bak.$(date +%s)"

  [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$zshrc_backup"

  cat > "$HOME/.zshrc" <<'EOF'
# ─── POWERLEVEL10K INSTANT PROMPT ────────────────────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── PATH SETUP ──────────────────────────────────────────────────────────────────────────────
export PATH="$HOME/.npm-global/bin:$PATH"

# ─── CLI TOOLS CHECK ────────────────────────────────────────────────────────────────────────
# bat (pretty cat)
if ! type bat &>/dev/null; then
  if command -v batcat &>/dev/null; then
    alias bat="batcat"
  else
    echo -e "\033[1;33m⚠️ Install bat: 'sudo apt install bat' or 'brew install bat'\033[0m"
  fi
fi

# tldr (simplified man)
if ! command -v tldr &>/dev/null; then
  echo -e "\033[1;33m⚠️ Install tldr: 'npm install -g tldr'\033[0m"
fi

# ─── NODE VERSION MANAGEMENT ────────────────────────────────────────────────
# fnm setup (must come before detection)
FNM_PATH="$HOME/.local/share/fnm"
if [[ -d "$FNM_PATH" ]]; then
  export PATH="$FNM_PATH:$PATH"

  if command -v fnm &>/dev/null; then
    eval "$(fnm env)"  # initialize fnm if available
  else
    echo -e "\033[1;33m⚠️ fnm not found – falling back to nvm if available\033[0m"
  fi
fi


# Node Version Manager Detection
NODE_VERSION_MANAGER="none"
if command -v fnm &>/dev/null; then
  NODE_VERSION_MANAGER="fnm"
elif [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_DIR="$HOME/.nvm"
  . "$NVM_DIR/nvm.sh"
  . "$NVM_DIR/bash_completion"
  NODE_VERSION_MANAGER="nvm"
fi

# Enhanced Node Version Management
autoload -U add-zsh-hook

# Function to get current node version
get_current_node_version() {
  case "$NODE_VERSION_MANAGER" in
    fnm)
      fnm current 2>/dev/null || echo "none"
      ;;
    nvm)
      nvm current 2>/dev/null || echo "none"
      ;;
    *)
      echo "none"
      ;;
  esac
}

# Main version check function (for fnm and general cases)
node_version_check() {
  [[ "$NODE_VERSION_MANAGER" == "none" ]] && return

  local current_version=$(get_current_node_version)
  local version_file=""
  [[ -f .nvmrc ]] && version_file=".nvmrc"
  [[ -f .node-version ]] && version_file=".node-version"

  if [[ -n "$version_file" ]]; then
    local desired=$(<"$version_file")
    desired=${desired//[$'\t\r\n ']/}

    case "$NODE_VERSION_MANAGER" in
      fnm)
        if [[ "$current_version" != *"$desired"* ]]; then
          echo -e "\033[1;33m⚠️ Switching to Node $desired (fnm)\033[0m"
          fnm use "$desired" || fnm install "$desired"
          current_version=$(get_current_node_version)
        fi
        echo -e "\033[1;32m✓ Using Node $current_version (from ${version_file})\033[0m"
        ;;
      nvm)
        # Let load-nvmrc handle this case to avoid duplicate messages
        load-nvmrc
        ;;
    esac
  else
    case "$NODE_VERSION_MANAGER" in
      fnm)
        local default_version=$(fnm default 2>/dev/null)
        if [[ "$current_version" != *"$default_version"* ]]; then
          echo -e "\033[1;34mℹ️ Using default Node version\033[0m"
          fnm default
          current_version=$(get_current_node_version)
        fi
        echo -e "\033[1;36mℹ️ No .nvmrc found. Current Node version: $current_version\033[0m"
        ;;
      nvm)
        # Let load-nvmrc handle this case to avoid duplicate messages
        load-nvmrc
        ;;
    esac
  fi
}

# Original nvmrc loader (for nvm fallback)
load-nvmrc() {
  # Only run if nvm is the version manager
  [[ "$NODE_VERSION_MANAGER" != "nvm" ]] && return

  # Prevent re-entrance
  [[ -n "$NVMRC_ACTIVE" ]] && return
  NVMRC_ACTIVE=1

  # Reset cache if older than 1 second (can adjust as needed)
  (( EPOCHSECONDS - ${_NVMRC_CACHE_TIME:-0} > 1 )) && unset _NVMRC_PATH_CACHE

  # Check that nvm command exists
  if ! command -v nvm &>/dev/null; then
    echo -e "\033[0;31m✗ nvm not loaded\033[0m" >&2
    unset NVMRC_ACTIVE
    return 1
  fi

  local current desired nvmrc_path
  current=$(nvm current)  # get current active node version
  nvmrc_path=${_NVMRC_PATH_CACHE:-$(nvm_find_nvmrc)}  # locate .nvmrc

  if [[ -n "$nvmrc_path" ]]; then
    desired=$(<"$nvmrc_path")           # read desired version
    desired=${desired//[$'\t\r\n ']/}  # strip whitespace

    # Validate version string (only allow alphanumeric, dot, slash, star, dash)
    if [[ -z "$desired" || "$desired" =~ [^a-zA-Z0-9./*-] ]]; then
      echo -e "\033[0;31m✗ Invalid .nvmrc: ${desired:-empty}\033[0m" >&2
      unset NVMRC_ACTIVE _NVMRC_PATH_CACHE
      return 1
    fi

    # If desired differs from current, switch versions
    if [[ "$desired" != "$current" ]]; then
      # If desired version not installed, install it
      if ! nvm ls "$desired" &>/dev/null; then
        echo -e "\033[1;36m⌛ Installing Node $desired...\033[0m"
        if ! nvm install "$desired"; then
          echo -e "\033[0;31m✗ Install failed\033[0m" >&2
          unset NVMRC_ACTIVE _NVMRC_PATH_CACHE
          return 1
        fi
      fi

      # IMPORTANT: run 'nvm use' in current shell, show output and error if any
      if nvm use "$desired"; then
        echo -e "\033[1;32m✓ Node $desired activated\033[0m"
      else
        echo -e "\033[0;31m✗ Failed to switch to Node $desired\033[0m" >&2
        unset NVMRC_ACTIVE _NVMRC_PATH_CACHE
        return 1
      fi
    else
      echo -e "\033[1;33mℹ️ Node $desired already active\033[0m"
    fi

    _NVMRC_PATH_CACHE=$nvmrc_path
    _NVMRC_CACHE_TIME=$EPOCHSECONDS
  else
    # No .nvmrc file found - optionally fallback to system node or just print info
    if [[ "$current" != "system" ]]; then
      if nvm ls system | grep -q '(not installed)'; then
        echo -e "\033[0;33m⚠️ System Node unavailable\033[0m" >&2
        unset NVMRC_ACTIVE
        return 1
      fi
      if nvm use system; then
        echo -e "\033[1;34m↩ System Node activated\033[0m"
      else
        echo -e "\033[0;31m✗ Failed to activate system Node\033[0m" >&2
        unset NVMRC_ACTIVE
        return 1
      fi
    else
      echo -e "\033[1;36mℹ️ No .nvmrc found. Current Node version: $current\033[0m"
    fi
  fi

  unset NVMRC_ACTIVE
}


# Initialize version manager and hooks
case "$NODE_VERSION_MANAGER" in
  fnm)
    if [[ -z "$FNM_ALREADY_INIT" ]]; then
      echo -e "\033[1;32m✓ Using fnm for Node.js version management\033[0m"
      eval "$(fnm env --use-on-cd)"
      export FNM_ALREADY_INIT=1
    fi
    add-zsh-hook chpwd node_version_check
    node_version_check  # Run once at startup
    ;;
  nvm)
    echo -e "\033[1;33m⚠️ Using nvm fallback (fnm not found)\033[0m"
    add-zsh-hook chpwd load-nvmrc
    load-nvmrc  # Run once at startup
    ;;
  *)
    echo -e "\033[1;31m❌ No Node version manager found. Install fnm or nvm.\033[0m"
    ;;
esac

# ─── OH-MY-ZSH + POWERLEVEL10K ──────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# ─── ZINIT SETUP ────────────────────────────────────────────────────────────────────────────
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit ~/.zinit/bin
fi
source ~/.zinit/bin/zinit.zsh

# Zinit Plugins
zinit light romkatv/zsh-defer
zinit light zsh-users/zsh-completions
zinit ice wait"1" silent; zinit light zsh-users/zsh-autosuggestions
zinit ice wait"2" silent; zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light Aloxaf/fzf-tab
zinit light rupa/z
zinit light djui/alias-tips
zinit light MichaelAquilina/zsh-you-should-use

# Oh My Zsh Plugins via Zinit
zinit ice wait"3" silent; zinit snippet OMZ::plugins/docker
zinit ice wait"4" silent; zinit snippet OMZ::plugins/docker-compose
zinit snippet OMZ::plugins/command-not-found
zinit snippet OMZ::plugins/web-search
zinit snippet OMZ::plugins/safe-paste
zinit snippet OMZ::plugins/copybuffer

# ─── PERFORMANCE, HISTORY, ENV ─────────────────────────────────────────────────────────────
DISABLE_AUTO_UPDATE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_AUTOSUGGEST_MANUAL_REBIND="1"
ZSH_HIGHLIGHT_MAXLENGTH="300"
HIST_IGNORE_SPACE="true"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS SHARE_HISTORY
umask 027
setopt no_clobber

# Init completions (only once)
autoload -Uz compinit && compinit -u

# Source Oh My Zsh (theme only)
source "$ZSH"/oh-my-zsh.sh

# ─── GIT CONFIG (SAFE DIRECTORY) ────────────────────────────────────────────────────────────
git config --global --add safe.directory '*'

# ─── P10K CONFIGURATION ────────────────────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── SHELL OPTIONS ──────────────────────────────────────────────────────────────────────────
setopt prompt_subst
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt interactive_comments

# ─── ALIASES ────────────────────────────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gl='git log'
alias gp='git push'
alias gpl='git pull'
alias gc='git commit'
alias ga='git add'
alias gco='git checkout'
alias gstash='git stash'
alias gpop='git stash pop'

# ─── FZF INTEGRATION (if installed) ────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d'
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
fi

# ─── FINAL MESSAGE ────────────────────────────────────────────────────────────────────────
echo -e "\033[1;32m✔️  ZSH environment loaded successfully\033[0m"
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

echo -e "\n\033[1;32m✅ Professional development environment setup complete!\n➡️  Start a new terminal session or run 'exec zsh'\033[0m"
