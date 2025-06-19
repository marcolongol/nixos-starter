#!/usr/bin/env node

/**
 * NixOS Configuration Repository Cleanup Utility
 * 
 * This script removes all customized configurations and resets the repository
 * to a clean state suitable for starting your own configuration.
 * 
 * Usage:
 *   node scripts/cleanup.js --force
 *   task cleanup --force
 */

import { readdir, rm, writeFile } from 'fs/promises';
import { join } from 'path';
import { existsSync } from 'fs';

const REPO_ROOT = process.cwd();

// Files and directories to clean up
const CLEANUP_TARGETS = {
  // User-specific files (remove all except example)
  users: {
    path: 'users',
    keep: ['default.nix', 'example.nix'],
    description: 'individual user configurations'
  },
  
  // Custom user profiles (keep only core ones)
  userProfiles: {
    path: 'profiles/users',
    keep: ['common.nix', 'admin.nix', 'developer.nix', 'minimal.nix', 'default.nix'],
    description: 'custom user profiles'
  },
  
  // Custom package profiles (keep only core ones)
  packageProfiles: {
    path: 'profiles/packages',
    keep: ['common.nix', 'desktop.nix', 'development.nix', 'security.nix', 'default.nix'],
    description: 'custom package profiles'
  },
  
  // Host configurations (keep only example)
  hosts: {
    path: 'hosts',
    keep: ['nixos-wsl'],
    description: 'custom host configurations'
  }
};

// Reset flake.nix to minimal state
const MINIMAL_FLAKE = `{
  description = "NixOS Configuration Management System";

  inputs = {
    # nixpkgs - Nix Packages collection
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nixos-wsl - NixOS-WSL modules
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # flake-parts - very lightweight flake framework
    # https://flake.parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # home-manager - home user modules
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, ... }@inputs:
    let
      lib = import ./lib {
        inherit inputs;
        hostsDir = ./hosts;
      };
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Task runner
            go-task

            # Nix tools
            nixfmt-classic
            nil # Nix language server

            # Development tools for parsing and manipulating Nix files
            nodejs_20
            nodePackages.typescript
            nodePackages.ts-node

            # Alternative: Python with parsing libraries
            python3
            python3Packages.lark

            # Shell scripting tools
            shellcheck
            shfmt

            # JSON/YAML processing
            jq
            yq-go

            # Git for version control
            git
          ];

          shellHook = ''
            echo "🚀 NixOS Config Management Environment"
            echo "Available tools:"
            echo "  - task: Run management tasks"
            echo "  - nixfmt: Format Nix files"
            echo "  - nil: Nix language server"
            echo ""
            echo "Run 'task --list' to see available tasks"
            echo "Run 'task cleanup --force' to reset to clean state"
          '';
        };
      };
      flake = {
        nixosConfigurations = {
          # Add your host configurations here
          # Example:
          # my-host = lib.mkSystem {
          #   hostname = "my-host";
          #   profiles = [ "common" "development" ];
          #   users = [{
          #     name = "your-username";
          #     profiles = [ "developer" ];
          #     extraGroups = [ "wheel" "networkmanager" ];
          #   }];
          # };
        };
      };
    };
}
`;

async function cleanupDirectory(targetConfig) {
  const { path, keep, description } = targetConfig;
  const fullPath = join(REPO_ROOT, path);
  
  if (!existsSync(fullPath)) {
    console.log(`⚠️  Directory ${path} doesn't exist, skipping...`);
    return;
  }

  try {
    const entries = await readdir(fullPath, { withFileTypes: true });
    let removedCount = 0;

    for (const entry of entries) {
      const shouldKeep = keep.includes(entry.name);
      
      if (!shouldKeep) {
        const entryPath = join(fullPath, entry.name);
        await rm(entryPath, { recursive: true, force: true });
        removedCount++;
        console.log(`  🗑️  Removed ${entry.isDirectory() ? 'directory' : 'file'}: ${entry.name}`);
      }
    }

    if (removedCount > 0) {
      console.log(`✅ Cleaned ${description}: ${removedCount} items removed`);
    } else {
      console.log(`✨ ${description}: already clean`);
    }
    
  } catch (error) {
    console.error(`❌ Error cleaning ${path}:`, error.message);
  }
}

async function resetFlake() {
  try {
    await writeFile(join(REPO_ROOT, 'flake.nix'), MINIMAL_FLAKE);
    console.log('✅ Reset flake.nix to minimal configuration');
  } catch (error) {
    console.error('❌ Error resetting flake.nix:', error.message);
  }
}

async function showSummary() {
  console.log('\n📋 Cleanup Summary');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('✅ Repository cleaned and ready for your own configuration!');
  console.log('');
  console.log('🔒 What was preserved:');
  console.log('  📁 Core user profiles (common, admin, developer, minimal)');
  console.log('  📁 Core package profiles (common, desktop, development, security)');
  console.log('  📁 Example files (users/example.nix, hosts/nixos-wsl)');
  console.log('  📁 All management utilities and documentation');
  console.log('  📁 Scripts and task configuration');
  console.log('');
  console.log('🗑️  What was removed:');
  console.log('  ❌ All custom user configurations');
  console.log('  ❌ All custom user profiles');
  console.log('  ❌ All custom package profiles');
  console.log('  ❌ All custom host configurations');
  console.log('  ❌ Host entries from flake.nix');
  console.log('');
  console.log('🚀 Next steps:');
  console.log('  1. Add your user: task users:add name=yourname email=your@email.com');
  console.log('  2. Create your host: task hosts:add name=yourhostname profiles=common,development');
  console.log('  3. Add yourself to host: task hosts:add-user host=yourhostname name=yourname profiles=developer');
  console.log('  4. Apply changes: task format && task check && task build');
  console.log('');
  console.log('📚 Need help? Check the README.md for detailed examples!');
}

function showUsage() {
  console.log('🧹 NixOS Configuration Repository Cleanup');
  console.log('═══════════════════════════════════════════════');
  console.log('');
  console.log('⚠️  This will remove ALL customized configurations and reset the repository');
  console.log('   to a clean state suitable for starting your own configuration.');
  console.log('');
  console.log('🔒 What will be preserved:');
  console.log('  • Core user profiles (common, admin, developer, minimal)');
  console.log('  • Core package profiles (common, desktop, development, security)');
  console.log('  • Example files and documentation');
  console.log('  • All management scripts and utilities');
  console.log('');
  console.log('🗑️  What will be removed:');
  console.log('  • All personal user configurations in users/');
  console.log('  • All custom profiles in profiles/users/ and profiles/packages/');
  console.log('  • All custom host configurations in hosts/');
  console.log('  • Host definitions from flake.nix');
  console.log('');
  console.log('⚡ Usage:');
  console.log('  node scripts/cleanup.js --force');
  console.log('  task cleanup --force');
  console.log('');
  console.log('⚠️  This action cannot be undone! Make sure you have backups if needed.');
}

async function main() {
  const args = process.argv.slice(2);
  const forceCleanup = args.includes('--force') || args.includes('-f');

  if (!forceCleanup) {
    showUsage();
    return;
  }

  console.log('🧹 NixOS Configuration Repository Cleanup');
  console.log('═══════════════════════════════════════════════');
  console.log('🔄 Starting cleanup process...');
  console.log('');

  // Clean up each target directory
  for (const [name, config] of Object.entries(CLEANUP_TARGETS)) {
    console.log(`🧽 Cleaning ${config.description}...`);
    await cleanupDirectory(config);
    console.log('');
  }

  // Reset flake.nix
  console.log('🔄 Resetting flake.nix...');
  await resetFlake();
  console.log('');

  await showSummary();
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(console.error);
}
