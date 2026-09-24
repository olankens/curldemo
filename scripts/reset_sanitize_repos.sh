#!/usr/bin/env bash

# shellcheck disable=SC2155
# shellcheck shell=bash

main() {

	# Enable strictness
	set -euo pipefail

	# Handle parameters
	[[ "$#" -gt 0 ]] || return 1

	# Remake repositories
	local temp_dir=$(mktemp -d)
	trap 'rm -rf -- "${temp_dir:-}"' EXIT
	for repo in "$@"; do
		local clone_dir="$temp_dir/${repo##*/}"
		gh repo clone "$repo" "$clone_dir"
		(
			cd "$clone_dir"
			curl -fsSL https://raw.githubusercontent.com/olankens/repowipe/HEAD/scripts/repowipe.sh | bash
			git push -u origin main
			curl -fsSL https://raw.githubusercontent.com/olankens/sanityme/HEAD/scripts/sanityme.sh | bash
			curl -fsSL https://raw.githubusercontent.com/olankens/repowipe/HEAD/scripts/repowipe.sh | bash
			git push -u origin main
			curl -fsSL https://raw.githubusercontent.com/olankens/sanityme/HEAD/scripts/sanityme.sh | bash
		)
	done

}

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
