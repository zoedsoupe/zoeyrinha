# Helix Editor Module

This directory contains a refactored, modular configuration for the Helix editor. The architecture has been redesigned for better extensibility, readability, and maintainability.

## Architecture Overview

The module is split into several focused files:

```
modules/users/helix/
├── README.md           # This documentation
├── default.nix         # Main entry point and options interface
├── editor.nix          # Editor settings and UI configuration
├── languages.nix       # Language configuration definitions
├── lsp-servers.nix     # LSP server configurations
├── types.nix           # Type definitions for language configs
└── lib.nix             # Helper functions and utilities
```

## Key Benefits

- **Modular**: Each concern is separated into its own file
- **Extensible**: Easy to add new languages without touching existing code
- **Type-safe**: Uses Nix module system with proper type definitions
- **Data-driven**: Language configurations are defined as data structures
- **Composable**: Helper functions enable code reuse and consistency

## Usage

### Basic Configuration

In your `hosts/<hostname>/custom.nix`:

```nix
{
  helix = {
    enable = true;
    
    # Configure which languages to enable
    languages = {
      elixir.enable = true;
      elixir.wakatime.enable = true;
      
      typescript.enable = true;
      nix.enable = true;
      rust.enable = true;
      python.enable = true;
    };
    
    # Editor settings
    editor = {
      disable-line-numbers = false;
    };
  };
}
```

## Adding New Languages

### Method 1: Add to languages.nix (Recommended for common languages)

1. **Define the language in `languages.nix`:**

```nix
# In languages.nix
haskell = {
  helix-names = ["haskell"];
  language-servers = ["haskell-language-server"];
  formatter = {
    command = "${pkgs.haskell-language-server}/bin/fourmolu";
    args = ["--stdin-input-file" "%{buffer_name}"];
  };
  auto-format = true;
  extra-servers = {
    haskell = ["uwu-colors"];
  };
};
```

2. **Add the LSP server configuration in `lsp-servers.nix`:**

```nix
# In lsp-servers.nix
haskell-language-server = mkIf (get-lang-config "haskell").enable {
  command = "${pkgs.haskell-language-server}/bin/haskell-language-server";
  args = ["--lsp"];
};
```

3. **Enable it in your config:**

```nix
# In your custom.nix
helix.languages.haskell.enable = true;
```

### Method 2: Runtime Language Configuration

For custom or project-specific languages, you can override configurations:

```nix
# In your custom.nix
helix = {
  enable = true;
  languages = {
    # Enable base language
    typescript.enable = true;
    
    # Custom configuration for a specific project
    my-custom-lang = {
      enable = true;
      helix-names = ["my-lang"];
      language-servers = ["my-custom-lsp"];
      formatter = {
        command = "my-formatter";
        args = ["--stdin"];
      };
    };
  };
};
```

## Language Configuration Options

Each language supports these configuration options:

```nix
languages.<name> = {
  # Whether to enable this language
  enable = mkEnableOption "language support";
  
  # WakaTime integration
  wakatime = {
    enable = mkEnableOption "WakaTime tracking";
  };
  
  # LSP configuration
  lsp = {
    enable = mkEnableOption "LSP support";
    name = mkOption {
      type = types.str;
      description = "Primary LSP server name";
    };
    except-features = mkOption {
      type = types.listOf types.str;
      description = "LSP features to disable";
    };
  };
};
```

## Changing LSP Servers

### Method 1: Override Language Configuration

```nix
# In your custom.nix - switch Elixir from lexical to next-ls
helix.languages.elixir = {
  enable = true;
  lsp.name = "next-ls";  # Override default LSP
};
```

### Method 2: Add Multiple Servers

```nix
# In languages.nix - modify existing language
elixir = {
  helix-names = ["elixir" "heex" "eex"];
  language-servers = ["lexical" "next-ls"];  # Multiple servers
  # ... rest of config
};
```

### Method 3: Server-specific Configuration

```nix
# In lsp-servers.nix - configure server with specific options
next-ls = mkIf (get-lang-config "elixir").enable {
  command = "${pkgs.next-ls}/bin/next-ls";
  args = ["--stdio"];
  config = {
    experimental = {
      completions = {
        enable = true;
      };
    };
  };
};
```

## Adding New LSP Servers

1. **Add server definition in `lsp-servers.nix`:**

```nix
my-new-server = mkIf (get-lang-config "my-language").enable {
  command = "${pkgs.my-server}/bin/my-server";
  args = ["--stdio"];
  config = {
    # Server-specific configuration
    settings = {
      diagnostics = true;
    };
  };
};
```

2. **Reference it in language configuration:**

```nix
# In languages.nix
my-language = {
  helix-names = ["mylang"];
  language-servers = ["my-new-server"];
};
```

## Advanced Patterns

### Conditional LSP Servers

```nix
# Different servers based on conditions
elixir = {
  helix-names = ["elixir" "heex" "eex"];
  language-servers = 
    if cfg.elixir.lsp.name == "lexical" 
    then ["lexical"]
    else ["next-ls"];
};
```

### Per-File-Type Server Configuration

```nix
elixir = {
  helix-names = ["elixir" "heex" "eex"];
  language-servers = ["next-ls"];
  extra-servers = {
    heex = ["emmet-ls" "tailwindcss-intellisense"];
    eex = ["emmet-ls"];
    # elixir gets just the base servers
  };
};
```

### Custom Formatters

```nix
my-language = {
  helix-names = ["mylang"];
  language-servers = ["mylang-lsp"];
  formatter = {
    command = "${pkgs.my-formatter}/bin/format";
    args = [
      "--stdin-filename" "%{buffer_name}"
      "--config" "%{workspace_root}/.formatter.toml"
    ];
  };
  auto-format = true;
};
```

## Helper Functions

The `lib.nix` provides several utilities:

### `with-wakatime`
Automatically adds WakaTime server if enabled for a language:

```nix
servers = with-wakatime "elixir" ["lexical" "other-server"];
# Results in: ["lexical" "other-server" "wakatime-ls"] if wakatime is enabled
```

### `mk-helix-lang`
Creates a Helix language configuration from our data structure:

```nix
helix-config = mk-helix-lang language-defaults.elixir "elixir";
```

### `build-language-configs`
Processes all language definitions and creates Helix configurations:

```nix
all-configs = build-language-configs language-defaults overrides;
```

## Editor Settings

Editor-specific settings are in `editor.nix`. To modify:

```nix
# In your custom.nix
helix.editor.disable-line-numbers = true;
```

Available editor options:
- `disable-line-numbers`: Hide line numbers in gutter (default: true)
