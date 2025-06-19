# Minimal User Profile
# Basic user setup with essential tools only

{ ... }:

{
  # Import common user profile
  imports = [ ./common.nix ];

  # No additional packages beyond common
  # (common profile already provides essential CLI tools)
}
