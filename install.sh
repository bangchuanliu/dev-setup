#!/usr/bin/env bash
# Set up a macOS development machine and link this repository's dotfiles.
# Safe to re-run.

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

formulae=(
	gh
	pi
)

casks=(
	font-meslo-lg-nerd-font
	iterm2
	superwhisper
	wezterm
)

dotfiles=(
	.gitconfig
	.tmux.conf
	.wezterm.lua
	.zshrc
	.config/herdr/config.toml
)

log() { printf '\n==> %s\n' "$1"; }
info() { printf '    %s\n' "$1"; }

if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "This installer only supports macOS." >&2
	exit 1
fi

brew_prefix() {
	if [[ "$(uname -m)" == "arm64" ]]; then
		echo "/opt/homebrew"
	else
		echo "/usr/local"
	fi
}

ensure_homebrew() {
	log "Homebrew"

	if ! command -v brew >/dev/null 2>&1; then
		local brew_bin="$(brew_prefix)/bin/brew"
		if [[ ! -x "$brew_bin" ]]; then
			info "Installing Homebrew..."
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi
		eval "$("$brew_bin" shellenv)"
	fi

	info "Using $(brew --version | head -n 1) at $(command -v brew)"
}

install_formula() {
	local formula="$1"
	if brew list --formula "$formula" >/dev/null 2>&1; then
		info "Already installed: $formula"
	else
		info "Installing $formula..."
		brew install "$formula"
	fi
}

install_cask() {
	local cask="$1"
	if brew list --cask "$cask" >/dev/null 2>&1; then
		info "Already installed: $cask"
	else
		info "Installing $cask..."
		brew install --cask "$cask"
	fi
}

install_oh_my_zsh() {
	if [[ -d "$HOME/.oh-my-zsh" ]]; then
		info "Already installed: oh-my-zsh"
	else
		info "Installing oh-my-zsh..."
		git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
	fi
}

link_dotfiles() {
	log "Dotfiles"

	for dotfile in "${dotfiles[@]}"; do
		local source_path="$script_dir/$dotfile"
		local destination_path="$HOME/$dotfile"

		# Accept absolute or relative links that resolve to this repository file.
		# A symlink means later repository changes take effect immediately.
		if [[ -L "$destination_path" && "$destination_path" -ef "$source_path" ]]; then
			info "Already linked: $destination_path"
			continue
		fi

		if [[ -e "$destination_path" || -L "$destination_path" ]]; then
			local backup_path="$destination_path.backup.$(date +%Y%m%d%H%M%S)"
			mv -- "$destination_path" "$backup_path"
			info "Backed up $destination_path to $backup_path"
		fi

		mkdir -p -- "$(dirname -- "$destination_path")"
		ln -s -- "$source_path" "$destination_path"
		info "Linked $destination_path"
	done
}

ensure_homebrew

log "Command-line tools"
for formula in "${formulae[@]}"; do
	install_formula "$formula"
done

log "Applications and font"
for cask in "${casks[@]}"; do
	install_cask "$cask"
done

log "Shell"
install_oh_my_zsh

link_dotfiles

log "Done"
info "Restart your shell (or run 'exec \$SHELL -l')."
info "Authenticate GitHub manually with: gh auth login"
