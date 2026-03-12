# 🚀 Rootless HPC Dotfiles (Pixi + Chezmoi)

This repository is a lightweight, rootless alternative to my declarative [NixOS configuration](https://github.com/HugoHakem/nix-os.config). It is specifically designed for High-Performance Computing (HPC) clusters or any environment where I lack `sudo` access.

It uses [Pixi](https://pixi.prefix.dev/dev/deployment/pixi_pack/) for user-space package management and [Chezmoi](https://www.chezmoi.io/) for dotfile templating and deployment.

## 📥 Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/HugoHakem/dotfiles/main/install.sh | bash

```

## 📦 Included Packages

Managed entirely in user-space via `pixi global`:

+ `chezmoi` - Dotfile manager
+ `starship` - Cross-shell prompt
+ `direnv` - Directory-specific environments
+ `bat` - A `cat` clone with syntax highlighting
+ `htop` - Interactive process viewer and system monitor
+ `tree` - Visual, depth-indented directory lister
+ `tldr` - Simplified, practical man pages with quick command examples
+ `uv` - fast Python package and project manager, written in Rust (used by Pixi under the hood).

## 📂 Repository Structure

```text
.
├── .chezmoi.toml.tmpl          # Chezmoi config template (handles VS Code merge setup)
├── dot_bashrc                  # Bash config (HPC safe + Starship + direnv)
├── dot_config
│   └── starship.toml           # Cross-shell prompt configuration
├── dot_gitconfig.tmpl          # Git config with LFS filters and dynamic user data
├── dot_pixi
│   └── manifests
│       └── pixi-global.toml    # The declarative list of all required software
├── dot_tmux.conf
├── dot_vimrc                   # Classic Vim setup
├── dot_zshrc                   # Zsh config (HPC safe + Starship + direnv)
├── install.sh                  # Interactive bootstrap script
└── README.md
```

## 🛠️ Guidelines for Replication

If you want to fork and use this setup for your own environments:

1. **Fork the repo**: Create your own copy on GitHub.
2. **Run the bootstrap**: Execute the `curl` command above on your target machine (remembering to point to your fork's URL). The script will interactively prompt you for your GitHub username and Git credentials.

## ⚙️ Manage Packages Interactively

Do not manually edit the `pixi-global.toml` manifest right out of the box. Instead, manage your tools dynamically using the CLI:

```bash
pixi global install <package-name>
pixi global uninstall <package-name>
```

**Persist Your Changes**: Once you are happy with your new toolset, use the manifest to ensure reproducibility across your other machines by adding the updated file back to Chezmoi:

```bash
chezmoi add ~/.pixi/manifests/pixi-global.toml
chezmoi cd
git add dot_pixi/manifests/pixi-global.toml
git commit -m "chore: update pixi global manifest"
git push
```

## 📋 TO-DO

+ [ ] HugoHakem/dotfiles#1
+ [ ] HugoHakem/dotfiles#2
