# Professional Zsh Environment Setup for MERN Stack (Optimized for WSL)

![Terminal Demo Screenshot](https://user-images.githubusercontent.com/704406/114582739-0a1c2d00-9c8e-11eb-9a7b-421d86988a7f.png)

This is a complete, ready-to-use Zsh environment setup tailored for MERN stack developers working primarily on Windows Subsystem for Linux (WSL). It combines modern tooling, smart version management, and optimized plugins to create a smooth, productive terminal experience.

---

## What Does This Setup Provide?

### Core Shell Environment

| Component        | Version/Info  | Purpose                                           |
|------------------|---------------|--------------------------------------------------|
| **Zsh**          | 5.8+          | A powerful shell with extensibility and plugins  |
| **Oh My Zsh**    | Latest        | Framework to manage themes and plugins (theme only) |
| **Powerlevel10k**| Latest        | Highly customizable, fast prompt with icons      |
| **Meslo Nerd Font** | 3.0.2       | Font with icons needed for Powerlevel10k          |
| **Zinit**        | 3.15          | Fast, flexible plugin manager for Zsh             |

### Development Utilities

| Tool             | Role                                                 |
|------------------|------------------------------------------------------|
| **Node.js (LTS)**| JavaScript runtime, managed with FNM (Fast Node Manager) |
| **Lazygit**      | Interactive terminal UI for git                       |
| **exa**          | Modern alternative to `ls` with colors and icons    |
| **fzf-tab**      | Fuzzy finder integration for enhanced tab completion |
| **Docker CE**    | Container platform for building and running apps    |
| **Docker Compose**| Tool for defining and managing multi-container setups |

### Zinit Plugins for Speed and Productivity

| Plugin                     | What It Does                                    |
|----------------------------|------------------------------------------------|
| **zsh-autosuggestions**    | Suggests commands based on history as you type |
| **zsh-syntax-highlighting**| Colors commands for easier reading and errors  |
| **you-should-use**          | Recommends shorter, better commands             |
| **fzf-tab**                | Fuzzy completion to quickly find commands/files |
| **zsh-history-substring-search** | Search shell history more intuitively        |
| **alias-tips**             | Warns if an alias can replace your typed command|
| **zsh-completions**        | Adds extra completion scripts                    |
| **Oh My Zsh Plugins**      | Docker, git, web-search snippets                 |

---

## Important `.zshrc` Enhancements

- Over **15 developer-friendly aliases** for npm, git, docker, and more
- Adds `~/.npm-global/bin` to PATH for global npm binaries
- Instant prompt enabled for Powerlevel10k for faster shell startup
- Automatic Node.js version switching with FNM (Fast Node Manager)
- Custom `cdw` command to switch directories with WSL path conversion
- CI/CD shortcuts for GitHub and GitLab workflows
- Zinit configured to load plugins **in parallel** and **cache** compiled plugins for speed

---

## Node.js Version Management via FNM (Fast Node Manager)

This setup includes an **automatic Node.js version switcher** that reads `.nvmrc` files in your project directories and:

- Switches Node versions immediately on directory change (`cd`)
- Shows a colored message indicating the version switch
- Automatically installs missing Node versions
- Supports nested projects with their own `.nvmrc` files
- Silent and unobtrusive unless switching versions
- Fall back to NVM if FNM fails.

### How It Works (Inside `.zshrc`)

```zsh
eval "$(fnm env --use-on-cd)"

fnm_check_version() {
  local desired current
  [[ -f .nvmrc ]] && desired=$(<.nvmrc) || return
  current=$(node -v 2>/dev/null || echo "none")

  if [[ "$current" != "v$desired" ]]; then
    echo -e "\033[1;33m⚠️ Switching to Node v$desired\033[0m"
    fnm use "$desired" || fnm install "$desired"
  fi
}
add-zsh-hook chpwd fnm_check_version
```

## How To Use

- Add .nvmrc in your project root specifying Node version:

```bash
echo "20.19.0" > .nvmrc
```

- Or for existing projects:

```bash
node -v > .nvmrc
```

## 🛠️ Installation steps

```bash
# 1. Clone the repository
git clone https://github.com/ahmedmounib2/my-zsh-setup.git

# 2. Change directory into the repo folder
cd my-zsh-setup

# 3. Make the install script executable
chmod +x setup-zsh.sh

# 4. Run the installer script
./setup-zsh.sh
```

## Optional: One-liner (if you want to avoid cloning manually)

#### You can do it with git clone and run the script in one command like

```bash
git clone https://github.com/ahmedmounib2/my-zsh-setup.git && cd my-zsh-setup && chmod +x setup-zsh.sh && ./setup-zsh.sh
```

## 😰 Uninstall steps

```bash
# Method 1: Clone and run uninstall script
git clone https://github.com/ahmedmounib2/my-zsh-setup.git
cd my-zsh-setup/uninstall-setup-zsh
chmod +x uninstall.sh
./uninstall.sh
```

```bash
#Method 2: One-liner (clone & run uninstall script)
curl -O https://raw.githubusercontent.com/ahmedmounib2/my-zsh-setup/main/uninstall-setup-zsh/uninstall.sh
chmod +x uninstall.sh
./uninstall.sh
```

## 🔧 Maintenance

**Update components**:

```bash Download and run the installer script

# Configure your Powerlevel10k prompt interactively
p10k configure

# Verify installation
fnm --version && zinit --version
```

```bash
zinit self-update && zinit update --all
fnm install --latest
Uninstall:
```

## ⚠️ What the Uninstall Script Does Not Remove

The uninstall script is designed to safely and thoroughly clean up your ZSH setup, but a few components are intentionally left untouched:

- nvm
- ~/.zsh_history
- Docker & Docker Compose
- System fzf
- Custom alias files

**Node version not switching**:

````bash
fnm use 20 --install && fnm default 20
````

**Missing plugins**:

```bash
zinit compile --all
```

- Maintained by: Ahmed Monib
- Security Contact: <ahmedmounib2@gmail.com>
- Last Updated: 2024-05-24

## Compatibility

- WSL2 ✅

- Ubuntu 22.04+ ✅

- ARM64 ⚠️ Experimental

## License: MIT
