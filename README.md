# Professional ZSH Environment Setup for MERN Stack (WSL Optimized)

![Terminal Demo Screenshot](https://user-images.githubusercontent.com/704406/114582739-0a1c2d00-9c8e-11eb-9a7b-421d86988a7f.png)

A complete terminal environment configuration for professional web development with detailed auditing and enterprise-grade security.

## 📦 What This Script Installs

### Core System Components

| Package          | Version | Purpose                          |
|------------------|---------|----------------------------------|
| Zsh              | 5.8+    | Modern shell with plugin support |
| Oh My Zsh        | Latest  | Zsh configuration framework      |
| Powerlevel10k    | Latest  | Fast, customizable prompt theme  |
| Nerd Fonts       | Meslo   | Iconic font for terminal symbols |

### Development Tools

| Tool             | Purpose                                  |
|------------------|------------------------------------------|
| Node.js (LTS)    | JavaScript runtime via NVM               |
| Lazygit          | Terminal UI for Git operations           |
| exa              | Modern replacement for ls                |
| fzf              | Fuzzy finder integration                 |
| Docker CE        | Containerization platform                |
| Docker Compose   | Multi-container orchestration            |

### ZSH Plugins (23 Total)

| Plugin                       | Functionality                              |
|------------------------------|--------------------------------------------|
| zsh-autosuggestions          | Suggests commands as you type              |
| zsh-syntax-highlighting      | Colors commands for validation             |
| you-should-use               | Suggests shorter command alternatives      |
| fzf-tab                      | Fuzzy completion for Zsh                   |
| zsh-history-substring-search | Better history navigation                   |
| alias-tips                   | Warns when aliases are available            |
| web-search                   | Direct search from terminal                 |
| safe-paste                   | Safe clipboard pasting                      |
| copybuffer                   | Copies command output to clipboard          |
| git                          | Git aliases + status in prompt              |
| docker                       | Docker completion + helper aliases          |
| npm                          | NPM completion + project awareness          |

### .zshrc Modifications

```bash
# Key Configuration Changes
- 15+ Developer Aliases (npm, git, docker)
- PATH enhancements (~/.npm-global/bin added)
- Instant Prompt configuration for P10k
- Auto-switching Node versions via .nvmrc
- WSL path conversion (cdw command)
- CI/CD workflow shortcuts (gh/gitlab)
- Performance optimizations:
  - DISABLE_AUTO_UPDATE=true
  - ZSH_HIGHLIGHT_MAXLENGTH=300
  - Manual compinit initialization
```

## 📦 Node.js Version Management

### Automated Version Switching with `.nvmrc`

The script configures automatic Node.js version switching through these components:

```zsh
autoload -U add-zsh-hook
load-nvmrc() {
  local current_node=$(nvm version)
  local nvmrc_path=$(nvm_find_nvmrc)

  if [ -n "$nvmrc_path" ]; then
    local desired_node=$(cat "$nvmrc_path")
    if [ "$desired_node" != "$current_node" ]; then
      nvm install "$desired_node"
      nvm use "$desired_node"
    fi
  elif [ "$current_node" != "system" ]; then
    nvm use system >/dev/null 2>&1 || true
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

### What This Does

- **Automatic Detection**: Scans directories for `.nvmrc` files when you `cd`
- **Version Switching**: Changes Node.js version to match `.nvmrc`
- **Auto-Install**: Installs missing Node versions if needed
- **Fallback**: Uses system Node when no `.nvmrc` found

### Setup for Projects

1. **Create `.nvmrc` File**
   In your project root:

   ```bash
   node -v > .nvmrc  # For existing projects
   ```

   or manually specify version:

   ```bash
   echo "20.19.0" > .nvmrc
   ```

2. **Supported Version Formats**
   `.nvmrc` can specify:
   - Exact version: `20.19.0`
   - LTS names: `lts/hydrogen`
   - Version patterns: `18.x`, `>=16.13.0 <17.0.0`

3. **Workflow Example**

   ```bash
   cd my-project/     # Directory with .nvmrc
   # [Now using Node v20.19.0]

   git pull
   npm install

   cd ../legacy-project/  # Directory without .nvmrc
   # [Falling back to system Node v18.12.1]
   ```

### Key Features

- **Multi-level Search**: Looks for `.nvmrc` in parent directories
- **Silent Operation**: Only shows output when changing versions
- **Project Isolation**: Version changes don't affect other terminals
- **CI/CD Ready**: Works in scripts and automation environments

### Troubleshooting

**Q**: Version isn't switching automatically
**Fix**:

```bash
# 1. Verify .nvmrc exists
ls -a | grep .nvmrc

# 2. Check file contents
cat .nvmrc

# 3. Manually trigger detection
load-nvmrc
```

**Q**: Getting "Version not found" error
**Fix**: Install available versions with:

```bash
nvm ls-remote  # List available versions
nvm install <version-from-list>
```

**Q**: Want to disable auto-switching?
**Remove Hook**:

```zsh
# Add to ~/.zshrc
add-zsh-hook -d chpwd load-nvmrc
```

## 🛠️ Installation Guide

### System Requirements

- WSL2/Ubuntu 22.04 LTS or newer
- Minimum 2GB disk space
- Administrator privileges (for package installs)

### Step-by-Step Installation

1. **Download Script**

   ```bash
   curl -O https://yourdomain.com/setup-zsh.sh
   ```

2. **Make Executable**

   ```bash
   chmod +x setup-zsh.sh
   ```

3. **Run Installation**

   ```bash
   ./setup-zsh.sh
   ```

### What Happens During Installation

1. **System Preparation Phase**
   - Updates APT repositories
   - Installs 17 required packages:

     ```bash
     zsh git curl wget unzip fonts-powerline locales gpg docker.io
     docker-compose exa ripgrep fd-find jq
     ```

2. **Security Setup**
   - Verifies checksums for all downloads
   - Creates pre-installation backups
   - Limits sudo privileges to essential operations

3. **Core Installation**
   - Oh My Zsh with 23 plugins
   - Powerlevel10k theme configuration
   - Node.js LTS via NVM (with auto-version switching)
   - Lazygit 0.40+ installation

4. **Configuration**
   - Creates/modifies 6 config files:
     - ~/.zshrc (main configuration)
     - ~/.p10k.zsh (theme settings)
     - ~/.npm-completion (npm autocomplete)
     - ~/.mongodb-completion (MongoDB helpers)
     - ~/.fonts/ (Nerd Fonts directory)
     - /etc/locale.gen (UTF-8 setup)

5. **Post-Install**
   - Sets Zsh as default shell
   - Runs initial compinit
   - Creates restoration point

## 🚀 Post-Installation Steps

1. **Reload Shell**

   ```bash
   exec zsh
   ```

2. **Configure Powerlevel10k**

   ```bash
   p10k configure
   ```

   - Recommended settings:
     - Unicode characters
     - Lean prompt style
     - 12-hour time format
     - Compact spacing

3. **Verify Installations**

   ```bash
   lg --version       # Should show Lazygit 0.40+
   exa --version      # Modern ls replacement
   node --version     # Should show LTS version
   ```

## 🔧 Customization Guide

### Adding Custom Aliases

Add to `~/.zshrc`:

```bash
# MERN Development
alias nextlog="tail -f .next/logs/output.log"
alias mongo-start="sudo systemctl start mongod"

# Deployment
alias deploy-stage="npm run build && scp -r dist/ user@stage:/app"
```

### Plugin Management

Enable/disable plugins in `~/.zshrc`:

```bash
plugins=(
  git
  docker
  #web-search  <-- Disable by commenting
  zsh-autosuggestions
)
```

## ⚠️ Troubleshooting

### Common Issues

1. **Missing Icons**:

   ```bash
   sudo apt install fonts-powerline
   fc-cache -fv
   ```

2. **Web-Search Plugin Error**:

   ```bash
   nano $ZSH/plugins/web-search/web-search.plugin.zsh
   # Change line 103 to:
   declare -A urls=([DUCKDUCKGO]="https://duckduckgo.com/?q=")
   ```

3. **Shell Not Changing**:

   ```bash
   chsh -s $(which zsh)
   exec zsh
   ```

## 🔄 Maintenance

### Uninstallation

```bash
./safe-uninstall.sh
```

- Removes 42+ components including:
  - All ZSH plugins and themes
  - Node.js versions
  - Configuration files
  - System packages (optional)

### Updates

```bash
# Update plugins
zsh-mern-setup/ $ git pull origin main
# Re-run setup
./setup.sh --update
```

---

**Maintained by**: Ahmed Monib
**Security Contact**: <ahmedmounib2@gmail.com>
**Last Audited**: 2025-05-24
**Compatibility Matrix**:

- WSL2 ✅
- Ubuntu 22.04+ ✅
- Debian 11+ ✅
- ARM64 (Experimental) ⚠️

**License**: MIT
