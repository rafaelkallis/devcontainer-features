# Dev Container Features

A collection of Dev Container Features for development environments.

## Features

### Claude Code CLI

Installs the Claude Code CLI tool for interacting with Anthropic's Claude language model.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/claude-code:1": {}
  }
}
```

### Claude Code CLI Mounts

Mounts host Claude configuration directories `~/.claude.json` and `~/.claude/` into the dev container, enabling Claude Code CLI to use your existing authentication and settings.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/rafaelkallis/devcontainer-features/claude-code-mounts:1": {}
  }
}
```

**Prerequisites:**
- Claude Code CLI installed on host with existing configuration in `~/.claude/`
- Claude Code CLI installed in dev container (e.g. via `claude-code` feature)
