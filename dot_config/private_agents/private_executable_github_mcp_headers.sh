#!/bin/sh
set -eu

ENV_FILE="${HOME}/.config/agents/github_pat.env"

if [ ! -r "$ENV_FILE" ]; then
  printf '%s\n' "github_mcp_headers.sh: missing readable env file: $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$ENV_FILE"

case "${GITHUB_PAT:-}" in
  ""|"github_pat_REPLACE_WITH_YOUR_TOKEN")
    printf '%s\n' "github_mcp_headers.sh: GITHUB_PAT is unset or still the placeholder" >&2
    exit 1
    ;;
esac

printf '{"Authorization":"Bearer %s"}\n' "$GITHUB_PAT"