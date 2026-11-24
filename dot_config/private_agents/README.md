# GitHub MCP authentication for Codex and Claude Code

This directory manages the GitHub MCP header helper for Claude Code.

The PAT itself lives with the other local secrets (see
`dot_config/private_secrets/README.md`):

```txt
~/.config/secrets/github_pat.env
```

It contains the GitHub PAT used by Codex and Claude Code for GitHub MCP access.

The PAT itself is not committed. Chezmoi creates a placeholder file if missing,
then leaves the file alone after you edit it locally.

## Chezmoi source layout

In the chezmoi source repo:

```txt
dot_config/private_agents
├── private_executable_github_mcp_headers.sh
└── README.md

dot_config/private_secrets
├── create_private_github_pat.env.tmpl
├── create_private_mistral_api_key.env.tmpl
├── .gitignore
└── README.md
```

This creates:

```txt
~/.config/agents
├── github_mcp_headers.sh
└── README.md

~/.config/secrets
├── github_pat.env
├── mistral_api_key.env
└── README.md
```

## Why this layout?

The `private_` prefix on both source directories tells chezmoi to remove
group/world permissions from `~/.config/agents` and `~/.config/secrets`.

The token file source is `dot_config/private_secrets/create_private_github_pat.env.tmpl`:

- `create_`: create the target file if missing, but do not overwrite it later
- `private_`: make the target file private
- `.tmpl`: render it as a chezmoi template and strip the `.tmpl` suffix

So the target becomes:

```txt
~/.config/secrets/github_pat.env
```

## First-time setup with chezmoi

Run:

```sh
chezmoi apply
```

Then edit the target file:

```sh
$EDITOR "$HOME/.config/secrets/github_pat.env"
```

Replace:

```sh
export GITHUB_PAT='github_pat_REPLACE_WITH_YOUR_TOKEN'
```

with your real token:

```sh
export GITHUB_PAT='github_pat_your_real_token_here'
```

Do not include `Bearer`.

Check permissions:

```sh
ls -ld "$HOME/.config/agents" "$HOME/.config/secrets"
ls -l "$HOME/.config/secrets/github_pat.env"
ls -l "$HOME/.config/agents/github_mcp_headers.sh"
```

Expected shape:

```txt
drwx------ ... ~/.config/agents
drwx------ ... ~/.config/secrets
-rw------- ... ~/.config/secrets/github_pat.env
-rwx------ ... ~/.config/agents/github_mcp_headers.sh
```

## Creating the GitHub PAT

Prefer a fine-grained PAT where possible.

Create it in GitHub:

1. GitHub settings.
2. Developer settings.
3. Personal access tokens.
4. Fine-grained tokens.
5. Generate new token.
6. Choose an expiration.
7. Choose the resource owner.
8. Prefer selected repositories instead of all repositories.
9. Add only the permissions you need.

Suggested starting point for common MCP work:

- Metadata: read
- Contents: read, or read/write if agents should edit files
- Issues: read/write if agents should create or comment on issues
- Pull requests: read/write if agents should inspect or comment on PRs
- Actions: only if agents need workflow run access
- Workflows: only if agents need workflow modification or dispatch access
- Organization metadata: only if needed

If a fine-grained PAT does not work for a needed GitHub MCP operation, use a
classic PAT with the smallest scopes possible.

Common classic PAT scopes for GitHub MCP:

- `repo`
- `workflow`, only if needed
- `read:org`, only if needed
- `project`, only if needed
- `gist`, only if needed

Expand permissions only after a tool fails with a permissions error.

## Codex setup

Codex reads MCP configuration from:

```txt
~/.codex/config.toml
```

Add:

```toml
[mcp_servers.github]
url = "https://api.githubcopilot.com/mcp/"
bearer_token_env_var = "GITHUB_PAT"
```

This stores only the environment variable name, not the token.

`GITHUB_PAT` is not exported globally. `.bashrc` and `.zshrc` define a `codex`
wrapper that loads `~/.config/secrets/github_pat.env` in a subshell, so only
Codex sees the token:

```sh
codex() {
  (
    [ -r "$HOME/.config/secrets/github_pat.env" ] && . "$HOME/.config/secrets/github_pat.env"
    command codex "$@"
  )
}
```

Inside Codex, verify with:

```txt
/mcp
```

## Claude Code setup

Claude Code can use the GitHub MCP remote server with a dynamic header helper.

Because `~/.config/agents/github_mcp_headers.sh` reads the PAT from
`github_pat.env`, the PAT itself is not written into Claude's config.

Run:

```sh
claude mcp remove github 2>/dev/null || true

claude mcp add-json github \
  '{"type":"http","url":"https://api.githubcopilot.com/mcp/","headersHelper":"'"$HOME"'/.config/agents/github_mcp_headers.sh"}' \
  --scope user
```

Verify:

```sh
claude mcp list
claude mcp get github
```

Inside Claude Code, verify with:

```txt
/mcp
```

## Fallback: setup without chezmoi

Create the directory and env file manually:

```sh
mkdir -p "$HOME/.config/agents" "$HOME/.config/secrets"
chmod 700 "$HOME/.config/agents" "$HOME/.config/secrets"

cat > "$HOME/.config/secrets/github_pat.env" <<'EOF'
# ~/.config/secrets/github_pat.env
# Raw token only. Do not include "Bearer ".
export GITHUB_PAT='github_pat_REPLACE_WITH_YOUR_TOKEN'
EOF

chmod 600 "$HOME/.config/secrets/github_pat.env"
$EDITOR "$HOME/.config/secrets/github_pat.env"
```

Create the Claude Code headers helper manually:

```sh
cat > "$HOME/.config/agents/github_mcp_headers.sh" <<'EOF'
#!/bin/sh
set -eu

ENV_FILE="${HOME}/.config/secrets/github_pat.env"

if [ ! -r "$ENV_FILE" ]; then
  printf '%s\n' "github_mcp_headers.sh: missing readable env file: $ENV_FILE" >&2
  exit 1
fi

. "$ENV_FILE"

case "${GITHUB_PAT:-}" in
  ""|"github_pat_REPLACE_WITH_YOUR_TOKEN")
    printf '%s\n' "github_mcp_headers.sh: GITHUB_PAT is unset or still the placeholder" >&2
    exit 1
    ;;
esac

printf '{"Authorization":"Bearer %s"}\n' "$GITHUB_PAT"
EOF

chmod 700 "$HOME/.config/agents/github_mcp_headers.sh"
```

Then use the same Codex and Claude Code setup sections above.

## Rotating the token

Edit the local target file directly:

```sh
$EDITOR "$HOME/.config/secrets/github_pat.env"
```

Then restart Codex or Claude Code.

Because the file is managed with chezmoi's `create_` attribute, future
`chezmoi apply` runs will not overwrite the edited token file.

To recreate the placeholder from scratch:

```sh
rm "$HOME/.config/secrets/github_pat.env"
chezmoi apply
$EDITOR "$HOME/.config/secrets/github_pat.env"
```

## Safety checklist

- Never commit `github_pat.env`.
- Never paste the PAT into `~/.codex/config.toml`.
- Never paste the PAT into Claude's MCP JSON config.
- Keep `~/.config/agents` and `~/.config/secrets` private.
- Keep `~/.config/secrets/github_pat.env` private.
- Prefer fine-grained PATs with selected repositories.
- Use the shortest practical expiration.
- Rotate immediately if the token is printed, committed, or pasted into logs.

Before committing:

```sh
chezmoi cd
git status --short
git status --ignored --short dot_config/private_agents dot_config/private_secrets
```

The committed files should be the templates, helper script, READMEs, and
`.gitignore`; never a real `*.env` file.
