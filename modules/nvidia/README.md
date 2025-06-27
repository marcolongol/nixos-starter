# NVIDIA Graphics Module

This module provides comprehensive NVIDIA driver configuration for NixOS with support for:

- Basic NVIDIA driver setup
- Hybrid graphics (NVIDIA Optimus/Prime)
- Power management
- CUDA support
- OpenCL support
- Vulkan support

## Basic Usage

Add to your `configuration.nix`:

```nix
{
  imports = [ ./modules/nvidia ];
  
  hardware.nvidia-custom.enable = true;
}
```

## Hybrid Graphics Setup

For laptops with both integrated and discrete NVIDIA graphics:

### 1. Find your GPU bus IDs

```bash
lspci | grep -E "(VGA|3D)"
```

Example output:

```text
00:02.0 VGA compatible controller: Intel Corporation ...
01:00.0 3D controller: NVIDIA Corporation ...
```

### 2. Configure hybrid graphics

```nix
{
  hardware.nvidia-custom = {
    enable = true;
    hybrid = {
      enable = true;
      mode = "offload"; # or "sync" or "reverse-sync"
      busId = {
        intel = "PCI:0:2:0";   # Convert 00:02.0 to PCI:0:2:0
        nvidia = "PCI:1:0:0";  # Convert 01:00.0 to PCI:1:0:0
      };
    };
  };
}
```

## Hybrid Graphics Modes

- **offload**: Use integrated GPU by default, NVIDIA on demand (best for battery life)
- **sync**: Always use NVIDIA GPU (best performance, higher power consumption)
- **reverse-sync**: Use NVIDIA as primary, integrated as secondary

## Running Applications with NVIDIA (Offload Mode)

When using offload mode, prefix applications with the offload command:

```bash
nvidia-offload glxinfo | grep "OpenGL renderer"
nvidia-offload steam
```

## Advanced Configuration

### CUDA Support

```nix
{
  hardware.nvidia-custom = {
    enable = true;
    enableCUDA = true;
  };
}
```

### Power Management (Experimental)

```nix
{
  hardware.nvidia-custom = {
    enable = true;
    powerManagement = {
      enable = true;
      finegrained = true; # For RTX 30 series and newer
    };
  };
}
```

### Custom Driver Version

```nix
{
  hardware.nvidia-custom = {
    enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    # or nvidiaPackages.legacy_470, nvidiaPackages.legacy_390, etc.
  };
}
```

### Force Composition Pipeline (Fix Screen Tearing)

```nix
{
  hardware.nvidia-custom = {
    enable = true;
    settings.forceCompositionPipeline = true;
  };
}
```

## Complete Example for nixos-lt

```nix
{
  imports = [ ./modules/nvidia ];
  
  hardware.nvidia-custom = {
    enable = true;
    
    # Hybrid graphics setup
    hybrid = {
      enable = true;
      mode = "offload";
      busId = {
        intel = "PCI:0:2:0";   # Replace with your actual bus ID
        nvidia = "PCI:1:0:0";  # Replace with your actual bus ID
      };
    };
    
    # Power management
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    
    # Enable additional features
    enableCUDA = true;
    enableVulkan = true;
    
    # Settings
    settings = {
      modesetting = true;
      useGBM = true;
      forceCompositionPipeline = false; # Enable if you have screen tearing
    };
  };
}
```

## Troubleshooting

### Finding Bus IDs

```bash
# List all PCI devices
lspci | grep -E "(VGA|3D)"

# More detailed info
lspci -v | grep -E "(VGA|3D)" -A 10
```

### Check NVIDIA Status

```bash
nvidia-smi
glxinfo | grep "OpenGL renderer"
```

### Test Offload (if using offload mode)

```bash
nvidia-offload glxgears
```

### Common Issues

1. **Black screen**: Check if bus IDs are correct
2. **High power consumption**: Use offload mode instead of sync
3. **Screen tearing**: Enable `forceCompositionPipeline`
4. **Wayland issues**: Ensure `useGBM` is enabled
