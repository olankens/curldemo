#!/usr/bin/env bash

# shellcheck shell=bash

main() {

	# Enable strictness
	set -euo pipefail

	# Ensure all repos are private
	gh repo list --json nameWithOwner --limit 1000 |
		jq -r '.[].nameWithOwner' |
		xargs -I {} gh repo edit {} --visibility private --accept-visibility-change-consequences

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
