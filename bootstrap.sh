#!/usr/bin/env bash
#
# Bootstrap a fresh macOS machine:
#   1. Homebrew
#   2. WezTerm
#   3. iTerm2
#   4. Dotfiles (delegates to ./install.sh)
#
# Safe to re-run: every step is idempotent.

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

log() { printf '\n==> %s\n' "$1"; }
info() { printf '    %s\n' "$1"; }

if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "This bootstrap script only supports macOS." >&2
	exit 1
fi

brew_prefix() {
	if [[ "$(uname -m)" == "arm64" ]]; then
		echo "/opt/homebrew"
	else
		echo "/usr/local"
	fi
}

install_homebrew() {
	log "Homebrew"

	if ! command -v brew >/dev/null 2>&1; then
		local shellenv="$(brew_prefix)/bin/brew"
		if [[ -x "$shellenv" ]]; then
			info "Found Homebrew at $shellenv but it is not on PATH."
		else
			info "Installing Homebrew..."
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi
		eval "$("$shellenv" shellenv)"
	fi

	info "Using $(brew --version | head -n 1) at $(command -v brew)"
}

install_cask() {
	local cask="$1" app="$2"

	if [[ -d "/Applications/$app" || -d "$HOME/Applications/$app" ]]; then
		info "Already installed: $app"
		return
	fi

	if brew list --cask "$cask" >/dev/null 2>&1; then
		info "Already installed via Homebrew: $cask"
		return
	fi

	info "Installing $cask..."
	brew install --cask "$cask"
}

install_homebrew

log "WezTerm"
install_cask wezterm "WezTerm.app"

log "iTerm2"
install_cask iterm2 "iTerm.app"

log "Dotfiles"
"$script_dir/install.sh"

log "Done"
info "Restart your shell (or run 'exec \$SHELL -l') to pick up the new config."
