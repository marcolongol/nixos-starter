#!/usr/bin/env node

/**
 * Hosts Management Utility
 * Manages host configurations in both flake.nix and hosts/ directory
 */

import { readFileSync, writeFileSync, existsSync, readdirSync, unlinkSync, mkdirSync } from 'fs';
import { join, resolve } from 'path';

const FLAKE_FILE = resolve('flake.nix');
const HOSTS_DIR = resolve('hosts');

class HostsManager {
  constructor() {
    this.flakeFile = FLAKE_FILE;
    this.hostsDir = HOSTS_DIR;
  }

  listHosts() {
    const content = readFileSync(this.flakeFile, 'utf8');
    const configsMatch = content.match(/nixosConfigurations\s*=\s*\{([\s\S]*?)\s*\};\s*\}/);
    
    if (!configsMatch) {
      console.log('🏠 No hosts found in configuration');
      return [];
    }

    const configsBlock = configsMatch[1];
    const hostMatches = configsBlock.match(/([\w-]+)\s*=\s*lib\.mkSystem\s*\{/g);
    
    if (!hostMatches) {
      console.log('🏠 No hosts found in configuration');
      return [];
    }

    const hosts = hostMatches.map(match => match.split('=')[0].trim());
    
    console.log('🏠 Available hosts:');
    hosts.forEach(host => {
      console.log(`  • ${host}`);
      this.showHostSummary(host);
    });
    
    return hosts;
  }

  showHostSummary(hostname) {
    const content = readFileSync(this.flakeFile, 'utf8');
    const hostRegex = new RegExp(`${hostname}\\s*=\\s*lib\\.mkSystem\\s*\\{([\\s\\S]*?)\\};`, 'm');
    const hostMatch = content.match(hostRegex);
    
    if (!hostMatch) {
      console.log(`    ❌ Configuration not found in flake.nix`);
      return;
    }

    const hostBlock = hostMatch[1];
    
    // Extract profiles
    const profilesMatch = hostBlock.match(/profiles\s*=\s*\[([^\]]*)\]/);
    const profiles = profilesMatch ? 
      profilesMatch[1].split('"').filter(p => p.trim() && !p.includes('[') && !p.includes(']')).map(p => p.trim()) : [];
    
    // Extract users
    const usersMatch = hostBlock.match(/users\s*=\s*\[([^\]]*)\]/s);
    const users = [];
    if (usersMatch) {
      const usersBlock = usersMatch[1];
      const userMatches = usersBlock.match(/{\s*name\s*=\s*"([^"]+)"/g);
      if (userMatches) {
        userMatches.forEach(match => {
          const nameMatch = match.match(/name\s*=\s*"([^"]+)"/);
          if (nameMatch) users.push(nameMatch[1]);
        });
      }
    }

    // Check if host directory exists
    const hostDir = join(this.hostsDir, hostname);
    const hasHostDir = existsSync(hostDir);

    console.log(`    📦 Profiles: ${profiles.length > 0 ? profiles.join(', ') : 'none'}`);
    console.log(`    👥 Users: ${users.length > 0 ? users.join(', ') : 'none'}`);
    console.log(`    📁 Host dir: ${hasHostDir ? '✅' : '❌'}`);
  }

  showHost(hostname) {
    const content = readFileSync(this.flakeFile, 'utf8');
    const hostRegex = new RegExp(`${hostname}\\s*=\\s*lib\\.mkSystem\\s*\\{([\\s\\S]*?)\\};`, 'm');
    const hostMatch = content.match(hostRegex);
    
    if (!hostMatch) {
      console.error(`❌ Host '${hostname}' not found in flake.nix`);
      return false;
    }

    console.log(`🏠 Host: ${hostname}`);
    console.log('═'.repeat(50));
    console.log('Flake Configuration:');
    console.log(hostMatch[0]);
    console.log();

    // Show host directory contents if it exists
    const hostDir = join(this.hostsDir, hostname);
    if (existsSync(hostDir)) {
      console.log('Host Directory Contents:');
      const files = readdirSync(hostDir);
      files.forEach(file => {
        console.log(`  📄 ${file}`);
      });
    } else {
      console.log('❌ Host directory does not exist');
    }

    return true;
  }

  addHost(hostname, options = {}) {
    const { profiles = ['common'], users = [], extraModules = [], system = 'x86_64-linux' } = options;
    
    // Check if host already exists
    const content = readFileSync(this.flakeFile, 'utf8');
    if (content.includes(`${hostname} = lib.mkSystem`)) {
      console.error(`❌ Host '${hostname}' already exists in flake.nix`);
      return false;
    }

    // Create host directory
    const hostDir = join(this.hostsDir, hostname);
    if (!existsSync(hostDir)) {
      mkdirSync(hostDir, { recursive: true });
    }

    // Create default.nix
    const defaultNix = `# Host Configuration Loader
# Loads the configuration.nix for ${hostname}

{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./configuration.nix ];
}
`;

    // Create configuration.nix
    const configurationNix = `# ${hostname} Configuration
# Host-specific configuration for ${hostname}

{ config, lib, pkgs, ... }: {
  networking.hostName = "${hostname}";

  # Add host-specific configuration here
}
`;

    writeFileSync(join(hostDir, 'default.nix'), defaultNix);
    writeFileSync(join(hostDir, 'configuration.nix'), configurationNix);

    // Add host to flake.nix
    this.addHostToFlake(hostname, { profiles, users, extraModules, system });

    console.log(`✅ Created host '${hostname}'`);
    console.log(`   📁 Directory: ${hostDir}`);
    console.log(`   📦 Profiles: ${profiles.join(', ')}`);
    console.log(`   👥 Users: ${users.length > 0 ? users.map(u => typeof u === 'string' ? u : u.name).join(', ') : 'none'}`);
    
    return true;
  }

  addHostToFlake(hostname, options) {
    let content = readFileSync(this.flakeFile, 'utf8');
    const { profiles, users, extraModules, system } = options;

    // Build the host configuration
    const profilesStr = `[ "${profiles.join('" "')}" ]`;
    const usersStr = users.length > 0 ? this.formatUsers(users) : '[]';
    const extraModulesStr = extraModules.length > 0 ? ` [ ${extraModules.join(' ')} ]` : '';

    const hostConfig = `          ${hostname} = lib.mkSystem {
            hostname = "${hostname}";${system !== 'x86_64-linux' ? `\n            system = "${system}";` : ''}${extraModulesStr ? `\n            extraModules =${extraModulesStr};` : ''}
            profiles = ${profilesStr};
            users = ${usersStr};
          };`;

    // Find the nixosConfigurations block and add the new host
    const configsRegex = /(nixosConfigurations\s*=\s*\{[\s\S]*?)(\s*\};\s*\};\s*\};\s*$)/;
    const match = content.match(configsRegex);
    
    if (match) {
      const configsSection = match[1];
      const afterConfigs = match[2];
      
      // Add the new host before the closing braces
      const newContent = `${configsSection}\n${hostConfig}\n        ${afterConfigs}`;
      content = content.replace(configsRegex, newContent);
      writeFileSync(this.flakeFile, content);
    } else {
      console.error('❌ Could not find nixosConfigurations section to update');
    }
  }

  formatUsers(users) {
    if (users.length === 0) return '[]';
    
    const userStrings = users.map(user => {
      if (typeof user === 'string') {
        return `{
              name = "${user}";
              profiles = [];
              extraGroups = [ "wheel" "networkmanager" ];
            }`;
      } else {
        const profilesStr = user.profiles ? `[ "${user.profiles.join('" "')}" ]` : '[]';
        const groupsStr = user.extraGroups ? `[ "${user.extraGroups.join('" "')}" ]` : '[ "wheel" "networkmanager" ]';
        return `{
              name = "${user.name}";
              profiles = ${profilesStr};
              extraGroups = ${groupsStr};
            }`;
      }
    });

    return `[\n            ${userStrings.join('\n            ')}\n          ]`;
  }

  removeHost(hostname) {
    // Check if host exists
    const content = readFileSync(this.flakeFile, 'utf8');
    if (!content.includes(`${hostname} = lib.mkSystem`)) {
      console.error(`❌ Host '${hostname}' not found in flake.nix`);
      return false;
    }

    // Remove from flake.nix
    this.removeHostFromFlake(hostname);

    // Ask about removing directory (for safety)
    const hostDir = join(this.hostsDir, hostname);
    if (existsSync(hostDir)) {
      console.log(`⚠️  Host directory '${hostDir}' still exists.`);
      console.log(`   Run 'rm -rf ${hostDir}' to remove it manually if desired.`);
    }

    console.log(`✅ Removed host '${hostname}' from flake.nix`);
    return true;
  }

  removeHostFromFlake(hostname) {
    let content = readFileSync(this.flakeFile, 'utf8');
    
    // Remove the host configuration block
    const hostRegex = new RegExp(`\\s*${hostname}\\s*=\\s*lib\\.mkSystem\\s*\\{[\\s\\S]*?\\};`, 'm');
    content = content.replace(hostRegex, '');
    
    writeFileSync(this.flakeFile, content);
  }

  addUserToHost(hostname, userData) {
    let content = readFileSync(this.flakeFile, 'utf8');
    
    const hostRegex = new RegExp(`(${hostname}\\s*=\\s*lib\\.mkSystem\\s*\\{[\\s\\S]*?users\\s*=\\s*\\[)([\\s\\S]*?)(\\][\\s\\S]*?\\};)`, 'm');
    const match = content.match(hostRegex);
    
    if (!match) {
      console.error(`❌ Host '${hostname}' not found or has invalid users configuration`);
      return false;
    }

    const before = match[1];
    const usersBlock = match[2];
    const after = match[3];

    // Check if user already exists
    if (usersBlock.includes(`name = "${userData.name}"`)) {
      console.error(`❌ User '${userData.name}' already exists in host '${hostname}'`);
      return false;
    }

    const newUser = this.formatUsers([userData]).slice(1, -1).trim(); // Remove outer brackets
    const newUsersBlock = usersBlock.trim() 
      ? `${usersBlock}${newUser}\n            `
      : `\n            ${newUser}\n            `;

    content = content.replace(hostRegex, `${before}${newUsersBlock}${after}`);
    writeFileSync(this.flakeFile, content);

    console.log(`✅ Added user '${userData.name}' to host '${hostname}'`);
    return true;
  }

  removeUserFromHost(hostname, username) {
    let content = readFileSync(this.flakeFile, 'utf8');
    
    const hostRegex = new RegExp(`(${hostname}\\s*=\\s*lib\\.mkSystem\\s*\\{[\\s\\S]*?users\\s*=\\s*\\[)([\\s\\S]*?)(\\][\\s\\S]*?\\};)`, 'm');
    const match = content.match(hostRegex);
    
    if (!match) {
      console.error(`❌ Host '${hostname}' not found`);
      return false;
    }

    const before = match[1];
    const usersBlock = match[2];
    const after = match[3];

    // Remove user block
    const userRegex = new RegExp(`\\s*{[^}]*name\\s*=\\s*"${username}"[^}]*}`, 's');
    
    if (!usersBlock.match(userRegex)) {
      console.error(`❌ User '${username}' not found in host '${hostname}'`);
      return false;
    }

    const newUsersBlock = usersBlock.replace(userRegex, '');
    content = content.replace(hostRegex, `${before}${newUsersBlock}${after}`);
    writeFileSync(this.flakeFile, content);

    console.log(`✅ Removed user '${username}' from host '${hostname}'`);
    return true;
  }
}

// CLI Interface
const manager = new HostsManager();
const [,, command, ...args] = process.argv;

switch (command) {
  case 'list':
    manager.listHosts();
    break;
    
  case 'show':
    const showHost = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!showHost) {
      console.error('❌ Usage: show name=HOSTNAME');
      process.exit(1);
    }
    manager.showHost(showHost);
    break;
    
  case 'add':
    const addHost = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    const profiles = args.find(arg => arg.startsWith('profiles='))?.split('=')[1]?.split(',') || ['common'];
    const system = args.find(arg => arg.startsWith('system='))?.split('=')[1] || 'x86_64-linux';
    
    if (!addHost) {
      console.error('❌ Usage: add name=HOSTNAME [profiles=profile1,profile2] [system=SYSTEM]');
      process.exit(1);
    }
    manager.addHost(addHost, { profiles: profiles.filter(p => p.trim()), system });
    break;
    
  case 'remove':
    const removeHost = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    if (!removeHost) {
      console.error('❌ Usage: remove name=HOSTNAME');
      process.exit(1);
    }
    manager.removeHost(removeHost);
    break;
    
  case 'add-user':
    const addUserHost = args.find(arg => arg.startsWith('host='))?.split('=')[1];
    const addUserName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    const addUserProfiles = args.find(arg => arg.startsWith('profiles='))?.split('=')[1]?.split(',') || [];
    const addUserGroups = args.find(arg => arg.startsWith('groups='))?.split('=')[1]?.split(',') || ['wheel', 'networkmanager'];
    
    if (!addUserHost || !addUserName) {
      console.error('❌ Usage: add-user host=HOSTNAME name=USERNAME [profiles=profile1,profile2] [groups=group1,group2]');
      process.exit(1);
    }
    
    manager.addUserToHost(addUserHost, {
      name: addUserName,
      profiles: addUserProfiles.filter(p => p.trim()),
      extraGroups: addUserGroups.filter(g => g.trim())
    });
    break;
    
  case 'remove-user':
    const removeUserHost = args.find(arg => arg.startsWith('host='))?.split('=')[1];
    const removeUserName = args.find(arg => arg.startsWith('name='))?.split('=')[1];
    
    if (!removeUserHost || !removeUserName) {
      console.error('❌ Usage: remove-user host=HOSTNAME name=USERNAME');
      process.exit(1);
    }
    manager.removeUserFromHost(removeUserHost, removeUserName);
    break;
    
  default:
    console.log(`
🛠️  Hosts Management

Usage:
  node scripts/hosts.js <command> [options]

Commands:
  list                                    List all hosts
  show name=HOST                          Show host configuration
  add name=HOST [profiles=p1,p2] [system=SYSTEM]
                                         Create new host
  remove name=HOST                        Remove host
  add-user host=HOST name=USER [profiles=p1,p2] [groups=g1,g2]
                                         Add user to host
  remove-user host=HOST name=USER         Remove user from host

Examples:
  node scripts/hosts.js list
  node scripts/hosts.js add name=desktop profiles=common,desktop,development
  node scripts/hosts.js show name=nixos-wsl
  node scripts/hosts.js add-user host=desktop name=alice profiles=developer groups=wheel,docker
  node scripts/hosts.js remove name=desktop
`);
}
