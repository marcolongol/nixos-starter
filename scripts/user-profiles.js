#!/usr/bin/env node

/**
 * User Profile Management Utility
 * Manages NixOS user profiles in profiles/users/
 */

import { readFileSync, writeFileSync, existsSync, readdirSync, unlinkSync } from 'fs';
import { join, resolve } from 'path';

const PROFILES_DIR = resolve('profiles/users');
const PROFILES_INDEX = join(PROFILES_DIR, 'default.nix');

class UserProfileManager {
  constructor() {
    this.profilesDir = PROFILES_DIR;
    this.indexFile = PROFILES_INDEX;
  }

  listProfiles() {
    const profiles = readdirSync(this.profilesDir)
      .filter(f => f.endsWith('.nix') && f !== 'default.nix')
      .map(f => f.replace('.nix', ''));
    
    console.log('📋 Available user profiles:');
    profiles.forEach(profile => console.log(`  • ${profile}`));
    return profiles;
  }

  showProfile(name) {
    const profileFile = join(this.profilesDir, `${name}.nix`);
    if (!existsSync(profileFile)) {
      console.error(`❌ Profile '${name}' not found`);
      return false;
    }

    const content = readFileSync(profileFile, 'utf8');
    console.log(`📄 Profile: ${name}`);
    console.log(`📁 File: ${profileFile}`);
    console.log('─'.repeat(50));
    console.log(content);
    return true;
  }

  addProfile(name) {
    const profileFile = join(this.profilesDir, `${name}.nix`);
    
    if (existsSync(profileFile)) {
      console.error(`❌ Profile '${name}' already exists`);
      return false;
    }

    const template = `# User Profile: ${name}
{ pkgs, ... }: {
  # Import common profile
  imports = [ ./common.nix ];

  # Home packages specific to ${name} profile
  home.packages = with pkgs; [
    # Add packages here
  ];

  # Program configurations
  programs = {
    # Configure programs here
  };

  # Shell aliases
  programs.zsh.shellAliases = {
    # Add aliases here
  };
}
`;

    writeFileSync(profileFile, template);
    console.log(`✅ Created profile '${name}' at ${profileFile}`);
    
    this.updateIndex();
    return true;
  }

  removeProfile(name) {
    if (name === 'common') {
      console.error(`❌ Cannot remove 'common' profile - it's required by the system`);
      return false;
    }

    const profileFile = join(this.profilesDir, `${name}.nix`);
    
    if (!existsSync(profileFile)) {
      console.error(`❌ Profile '${name}' not found`);
      return false;
    }

    unlinkSync(profileFile);
    console.log(`✅ Removed profile '${name}'`);
    
    this.updateIndex();
    return true;
  }

  updateIndex() {
    const profiles = readdirSync(this.profilesDir)
      .filter(f => f.endsWith('.nix') && f !== 'default.nix')
      .map(f => f.replace('.nix', ''));

    const indexContent = `# User Profiles Index
# Auto-generated - do not edit manually
{
${profiles.map(p => `  ${p} = import ./${p}.nix;`).join('\n')}
}
`;

    writeFileSync(this.indexFile, indexContent);
    console.log(`📝 Updated profiles index with ${profiles.length} profiles`);
  }
}

// CLI Interface
const manager = new UserProfileManager();
const [,, command, ...args] = process.argv;

switch (command) {
  case 'list':
    manager.listProfiles();
    break;
    
  case 'show':
    const showName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!showName) {
      console.error('❌ Usage: show name=PROFILE_NAME');
      process.exit(1);
    }
    manager.showProfile(showName);
    break;
    
  case 'add':
    const addName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!addName) {
      console.error('❌ Usage: add name=PROFILE_NAME');
      process.exit(1);
    }
    manager.addProfile(addName);
    break;
    
  case 'remove':
    const removeName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!removeName) {
      console.error('❌ Usage: remove name=PROFILE_NAME');
      process.exit(1);
    }
    manager.removeProfile(removeName);
    break;
    
  default:
    console.log(`
🛠️  User Profile Management

Usage:
  node scripts/user-profiles.js <command> [options]

Commands:
  list                     List all user profiles
  show name=PROFILE        Show profile content
  add name=PROFILE         Create new profile
  remove name=PROFILE      Remove profile

Examples:
  node scripts/user-profiles.js list
  node scripts/user-profiles.js add name=gamer
  node scripts/user-profiles.js show name=developer
  node scripts/user-profiles.js remove name=gamer
`);
}
