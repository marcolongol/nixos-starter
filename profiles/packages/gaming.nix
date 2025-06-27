# Gaming Profile
# Steam, gaming platforms, performance tools, and hybrid graphics optimizations
{ config, lib, pkgs, ... }: {
  # Gaming applications and tools
  environment.systemPackages = with pkgs; [
    # Gaming platforms
    steam
    lutris          # Alternative gaming platform for non-Steam games
    
    # Gaming performance and monitoring
    mangohud        # Gaming overlay for FPS and system stats
    protonup-qt     # Proton version manager for Steam
    
    # Gaming utilities
    gamemode        # Optimize system for gaming performance
    winetricks      # Windows compatibility layer utilities
    bottles         # User-friendly Wine frontend
  ];

  # System-level gaming support
  programs = {
    # Steam configuration
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server
      gamescopeSession.enable = true; # Enable GameScope for better gaming performance
      protontricks.enable = true; # Enable protontricks for game fixes
    };

    # GameMode for system optimization during gaming
    gamemode.enable = true;
  };

  # Gaming-optimized environment variables
  environment.sessionVariables = {
    # Steam Proton compatibility tools path
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    
    # Enable MangoHud for all games by default (can be disabled per-game)
    MANGOHUD = "1";
    
    # OpenGL threading optimizations for gaming
    __GL_THREADED_OPTIMIZATIONS = "1";
    
    # NVIDIA specific optimizations (only applies when NVIDIA GPU is active)
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
  };

  # Gaming configuration files
  environment.etc = {
    # System-wide MangoHud configuration
    "mangohud/MangoHud.conf".text = ''
      # MangoHud configuration for gaming overlay
      legacy_layout=false
      
      # GPU monitoring
      gpu_stats
      gpu_temp
      gpu_power
      gpu_load_change
      gpu_load_value=50,90
      gpu_load_color=FFFFFF,FFAA7F,CC0000
      gpu_text=GPU
      
      # CPU monitoring
      cpu_stats
      cpu_temp
      cpu_power
      cpu_load_change
      core_load_change
      cpu_load_value=50,90
      cpu_load_color=FFFFFF,FFAA7F,CC0000
      cpu_text=CPU
      
      # I/O and memory
      io_read
      io_write
      ram
      vram
      
      # FPS and performance
      fps
      frametime=0
      frame_timing=1
      fps_value=30,60
      fps_color=B22222,FFFD44,39F900
      
      # Display settings
      position=top-left
      text_color=FFFFFF
      round_corners=5
      background_alpha=0.4
      font_size=24
      show_fps_limit
      
      # Controls
      toggle_hud=Shift_R+F12
      toggle_logging=Shift_L+F2
      upload_log=F5
      
      # Output
      output_folder=/tmp
    '';
  };

  # Gaming shell aliases (system-wide)
  programs.bash.shellAliases = {
    # GPU monitoring and checking
    nvidia-check = "nvidia-smi";
    gpu-check = "glxinfo | grep 'OpenGL renderer'";
    
    # Gaming performance
    gaming-mode = "systemctl --user start gamemoded";
    gaming-stop = "systemctl --user stop gamemoded";
    
    # Proton management
    proton-update = "protonup-qt";
    
    # Optional: NVIDIA override for problematic games
    force-nvidia = "nvidia-offload";
  };

  # ZSH aliases (for users with ZSH)
  programs.zsh.shellAliases = {
    # GPU monitoring and checking
    nvidia-check = "nvidia-smi";
    gpu-check = "glxinfo | grep 'OpenGL renderer'";
    
    # Gaming performance
    gaming-mode = "systemctl --user start gamemoded";
    gaming-stop = "systemctl --user stop gamemoded";
    
    # Proton management
    proton-update = "protonup-qt";
    
    # Optional: NVIDIA override for problematic games
    force-nvidia = "nvidia-offload";
  };

  # Firewall configuration for gaming
  networking.firewall = {
    allowedTCPPorts = [
      # Steam
      27036 27037 # Steam Client
      # Additional gaming ports can be added here
    ];
    allowedUDPPorts = [
      # Steam
      27031 27036 # Steam Client
      # Additional gaming ports can be added here
    ];
  };
}
