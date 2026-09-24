#!/usr/bin/env bash

set -euo pipefail

gh repo list --json nameWithOwner --limit 1000 |
  jq -r '.[].nameWithOwner' |
  xargs -I {} gh repo edit {} --visibility private --accept-visibility-change-consequences