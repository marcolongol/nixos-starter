#!/usr/bin/env node

/**
 * Package Profiles Management Utility
 * Manages system-wide package profiles in profiles/packages/
 */

import { readFileSync, writeFileSync, existsSync, readdirSync, unlinkSync } from 'fs';
import { join, resolve } from 'path';

const PACKAGE_PROFILES_DIR = resolve('profiles/packages');
const PACKAGE_PROFILES_INDEX = join(PACKAGE_PROFILES_DIR, 'default.nix');

class PackageProfilesManager {
  constructor() {
    this.profilesDir = PACKAGE_PROFILES_DIR;
    this.indexFile = PACKAGE_PROFILES_INDEX;
  }

  listProfiles() {
    const profiles = readdirSync(this.profilesDir)
      .filter(f => f.endsWith('.nix') && f !== 'default.nix')
      .map(f => f.replace('.nix', ''));
    
    console.log('📦 Available package profiles:');
    profiles.forEach(profile => console.log(`  • ${profile}`));
    return profiles;
  }

  showProfile(name) {
    const profileFile = join(this.profilesDir, `${name}.nix`);
    if (!existsSync(profileFile)) {
      console.error(`❌ Package profile '${name}' not found`);
      return false;
    }

    const content = readFileSync(profileFile, 'utf8');
    console.log(`📦 Package Profile: ${name}`);
    console.log(`📁 File: ${profileFile}`);
    console.log('─'.repeat(50));
    console.log(content);
    return true;
  }

  addProfile(name, description = '') {
    const profileFile = join(this.profilesDir, `${name}.nix`);
    
    if (existsSync(profileFile)) {
      console.error(`❌ Package profile '${name}' already exists`);
      return false;
    }

    const template = `# ${name} Package Profile
${description ? `# ${description}` : `# System-wide packages for ${name}`}

{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Add system-wide packages here
  ];

  # System services for ${name}
  # services = {
  #   # Configure services here
  # };

  # System configuration for ${name}
  # programs = {
  #   # Configure programs here
  # };

  # Environment variables
  # environment.variables = {
  #   # Add environment variables here
  # };
}
`;

    writeFileSync(profileFile, template);
    console.log(`✅ Created package profile '${name}' at ${profileFile}`);
    
    this.updateIndex();
    return true;
  }

  removeProfile(name) {
    // Prevent removal of essential profiles
    const coreProfiles = ['common'];
    if (coreProfiles.includes(name)) {
      console.error(`❌ Cannot remove core package profile '${name}' - it's required by the system`);
      return false;
    }

    const profileFile = join(this.profilesDir, `${name}.nix`);
    
    if (!existsSync(profileFile)) {
      console.error(`❌ Package profile '${name}' not found`);
      return false;
    }

    unlinkSync(profileFile);
    console.log(`✅ Removed package profile '${name}'`);
    
    this.updateIndex();
    return true;
  }

  updateIndex() {
    const profiles = readdirSync(this.profilesDir)
      .filter(f => f.endsWith('.nix') && f !== 'default.nix')
      .map(f => f.replace('.nix', ''));

    // Read the current index to preserve the structure
    let content = readFileSync(this.indexFile, 'utf8');
    
    // Update the availableProfiles list in the file
    const availableProfilesRegex = /(availableProfiles = let[\s\S]*?profileNames = map[\s\S]*?in) profileNames;/;
    
    if (content.match(availableProfilesRegex)) {
      // The index auto-discovers profiles, so we just need to make sure it's valid
      console.log(`📝 Package profiles index auto-discovers ${profiles.length} profiles`);
    } else {
      console.log(`📝 Package profiles index handles ${profiles.length} profiles`);
    }
    
    return true;
  }

  extractPackages(content) {
    const packagesRegex = /environment\.systemPackages\s*=\s*with\s+pkgs;\s*\[([\s\S]*?)\];/;
    const match = content.match(packagesRegex);
    
    if (match) {
      const packagesText = match[1];
      return packagesText
        .split('\n')
        .map(line => line.trim())
        .filter(line => line && !line.startsWith('#'))
        .map(line => line.replace(/,$/, ''));
    }
    
    return [];
  }

  listProfilesDetailed() {
    const profiles = readdirSync(this.profilesDir)
      .filter(f => f.endsWith('.nix') && f !== 'default.nix')
      .map(f => f.replace('.nix', ''));
    
    console.log('📦 Package profiles with details:');
    console.log('═'.repeat(60));
    
    profiles.forEach(profile => {
      const profileFile = join(this.profilesDir, `${profile}.nix`);
      try {
        const content = readFileSync(profileFile, 'utf8');
        const packages = this.extractPackages(content);
        const descriptionMatch = content.match(/^# (.+)$/m);
        const description = descriptionMatch ? descriptionMatch[1] : 'No description';
        
        console.log(`📦 ${profile}`);
        console.log(`   Description: ${description}`);
        console.log(`   Packages: ${packages.length} packages`);
        if (packages.length > 0 && packages.length <= 5) {
          console.log(`   Sample: ${packages.slice(0, 3).join(', ')}${packages.length > 3 ? '...' : ''}`);
        }
        console.log(`   File: ${profileFile}`);
        console.log('─'.repeat(40));
      } catch (error) {
        console.log(`📦 ${profile} - Error reading file`);
        console.log('─'.repeat(40));
      }
    });
    
    return profiles;
  }

  validateProfile(name) {
    const profileFile = join(this.profilesDir, `${name}.nix`);
    
    if (!existsSync(profileFile)) {
      console.error(`❌ Package profile '${name}' not found`);
      return false;
    }

    try {
      const content = readFileSync(profileFile, 'utf8');
      
      // Basic Nix syntax validation
      if (!content.includes('{') || !content.includes('}')) {
        console.error(`❌ Invalid Nix syntax in ${name}.nix`);
        return false;
      }

      // Check for required structure
      if (!content.includes('environment.systemPackages')) {
        console.log(`⚠️  Warning: ${name}.nix doesn't define systemPackages`);
      }

      console.log(`✅ Package profile '${name}.nix' is valid`);
      return true;
    } catch (error) {
      console.error(`❌ Error reading package profile: ${error.message}`);
      return false;
    }
  }
}

// CLI Interface
const manager = new PackageProfilesManager();
const [,, command, ...args] = process.argv;

switch (command) {
  case 'list':
    manager.listProfiles();
    break;
    
  case 'list-detailed':
    manager.listProfilesDetailed();
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
    const description = args.find(arg => arg.startsWith('description='))?.split('=')[1] || '';
    
    if (!addName) {
      console.error('❌ Usage: add name=PROFILE_NAME [description="DESCRIPTION"]');
      process.exit(1);
    }
    manager.addProfile(addName, description);
    break;
    
  case 'remove':
    const removeName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!removeName) {
      console.error('❌ Usage: remove name=PROFILE_NAME');
      process.exit(1);
    }
    manager.removeProfile(removeName);
    break;
    
  case 'validate':
    const validateName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!validateName) {
      console.error('❌ Usage: validate name=PROFILE_NAME');
      process.exit(1);
    }
    manager.validateProfile(validateName);
    break;
    
  default:
    console.log(`
🛠️  Package Profiles Management

Usage:
  node scripts/package-profiles.js <command> [options]

Commands:
  list                     List all package profiles
  list-detailed           List profiles with detailed info
  show name=PROFILE        Show profile content
  add name=PROFILE [description="DESC"]
                          Create new package profile
  remove name=PROFILE      Remove package profile
  validate name=PROFILE    Validate profile syntax

Examples:
  node scripts/package-profiles.js list
  node scripts/package-profiles.js add name=gaming description="Gaming packages and tools"
  node scripts/package-profiles.js show name=development
  node scripts/package-profiles.js remove name=gaming
  node scripts/package-profiles.js validate name=common
`);
}
