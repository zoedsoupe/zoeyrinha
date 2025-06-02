# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Quick build script: `./nix-build <target>` where target is:
  - `personal` - Build personal Mac configuration
  - `cloudwalk` - Build CloudWalk Mac configuration
  - `iso` - Build minimal ISO
- Build Darwin (macOS) configuration manually: `darwin-rebuild switch --flake .#<hostname>-mac`
  - Examples: `darwin-rebuild switch --flake .#cloudwalk-mac` or `.#zoedsoupe-mac`
- Build minimal ISO manually: `nix build .#installMedia.minimal.config.system.build.isoImage`

## Repository Architecture

### Flake Structure
The repository uses Nix flakes with modular architecture:
- **lib/**: Core helper functions
  - `host.nix`: Functions for creating Darwin/NixOS systems (`mkDarwin`, `mkHost`, `mkISO`)
  - `user.nix`: User configuration helpers (`mkDarwinUser`, `mkHMUser`, `mkSystemUser`)
  - `theme.nix`: Theming configuration
- **hosts/**: Per-machine configurations
  - Each host has: `configuration.nix`, `custom.nix`, `home.nix`
- **modules/**: Reusable configuration modules
  - `users/`: User-specific program configurations
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