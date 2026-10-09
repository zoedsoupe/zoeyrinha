# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

- Quick build script: `./nix-build <target>` where target is:
  - `personal` - Build personal Mac configuration
  - `iso` - Build minimal ISO
  - `yby-iso` - Build yby installer ISO (embeds the flake + ZFS tooling)
- Build Darwin (macOS) configuration manually: `darwin-rebuild switch --flake .#<hostname>-mac`
  - Examples: `darwin-rebuild switch --flake .#zoedsoupe-mac`
- Build minimal ISO manually: `nix build .#nixosConfigurations.minimal-iso.config.system.build.isoImage`
- Build yby installer ISO manually: `nix build .#nixosConfigurations.yby-iso.config.system.build.isoImage`

## Repository Architecture

### Flake Structure

The repository uses Nix flakes with modular architecture:

- **lib/**: Core helper functions
  - `default.nix`: Single lib file. Exports `make-pkgs`, `mkDarwin` (macOS), `mkHost` (NixOS, with `desktop` toggle), `mkISO` (optional `host` for a per-host installer)
- **hosts/**: Per-machine configurations
  - Each host has: `configuration.nix`, `custom.nix`, `home.nix` (NixOS hosts also `hardware-configuration.nix`)
  - `personal-mac` (darwin), `yby` (NixOS homelab: Niri+Noctalia desktop, ZFS, anytype/nextcloud), `eveo` (NixOS VPS: headscale+maddy)
- **modules/**: Reusable configuration modules
  - `users/`: User-specific program configurations (home-manager)
  - `nixos/`: NixOS system modules (`common.nix`, `desktop.nix`, `noctalia.nix`, `services/`)
  - `iso/`: ISO build modules

### Key Architectural Patterns

1. **Darwin System Creation**: Uses `mkDarwin` helper which:
   - Accepts host and user parameters
   - Integrates home-manager, lix-module, and custom overlays
   - Auto-links macOS applications via mkalias
2. **Module System**: All user programs (terminal emulators, editors, etc.) are toggle-able via `enable` options
3. **Font Management**: Centralized font configuration in terminal modules with variant support

## Code Style Guidelines

1. **Nix Format**: Use 2-space indentation for all .nix files
2. **Git Commits**: Follow the template in modules/users/misc/gitmessage
   - 50 character subject line
   - 72 character wrapped description explaining why/how/side effects
   - Add co-authors when appropriate
3. **Imports**: Group and order imports logically, prefer explicit imports
4. **Naming**:
   - Use camelCase for variables/functions (e.g., `mkDarwinUser`)
   - Use descriptive configuration option names
5. **Structure**:
   - Use mkOption with proper types and descriptions
   - Organize modules consistently with options/config sections
   - Follow NixOS module structure conventions
6. **Error Handling**: Use tryEval for potentially failing operations

Always maintain backward compatibility when modifying existing configurations.
