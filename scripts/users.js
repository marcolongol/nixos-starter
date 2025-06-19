#!/usr/bin/env node

/**
 * Users Management Utility
 * Manages individual user configuration files in users/
 */

import { readFileSync, writeFileSync, existsSync, readdirSync, unlinkSync } from 'fs';
import { join, resolve } from 'path';

const USERS_DIR = resolve('users');

class UsersManager {
  constructor() {
    this.usersDir = USERS_DIR;
  }

  listUsers() {
    const users = readdirSync(this.usersDir)
      .filter(f => f.endsWith('.nix') && f !== 'default.nix')
      .map(f => f.replace('.nix', ''));
    
    console.log('👥 Available users:');
    users.forEach(user => console.log(`  • ${user}`));
    return users;
  }

  showUser(name) {
    const userFile = join(this.usersDir, `${name}.nix`);
    if (!existsSync(userFile)) {
      console.error(`❌ User '${name}' not found`);
      return false;
    }

    const content = readFileSync(userFile, 'utf8');
    console.log(`👤 User: ${name}`);
    console.log(`📁 File: ${userFile}`);
    console.log('─'.repeat(50));
    console.log(content);
    return true;
  }

  addUser(name, email = '', fullName = '') {
    const userFile = join(this.usersDir, `${name}.nix`);
    
    if (existsSync(userFile)) {
      console.error(`❌ User '${name}' already exists`);
      return false;
    }

    const template = `# ${fullName || name}'s Individual User Configuration
# Personal configurations specific to ${name}

{ lib, pkgs, ... }: {
  # Personal git configuration
  programs.git = {
    userName = "${fullName || name}";${email ? `\n    userEmail = "${email}";` : ''}
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Personal packages
  home.packages = with pkgs; [
    # Add personal packages here
  ];

  # Personal shell aliases
  programs.zsh.shellAliases = {
    # Add personal aliases here
  };

  # Personal program configurations
  programs = {
    # Configure personal programs here
  };

  # Custom home-manager configurations
  home = {
    # Add home configurations here
  };
}
`;

    writeFileSync(userFile, template);
    console.log(`✅ Created user '${name}' at ${userFile}`);
    
    return true;
  }

  removeUser(name) {
    const userFile = join(this.usersDir, `${name}.nix`);
    
    if (!existsSync(userFile)) {
      console.error(`❌ User '${name}' not found`);
      return false;
    }

    unlinkSync(userFile);
    console.log(`✅ Removed user '${name}'`);
    
    return true;
  }
}

// CLI Interface
const manager = new UsersManager();
const [,, command, ...args] = process.argv;

switch (command) {
  case 'list':
    manager.listUsers();
    break;
    
  case 'show':
    const showName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!showName) {
      console.error('❌ Usage: show name=USER_NAME');
      process.exit(1);
    }
    manager.showUser(showName);
    break;
    
  case 'add':
    const addName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    const email = args.find(arg => arg.startsWith('email='))?.split('=')[1] || '';
    const fullName = args.find(arg => arg.startsWith('fullname='))?.split('=')[1] || '';
    
    if (!addName) {
      console.error('❌ Usage: add name=USER_NAME [email=EMAIL] [fullname="FULL NAME"]');
      process.exit(1);
    }
    manager.addUser(addName, email, fullName);
    break;
    
  case 'remove':
    const removeName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!removeName) {
      console.error('❌ Usage: remove name=USER_NAME');
      process.exit(1);
    }
    manager.removeUser(removeName);
    break;
    
  default:
    console.log(`
🛠️  Users Management

Usage:
  node scripts/users.js <command> [options]

Commands:
  list                     List all users
  show name=USER           Show user configuration
  add name=USER [email=EMAIL] [fullname="FULL NAME"]
                          Create new user
  remove name=USER         Remove user

Examples:
  node scripts/users.js list
  node scripts/users.js add name=john email=john@example.com fullname="John Doe"
  node scripts/users.js show name=lucas
  node scripts/users.js remove name=john
`);
}
