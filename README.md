# 🚀 My ## 🎯 What's In Here?

- **🧩 Modular Design**: Clean separation between user configs, package sets, and host definitions
- **🏠 Multi-Host Support**: Configurations for my laptop (`nixos-lt`) and WSL setup (`nixos-wsl`)
- **👤 Personal Profiles**: User profiles for different workflows (admin, developer, minimal)
- **📦 Package Collections**: Organized software bundles (desktop, development, security)
- **⚡ Developer Workflow**: Integrated development environment with task automational NixOS Configuration

> **My personal, modular NixOS setup - feel free to use as inspiration!**

[![GitHub Repository](https://img.shields.io/badge/GitHub-marcolongol%2Fnixos--config-blue?logo=github)](https://github.com/marcolongol/nixos-config)

This is my personal NixOS configuration that I use across my machines. It's organized in a modular way that makes it easy to manage different user profiles, package sets, and host configurations. While this is tailored to my specific needs, you're welcome to use it as inspiration for your own NixOS setup!

## 🎯 What Makes This Special?

- **🧩 Modular Design**: Clean separation between user configs, package sets, and host definitions
- **� Beginner Friendly**: Manual configuration with clear examples and structure
- **🔄 Infrastructure as Code**: Version-controlled, reproducible system configurations
- **⚡ Developer Experience**: Integrated development environment with all tools included

## 🔧 How It's Organized

This configuration follows NixOS best practices with a modular approach:
- **Declarative**: Everything is described in code
- **Reproducible**: Same config = identical systems across all my machines
- **Version Controlled**: Track changes, rollback safely
- **Modular**: Reuse configurations across different hosts

### ✨ Automatic "Common" Profile Inclusion

**Important**: The `common` profiles for both packages and users are automatically included in all configurations. You don't need to explicitly declare them!

- **Package Profiles**: The `common` package profile is automatically prepended to all host configurations
- **User Profiles**: The `common` user profile is automatically prepended to all user configurations

This means:
```nix
# Instead of writing:
profiles = [ "common" "desktop" "development" ];
users = [{ 
  name = "user"; 
  profiles = [ "common" "admin" "developer" ]; 
}];

# You can simply write:
profiles = [ "desktop" "development" ];
users = [{ 
  name = "user"; 
  profiles = [ "admin" "developer" ]; 
}];

# The system automatically becomes:
# profiles = [ "common" "desktop" "development" ];
# user.profiles = [ "common" "admin" "developer" ];
```

### My Setup Structure

1. **👤 User Profiles** (`profiles/users/`): Different user environment setups
2. **📦 Package Profiles** (`profiles/packages/`): Software collections for different purposes  
3. **🏠 Hosts**: My individual machines (`nixos-lt`, `nixos-wsl`)
4. **👥 Users**: My personal user accounts and configurations

## 🚀 Using This Configuration

If you want to use my configuration as inspiration for your own:

```bash
# Fork or clone this repository
git clone https://github.com/marcolongol/nixos-config.git /etc/nixos
cd /etc/nixos

# Enter the development environment (includes all tools)
nix develop

# Explore what's available
task --list
```

### Quick Commands
```bash
# Check Nix syntax
task check

# Format all Nix files
task format

# Build the configuration
task build

# Apply the configuration (requires sudo)
task switch
```

## 📁 Directory Structure

```
/etc/nixos/
├── 🎛️ flake.nix              # Main Nix flake configuration
├── 🔒 flake.lock             # Lock file for dependencies
├── ⚙️ Taskfile.yml           # Available task definitions  
├── 📖 README.md              # This file
├── 🖼️ assets/                # Static assets
│   └── default-wallpaper.png # Default system wallpaper
├── 📚 lib/                   # Helper functions and utilities
├── 🔧 overlays/              # Nixpkgs overlays and custom packages
│   ├── default.nix          # Main overlay loader
│   ├── custom-packages.nix  # Custom packages (nixvim configs, etc.)
│   ├── development.nix      # Development tool enhancements
│   └── overrides.nix        # Package overrides
├── 🏠 hosts/                 # Host-specific configurations
│   ├── nixos-lt/            # Example: Linux laptop host
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
    ├── default.nix          # Default user template
    ├── example.nix          # Example user configuration
    └── lucas.nix            # Personal user settings
```

## � Custom Packages & Overlays

This configuration includes a powerful overlay system that allows you to create custom packages and modify existing ones. The overlays support flake inputs, enabling advanced compositions like nixvim configurations.

### Available Custom Packages

- **`custom.nvim-ide`** - Full-featured Neovim IDE with LSP, Telescope, and more
- **`custom.nvim-minimal`** - Lightweight Neovim for servers
- **`devEnv.full`** - Complete development environment
- **`custom.hello-world`** - Example custom package

### Using Custom Packages

Use individual packages in any NixOS module:

```nix
environment.systemPackages = with pkgs; [
  custom.nvim-ide
  devEnv.full
];
```

### Adding Your Own Packages

To add custom packages, edit the overlay files in `overlays/`:

- `custom-packages.nix` - Add new custom packages and nixvim configurations
- `development.nix` - Add development environment bundles
- `overrides.nix` - Override existing nixpkgs packages

## �🛠️ Available Operations

Currently, the following core tasks are available via the `task` command:

### System Tasks
```bash
task help                        # Show available tasks
task format                      # Format all Nix files
task check                       # Check Nix syntax
task build                       # Build the NixOS configuration
task switch                      # Switch to the new NixOS configuration
task test                        # Test the NixOS configuration
```

> **Note**: Management scripts for users, profiles, and hosts have been temporarily removed. 
> These configurations can be managed manually by editing the respective `.nix` files.

### User Profile Management

User profiles define **how** users should be configured (shell setup, development tools, aliases).

> **Note**: User profile management scripts have been removed. You can view and edit user profiles directly:

```bash
# List all available user profiles
ls profiles/users/
```
admin.nix common.nix default.nix developer.nix minimal.nix
```

```bash
# View what's in the developer profile
cat profiles/users/developer.nix
```

This will show the actual Nix configuration for the developer user profile.

```bash
# Create a new user profile by copying an existing one
cp profiles/users/developer.nix profiles/users/gamer.nix
# Edit the new file
${EDITOR} profiles/users/gamer.nix

# To delete a profile, simply remove the file
rm profiles/users/gamer.nix
```

### Users Management

Individual user accounts with personal configurations and credentials.

> **Note**: User management scripts have been removed. You can manage users by directly editing files:

```bash
# List all users
ls users/
```
```
default.nix example.nix lucas.nix
```

```bash
# View user configuration
cat users/lucas.nix
```

To add a new user:
```bash
# Copy an existing user file
cp users/lucas.nix users/alice.nix
# Edit the new file with appropriate details
${EDITOR} users/alice.nix
# Update host configuration to include the new user
${EDITOR} hosts/nixos-wsl/default.nix
```

Example user configuration structure:
```nix
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

To remove a user:
```bash
# Remove the user file
rm users/alice.nix
# Update host configuration to remove the user reference
${EDITOR} hosts/nixos-wsl/default.nix
```

### Package Profiles Management

Package profiles define **what software** should be installed system-wide.

> **Note**: Package profile management scripts have been removed. You can view and edit package profiles directly:

```bash
# List all package profiles
ls profiles/packages/
```
```
common.nix default.nix desktop.nix development.nix security.nix
```

```bash
# See what's in the development profile
cat profiles/packages/development.nix
```

Example package profile structure:
```nix
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

To create or modify package profiles:
```bash
# Create a new package profile by copying an existing one
cp profiles/packages/development.nix profiles/packages/gaming.nix
# Edit the new file with gaming packages
${EDITOR} profiles/packages/gaming.nix

# To remove a package profile, simply delete the file
rm profiles/packages/gaming.nix
```

### Hosts Management

Hosts represent individual machines and their assigned profiles and users.

> **Note**: Host management scripts have been removed. You can view and edit host configurations directly:

```bash
# List all hosts
ls hosts/
```
```
nixos-lt/ nixos-wsl/
```

```bash
# View host configuration
cat hosts/nixos-wsl/default.nix
```

To modify a host configuration:
```bash
# Edit the host's main configuration
${EDITOR} hosts/nixos-wsl/default.nix
# Or edit specific configuration files
${EDITOR} hosts/nixos-wsl/configuration.nix
```
## 🎓 Using This as Inspiration

### Understanding My Setup
1. **User Profiles** = Templates for different user environments (admin, developer, minimal)
2. **Package Profiles** = Software collections for different purposes (desktop, development, security)  
3. **Users** = My personal accounts (`lucas.nix` and examples)
4. **Hosts** = My machines (`nixos-lt` for laptop, `nixos-wsl` for WSL)

### Exploring the Configuration
```bash
nix develop                    # Enter development environment
task --list                    # See available tasks
ls profiles/users/             # See my user templates
ls profiles/packages/          # See my software bundles  
ls users/                      # See my user configurations
ls hosts/                      # See my machine configurations
```

### Adapting for Your Use
To use this as a starting point for your own configuration:

```bash
# Copy my configuration as a starting point
git clone https://github.com/marcolongol/nixos-config.git your-nixos-config
cd your-nixos-config

# Remove my personal configs and create your own
rm users/lucas.nix
cp users/example.nix users/yourname.nix
# Edit the new user file
${EDITOR} users/yourname.nix

# Update host configurations to use your user
${EDITOR} hosts/nixos-wsl/default.nix
```

## 🔨 My Development Workflow

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

### Customizing for Your Needs

All configurations are managed by directly editing Nix files:

#### Creating Your Own User Profile
```bash
# Create new user profile based on mine
cp profiles/users/developer.nix profiles/users/yourprofile.nix
# Edit the new file
${EDITOR} profiles/users/yourprofile.nix
```

Add your preferred tools:
```nix
{ pkgs, ... }: {
  imports = [ ./common.nix ];
  
  home.packages = with pkgs; [
    # Add your preferred packages here
    your-favorite-editor
    your-tools
  ];
}
```

#### Creating Custom Package Collections  
```bash
# Create new package profile based on mine
cp profiles/packages/development.nix profiles/packages/yourpackages.nix
# Edit the new file
${EDITOR} profiles/packages/yourpackages.nix
```

## 🌟 Configuration Examples

> **Note**: These examples show how the modular structure can be adapted for different use cases. 
> You can use these patterns as inspiration for your own setup.

### Example 1: Multi-User Family Setup
The modular design makes it easy to support different family members:
```bash
# Different user profiles for family members
profiles/users/parent.nix      # Productivity and media tools
profiles/users/student.nix     # Educational software  
profiles/users/gamer.nix      # Gaming setup

# Individual users with personal settings
users/mom.nix                 # Mom's personal config
users/dad.nix                 # Dad's personal config
users/kid.nix                 # Kid's personal config

# Single family computer host
hosts/family-pc/              # Host combining all users
```

### Example 2: Development Team Environment
How the structure scales for team development:
```bash
# Specialized development profiles
profiles/users/frontend-dev.nix   # React, TypeScript, design tools
profiles/users/backend-dev.nix    # Go, databases, APIs
profiles/users/devops.nix        # Docker, Kubernetes, monitoring

# Team member configurations
users/alice.nix              # Frontend developer
users/bob.nix                # Backend developer  
users/charlie.nix            # DevOps engineer

# Different server types
hosts/dev-server/             # Development environment
hosts/staging-server/         # Staging environment
```

### Example 3: Personal Multi-Host Setup (Like Mine!)
My actual configuration across different machines:
```bash
# My user profiles for different contexts
profiles/users/admin.nix       # System administration
profiles/users/developer.nix   # Programming and development
profiles/users/minimal.nix     # Lightweight environments

# My package collections
profiles/packages/desktop.nix     # GUI applications
profiles/packages/development.nix # Programming tools
profiles/packages/security.nix    # Security utilities

# My personal user
users/lucas.nix               # My personal settings

# My machines
hosts/nixos-lt/               # My laptop configuration
hosts/nixos-wsl/              # My WSL development environment
```

## 🔧 Available Tools in Development Environment

When you run `nix develop`, you get access to:

| Tool | Purpose |
|------|---------|
| `task` | Task runner for core operations |
| `nixfmt-classic` | Format Nix files consistently |
| `nixd` | Nix language server for VS Code/editors |
| `nodejs_20` | Node.js runtime and tools |
| `typescript` | TypeScript compiler and tools |
| `ts-node` | TypeScript execution environment |

## 📋 Complete Task Reference

### System Tasks
```bash
task help                        # Show available tasks
task format                      # Format all Nix files
task check                       # Validate Nix syntax
task build                       # Build configuration
task test                        # Test configuration
task switch                      # Apply configuration (requires sudo)
```

> **Note**: User, profile, and host management tasks have been temporarily removed.
> These can be managed by manually editing the respective `.nix` files in the
> `users/`, `profiles/`, and `hosts/` directories.

## 🚨 Best Practices

### ✅ Do
- Always run `task format` before committing
- Use `task check` to validate syntax
- Test with `task build` before applying
- Keep user profiles focused and reusable
- Use descriptive names for profiles and users
- Document custom configurations in comments

### ❌ Don't  
- Manually edit `flake.nix` unless you understand the implications
- Remove core profiles (common, admin, developer, minimal)
- Skip validation steps
- Put personal configs in shared profiles
- Use spaces in profile/user names

## 🤝 Using This Configuration

This is my personal NixOS configuration, but you're welcome to:

1. **Fork** this repository as a starting point for your own setup
2. **Adapt** the profiles and structure for your needs
3. **Learn** from the modular organization  
4. **Share** improvements or interesting patterns you discover

### Making It Your Own

#### Starting Fresh with This Structure
1. Fork or clone this repository
2. Remove my personal configs (`users/lucas.nix`)
3. Create your own user configurations
4. Adapt the host configurations for your machines
5. Modify package profiles to match your software preferences

#### Understanding the Structure
- Look at how I organize profiles in `profiles/`
- See how hosts combine different profiles in `hosts/`
- Check out my personal user config in `users/lucas.nix`
- Notice how the flake ties everything together

## 🏠 About My Setup

### My Machines
- **nixos-lt**: My main laptop configuration with desktop environment
- **nixos-wsl**: My Windows Subsystem for Linux development environment

### My User Profiles
- **admin**: System administration and security tools
- **developer**: Programming languages, editors, and development tools
- **minimal**: Lightweight profile for basic usage

### My Package Collections
- **desktop**: GUI applications and desktop environment
- **development**: Programming tools and languages
- **security**: Security utilities and monitoring tools
- **common**: Base packages needed on all systems

## 📚 Learn More

### NixOS Resources
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Language Basics](https://nixos.org/guides/nix-language.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Flakes Introduction](https://nixos.wiki/wiki/Flakes)

### Infrastructure as Code
- [What is Infrastructure as Code?](https://en.wikipedia.org/wiki/Infrastructure_as_code)
- [Declarative vs Imperative](https://about.gitlab.com/topics/gitops/declarative-vs-imperative/)

## 🧹 Adapting This Configuration

If you want to use this as a starting point for your own configuration:

```bash
# Clone/fork this repository
git clone https://github.com/marcolongol/nixos-config.git my-nixos-config
cd my-nixos-config

# Remove my personal configs and create your own
rm users/lucas.nix
cp users/example.nix users/myuser.nix
${EDITOR} users/myuser.nix

# Update host configurations to use your setup
${EDITOR} hosts/nixos-wsl/default.nix

# Customize package profiles for your needs
${EDITOR} profiles/packages/development.nix
${EDITOR} profiles/packages/desktop.nix
```

---

## 📄 License

This project is open source. Feel free to use, modify, and share!

## 🙋‍♂️ Questions?

- 📖 Check this README for understanding the structure
- 🔍 Use `task --list` to see all available commands  
- 🛠️ Run `task check` to validate configurations
- 💬 Open an issue if you have questions about the setup

This is my personal configuration, but I hope it can serve as inspiration for your own NixOS journey! 🚀
