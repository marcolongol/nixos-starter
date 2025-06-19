# 🚀 nixos-started

> **A beginner-friendly, modular approach to Infrastructure as Code with NixOS**

[![GitHub Repository](https://img.shields.io/badge/GitHub-marcolongol%2Fnixos--started-blue?logo=github)](https://github.com/marcolongol/nixos-started)

Welcome to a modern NixOS configuration system designed to make managing your infrastructure simple, scalable, and maintainable. Whether you're new to NixOS or an experienced user, this repository provides powerful abstractions that make managing users, packages, and hosts intuitive.

## 🎯 What Makes This Special?

- **🧩 Modular Design**: Clean separation between user configs, package sets, and host definitions
- **🛠️ Automated Tooling**: Simple CLI commands handle complex Nix configurations  
- **📚 Beginner Friendly**: No need to manually edit complex Nix files
- **🔄 Infrastructure as Code**: Version-controlled, reproducible system configurations
- **⚡ Developer Experience**: Integrated development environment with all tools included

## 🔧 Core Concepts

### Infrastructure as Code (IaC) with NixOS
Instead of manually configuring systems, you define your entire infrastructure in code:
- **Declarative**: Describe what you want, not how to get there
- **Reproducible**: Same configuration = identical systems  
- **Version Controlled**: Track changes, rollback safely
- **Modular**: Reuse configurations across multiple machines

### The Four Pillars

1. **👤 User Profiles** (`profiles/users/`): How users should be configured (shell, tools, aliases)
2. **📦 Package Profiles** (`profiles/packages/`): What software should be installed system-wide  
3. **🏠 Hosts**: Individual machines and their assigned profiles
4. **👥 Users**: Individual user accounts and their personal configurations

## 🚀 Quick Start

```bash
# Clone this repository to /etc/nixos
sudo git clone https://github.com/marcolongol/nixos-started.git /etc/nixos
cd /etc/nixos

# If you want to start fresh (removes all personal configs)
nix develop -c task cleanup --force

# Enter the development environment (includes all tools)
nix develop

# Explore what's available
task --list
```

### Your First Commands
```bash
# See what user profiles are available
task user-profiles:list

# See what package profiles exist  
task package-profiles:list

# Check current hosts
task hosts:list

# Add a new user
task users:add name=alice email=alice@example.com fullname="Alice Smith"
```

## 📁 Directory Structure

```
/etc/nixos/
├── 🎛️ flake.nix              # Main Nix flake (auto-managed)
├── ⚙️ Taskfile.yml           # CLI task definitions  
├── 📖 README.md              # This file
├── 🧰 scripts/               # Management utilities (Node.js)
│   ├── user-profiles.js      # User profile operations
│   ├── users.js             # User account operations  
│   ├── package-profiles.js  # Package profile operations
│   └── hosts.js             # Host operations
├── 📚 lib/                   # Helper functions
├── 🏠 hosts/                 # Host-specific configurations
│   └── nixos-wsl/           # Example: WSL host
├── 👤 profiles/              # Reusable profile definitions
│   ├── packages/            # System-wide package sets
│   │   ├── common.nix       # Base packages for all systems
│   │   ├── desktop.nix      # GUI applications
│   │   ├── development.nix  # Programming tools
│   │   └── security.nix     # Security utilities
│   └── users/               # User environment templates  
│       ├── common.nix       # Base user config
│       ├── admin.nix        # System administrator
│       ├── developer.nix    # Software developer
│       └── minimal.nix      # Basic user
└── 👥 users/                 # Individual user configurations
    └── lucas.nix            # Personal user settings
```

## 🛠️ Management Operations

All operations use the simple `task` command. Here's what each area manages:

### 👤 User Profiles Management

User profiles define **how** users should be configured (shell setup, development tools, aliases).

```bash
# List all available user profiles
task user-profiles:list
```
```
📋 Available user profiles:
  • admin      # System administration tools
  • common     # Base configuration (auto-imported)
  • developer  # Development environment  
  • minimal    # Basic user setup
```

```bash
# See what's in the developer profile
task user-profiles:show name=developer
```
```
📄 Profile: developer
📁 File: /etc/nixos/profiles/users/developer.nix
──────────────────────────────────────────────────
# Developer User Profile
# Comprehensive development environment with modern tooling

{ pkgs, ... }: {
  # Import common user profile
  imports = [ ./common.nix ];

  # Development packages (extends common packages)
  home.packages = with pkgs; [
    # Terminal enhancements
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    eza
    bat
    fzf
    zoxide

    # Development tools  
    lazygit
    delta
    tree-sitter
    shellcheck

    # System utilities
    bottom
    dust
    procs
  ];

  # Shell configuration for developers
  programs.zsh = {
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      cat = "bat";
      cd = "z";
      top = "btm";
    };
  };
  
  # And much more...
}
```

```bash
# Create a new user profile
task user-profiles:add name=gamer

# Remove a user profile (protected profiles can't be removed)
task user-profiles:remove name=gamer
```

### 👥 Users Management

Individual user accounts with personal configurations and credentials.

```bash
# List all users
task users:list
```
```
👥 Available users:
  • lucas
```

```bash
# Add a new user with details
task users:add name=alice email=alice@example.com fullname="Alice Smith"
```
```
✅ User 'alice' created successfully
📁 Created: /etc/nixos/users/alice.nix
```

```bash
# Show user configuration  
task users:show name=alice
```
```
👤 User: alice
📁 File: /etc/nixos/users/alice.nix
──────────────────────────────────────────────────
# User configuration for alice
# Email: alice@example.com
# Full Name: Alice Smith

{ pkgs, ... }: {
  # Personal git configuration
  programs.git = {
    userName = "Alice Smith";
    userEmail = "alice@example.com";
  };

  # Add your personal packages here
  home.packages = with pkgs; [
    # Add packages you want for this user
  ];

  # Add your personal shell aliases here
  programs.zsh.shellAliases = {
    # Add your aliases here
  };
}
```

```bash
# Remove a user
task users:remove name=alice

# Validate user file syntax
task users:validate name=lucas
```

### 📦 Package Profiles Management

Package profiles define **what software** should be installed system-wide.

```bash
# List all package profiles
task package-profiles:list
```
```
📦 Available package profiles:
  • common       # Essential packages for all systems
  • desktop      # GUI environment packages  
  • development  # Programming tools and environments
  • security     # Security hardening and monitoring
```

```bash
# See what's in the development profile
task package-profiles:show name=development  
```
```
📦 Package Profile: development
📁 File: /etc/nixos/profiles/packages/development.nix
──────────────────────────────────────────────────
# Development tools and environments
# Essential programming tools

{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Version control
    git
    lazygit

    # Editors
    vscode

    # Programming languages
    nodejs  
    python3

    # Build essentials
    gcc
    gnumake

    # Containers
    docker
    docker-compose

    # Terminal tools
    tmux
    direnv
    fd

    # Language servers
    nixd

    # Code formatting
    nixfmt-classic
    alejandra
  ];

  # Development services
  virtualisation.docker.enable = lib.mkDefault true;
  programs.direnv.enable = lib.mkDefault true;
  documentation.dev.enable = lib.mkDefault true;
}
```

```bash
# Create a new package profile
task package-profiles:add name=gaming description="Gaming packages and tools"

# Remove a package profile  
task package-profiles:remove name=gaming
```

### 🏠 Hosts Management

Hosts represent individual machines and their assigned profiles and users.

```bash
# List all hosts
task hosts:list
```
```
🏠 Available hosts:
  • nixos-wsl
    📦 Profiles: common, development, security
    👥 Users: lucas
    📁 Host dir: ✅
```

```bash
# Show detailed host configuration
task hosts:show name=nixos-wsl
```
```
🏠 Host: nixos-wsl
══════════════════════════════════════════════════
Flake Configuration:
nixos-wsl = lib.mkSystem {
  hostname = "nixos-wsl";
  extraModules = [ inputs.nixos-wsl.nixosModules.default ];
  profiles = [ "common" "development" "security" ];
  users = [{
    name = "lucas";
    profiles = [ "developer" ];
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  }];
};

Host Directory Contents:
  📄 configuration.nix
  📄 default.nix
```

```bash
# Add a new host
task hosts:add name=desktop profiles=common,desktop,development

# Add a user to a host  
task hosts:add-user host=desktop name=alice profiles=developer groups=wheel,docker

# Remove user from host
task hosts:remove-user host=desktop name=alice

# Remove entire host
task hosts:remove name=desktop
```
## 🎓 Learning Path for Beginners

### Step 1: Understanding the Concepts
1. **User Profiles** = Templates for user environments (like VS Code profiles)
2. **Package Profiles** = Software bundles for different purposes  
3. **Users** = Individual people with personal settings
4. **Hosts** = Computers/servers that combine profiles and users

### Step 2: Explore What's Available
```bash
nix develop                    # Enter development environment
task user-profiles:list       # See available user templates
task package-profiles:list    # See available software bundles  
task users:list               # See configured users
task hosts:list               # See configured machines
```

### Step 3: Create Your First User
```bash
task users:add name=myname email=me@example.com fullname="My Name"
```

### Step 4: Add User to a Host
```bash
task hosts:add-user host=nixos-wsl name=myname profiles=developer
```

### Step 5: Apply Changes
```bash
task format                   # Format all Nix files
task check                    # Validate configuration
task build                    # Build new configuration
task switch                   # Apply changes (requires sudo)
```

## 🔨 Development Workflow

### Daily Operations
```bash
# Format and validate before committing
task format && task check

# Build and test changes
task build
task test       # Test without applying

# Apply to system  
task switch     # Make changes permanent
```

### Creating Custom Configurations

#### Custom User Profile
```bash
# Create new user profile
task user-profiles:add name=designer

# Edit the generated file
${EDITOR} profiles/users/designer.nix
```

Add design tools:
```nix
{ pkgs, ... }: {
  imports = [ ./common.nix ];
  
  home.packages = with pkgs; [
    gimp
    inkscape
    blender
    figma-linux
  ];
}
```

#### Custom Package Profile  
```bash
# Create new package profile
task package-profiles:add name=media description="Media production tools"

# Edit the generated file
${EDITOR} profiles/packages/media.nix
```

Add media packages:
```nix
{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    ffmpeg
    obs-studio
    audacity
    kdenlive
  ];
}
```

## 🌟 Real-World Examples

### Example 1: Family Computer Setup
```bash
# Create user profiles for different family members
task user-profiles:add name=parent
task user-profiles:add name=student  
task user-profiles:add name=gamer

# Create users
task users:add name=mom email=mom@family.com fullname="Mom"
task users:add name=dad email=dad@family.com fullname="Dad"  
task users:add name=kid email=kid@family.com fullname="Kid"

# Create family computer host
task hosts:add name=family-pc profiles=common,desktop

# Assign users to host with appropriate profiles
task hosts:add-user host=family-pc name=mom profiles=parent
task hosts:add-user host=family-pc name=dad profiles=parent
task hosts:add-user host=family-pc name=kid profiles=student,gamer
```

### Example 2: Development Team Setup
```bash
# Create specialized profiles
task user-profiles:add name=frontend-dev
task user-profiles:add name=backend-dev
task user-profiles:add name=devops

# Create team members
task users:add name=alice email=alice@company.com fullname="Alice Frontend"
task users:add name=bob email=bob@company.com fullname="Bob Backend"  
task users:add name=charlie email=charlie@company.com fullname="Charlie DevOps"

# Create development server
task hosts:add name=dev-server profiles=common,development,security

# Assign team members
task hosts:add-user host=dev-server name=alice profiles=frontend-dev
task hosts:add-user host=dev-server name=bob profiles=backend-dev  
task hosts:add-user host=dev-server name=charlie profiles=devops groups=wheel,docker
```

### Example 3: Multi-Host Infrastructure
```bash
# Create different types of hosts
task hosts:add name=web-server profiles=common,security
task hosts:add name=db-server profiles=common,security  
task hosts:add name=workstation profiles=common,desktop,development

# Add admin user to all hosts
task hosts:add-user host=web-server name=admin profiles=admin groups=wheel
task hosts:add-user host=db-server name=admin profiles=admin groups=wheel
task hosts:add-user host=workstation name=admin profiles=admin groups=wheel
```

## 🔧 Available Tools in Development Environment

When you run `nix develop`, you get access to:

| Tool | Purpose |
|------|---------|
| `task` | Task runner for all management operations |
| `nixfmt-classic` | Format Nix files consistently |
| `nil` | Nix language server for VS Code/editors |
| `nodejs_20` | Runtime for management scripts |
| `jq` / `yq-go` | JSON/YAML processing utilities |
| `git` | Version control |
| `shellcheck` | Shell script validation |

## 📋 Complete Task Reference

### User Profile Tasks
```bash
task user-profiles:list          # List all user profiles
task user-profiles:show name=X   # Show profile content
task user-profiles:add name=X    # Create new profile
task user-profiles:remove name=X # Remove profile
```

### User Tasks  
```bash
task users:list                  # List all users
task users:show name=X           # Show user config
task users:add name=X email=Y fullname="Z"  # Create user
task users:remove name=X         # Remove user
task users:validate name=X       # Validate syntax
```

### Package Profile Tasks
```bash
task package-profiles:list           # List all package profiles
task package-profiles:list-detailed  # List with details
task package-profiles:show name=X    # Show profile content  
task package-profiles:add name=X description="Y"  # Create profile
task package-profiles:remove name=X  # Remove profile
task package-profiles:validate name=X # Validate syntax
```

### Host Tasks
```bash
task hosts:list                  # List all hosts
task hosts:show name=X           # Show host config
task hosts:add name=X profiles=Y # Create host
task hosts:remove name=X         # Remove host  
task hosts:add-user host=X name=Y profiles=Z groups=W  # Add user to host
task hosts:remove-user host=X name=Y  # Remove user from host
```

### System Tasks
```bash
task format                      # Format all Nix files
task check                       # Validate Nix syntax
task build                       # Build configuration
task test                        # Test configuration
task switch                      # Apply configuration (requires sudo)
task cleanup --force             # Reset repository to clean state
```

## 🚨 Best Practices

### ✅ Do
- Always run `task format` before committing
- Use `task check` to validate syntax
- Test with `task build` before applying
- Keep user profiles focused and reusable
- Use descriptive names for profiles and users
- Document custom configurations in comments

### ❌ Don't  
- Manually edit `flake.nix` hosts section (use `task hosts:*`)
- Remove core profiles (common, admin, developer, minimal)
- Skip validation steps
- Put personal configs in shared profiles
- Use spaces in profile/user names

## 🤝 Contributing

This repository is designed to be forked and customized for your needs:

1. **Fork** this repository
2. **Customize** profiles for your use case
3. **Add** your users and hosts  
4. **Share** improvements back to the community

### Extending the System

#### Adding New Management Features
The management scripts are in `scripts/` and use a consistent pattern:
- Command-line argument parsing
- File system operations  
- Nix syntax generation
- Error handling and validation

#### Adding New Profile Types
You can extend the system with new profile categories:
1. Create new directory in `profiles/`
2. Add management script in `scripts/`
3. Update `Taskfile.yml` with new tasks
4. Update `lib/default.nix` if needed

## 📚 Learn More

### NixOS Resources
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Language Basics](https://nixos.org/guides/nix-language.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Flakes Introduction](https://nixos.wiki/wiki/Flakes)

### Infrastructure as Code
- [What is Infrastructure as Code?](https://en.wikipedia.org/wiki/Infrastructure_as_code)
- [Declarative vs Imperative](https://about.gitlab.com/topics/gitops/declarative-vs-imperative/)

## 🧹 Starting Fresh

If you cloned this repository and want to start with your own configuration:

```bash
# Reset the repository to a clean state
task cleanup --force
```

This will remove all personal configurations while keeping the core system intact.

---

## 📄 License

This project is open source. Feel free to use, modify, and share!

## 🙋‍♂️ Support

- 📖 Check this README for common tasks
- 🔍 Use `task --list` to see all available commands  
- 🛠️ Run `task check` to validate your configuration
- 💬 Create issues for bugs or feature requests

**Happy NixOS managing! 🚀**
