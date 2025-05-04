# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Build home configuration: `nix build .#homeManagerConfigurations.<username>.activationPackage`
- Build minimal ISO: `nix build .#installMedia.minimal.config.system.build.isoImage`

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