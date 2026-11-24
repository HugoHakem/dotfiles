# Local secrets

Target directory: `~/.config/secrets` (mode `700`).

Each secret is one `<name>.env` file that `export`s one variable:

| File                  | Variable          | Used by                          |
| --------------------- | ----------------- | -------------------------------- |
| `github_pat.env`      | `GITHUB_PAT`      | Codex + Claude Code GitHub MCP   |
| `mistral_api_key.env` | `MISTRAL_API_KEY` | PDF-to-Markdown OCR tool (dev)   |

## Load on demand, never globally

Secrets are **not** exported in every shell. Each one is loaded only by the
process that needs it, so other programs (including AI agents) never see it:

- `GITHUB_PAT`: Claude Code's helper (`~/.config/agents/github_mcp_headers.sh`)
  reads the file itself; Codex gets it through the `codex` wrapper in
  `.bashrc`/`.zshrc`. See `dot_config/private_agents/README.md`.
- `MISTRAL_API_KEY`: loaded by the project's own environment or run command,
  for example:

  ```sh
  (. ~/.config/secrets/mistral_api_key.env && python -m my_tool input.pdf)
  ```

  Files use `export VAR='value'` lines, which both `sh` and python-dotenv can read.

## How it works

The source files are `create_private_<name>.env.tmpl`:

- `create_`: chezmoi writes a placeholder only if the file is missing, and
  never overwrites it afterwards
- `private_`: target file is mode `600`
- `.tmpl`: suffix is stripped

After `chezmoi apply`, edit the target file and replace the placeholder:

```sh
$EDITOR "$HOME/.config/secrets/<name>.env"
```

To reset to the placeholder: delete the target file and run `chezmoi apply`.

## Adding a secret

1. Copy an existing template to `create_private_<name>.env.tmpl` and change the
   header comment, variable name, and placeholder.
2. Add a row to the table above.
3. Load it only where it is used (wrapper, helper, or project activation);
   don't source it from `.bashrc`/`.zshrc`.
4. `chezmoi apply`, then fill in the real value in `~/.config/secrets/<name>.env`.

## Safety

- Never commit a real `*.env` file (`.gitignore` blocks them in this directory).
- Before committing: `git status --ignored --short dot_config/private_secrets`.
- Rotate immediately if a value is printed, committed, or pasted into logs.
