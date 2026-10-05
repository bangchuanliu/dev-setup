#!/usr/bin/env bash
# Set up a macOS development machine and link this repository's dotfiles.
# Safe to re-run.

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

dotfiles=(
	.gitconfig
	.tmux.conf
	.wezterm.lua
	.zshrc
	.config/herdr/config.toml
)

log() { printf '\n==> %s\n' "$1"; }
info() { printf '    %s\n' "$1"; }

# ask (default), override, or skip when a Brewfile entry is already installed.
conflict_policy="${DEV_SETUP_ON_CONFLICT:-ask}"

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

install_oh_my_zsh() {
	if [[ -d "$HOME/.oh-my-zsh" ]]; then
		info "Already installed: oh-my-zsh"
	else
		info "Installing oh-my-zsh..."
		git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
	fi
}

brewfile_entries() {
	# Print the names declared for one Brewfile directive (brew, cask, or tap).
	sed -n -E "s/^[[:space:]]*$1[[:space:]]+[\"']([^\"']+)[\"'].*/\1/p" "$script_dir/Brewfile"
}

read_brewfile_entries() {
	# Collect entries up front so prompts later keep the caller's stdin.
	local directive="$1" line
	brewfile_names=()

	while IFS= read -r line; do
		[[ -n "$line" ]] && brewfile_names+=("$line")
	done < <(brewfile_entries "$directive")
}

cask_existing_app() {
	# Print the path of an already present app bundle that this cask would own,
	# which catches apps installed outside of Homebrew.
	local app_name app_path
	while IFS= read -r app_name; do
		app_path="/Applications/$app_name"
		if [[ -e "$app_path" ]]; then
			echo "$app_path"
			return 0
		fi
	done < <(brew info --cask "$1" 2>/dev/null | sed -n -E 's/^(.+\.app) \(App\)$/\1/p')

	return 1
}

# Answer whether an already installed entry should be overridden.
should_override() {
	local label="$1" answer

	case "$conflict_policy" in
	override) return 0 ;;
	skip) return 1 ;;
	esac

	if [[ ! -t 0 ]]; then
		info "Not an interactive shell; keeping existing $label"
		return 1
	fi

	while true; do
		printf '    %s is already installed. Override? [y]es / [n]o / [a]ll / [s]kip all: ' "$label"
		read -r answer || answer=n
		case "$answer" in
		y | Y) return 0 ;;
		n | N | "") return 1 ;;
		a | A)
			conflict_policy=override
			return 0
			;;
		s | S)
			conflict_policy=skip
			return 1
			;;
		esac
	done
}

install_brewfile() {
	log "Homebrew packages"

	local name existing_app

	read_brewfile_entries tap
	for name in ${brewfile_names+"${brewfile_names[@]}"}; do
		info "Tapping $name..."
		brew tap "$name"
	done

	read_brewfile_entries brew
	for name in ${brewfile_names+"${brewfile_names[@]}"}; do
		if brew list --formula --versions "$name" >/dev/null 2>&1; then
			if should_override "Formula $name"; then
				info "Reinstalling formula: $name"
				brew reinstall --formula "$name"
			else
				info "Skipped formula: $name"
			fi
		else
			info "Installing formula: $name"
			brew install --formula "$name"
		fi
	done

	read_brewfile_entries cask
	for name in ${brewfile_names+"${brewfile_names[@]}"}; do
		if brew list --cask --versions "$name" >/dev/null 2>&1; then
			if should_override "Cask $name"; then
				info "Reinstalling cask: $name"
				brew reinstall --cask "$name"
			else
				info "Skipped cask: $name"
			fi
		elif existing_app=$(cask_existing_app "$name"); then
			if should_override "Cask $name ($existing_app, not managed by Homebrew)"; then
				info "Replacing $existing_app with cask: $name"
				brew install --cask --force "$name"
			else
				info "Skipped cask: $name"
			fi
		else
			info "Installing cask: $name"
			brew install --cask "$name"
		fi
	done < <(brewfile_entries cask)
}

setup_github_ssh() {
	local key_path="$HOME/.ssh/id_ed25519"
	local public_key_path="$key_path.pub"

	log "GitHub SSH"
	mkdir -p -m 700 "$HOME/.ssh"

	if [[ ! -f "$key_path" ]]; then
		local email
		email=$(git config --global --get user.email 2>/dev/null || true)
		info "Generating GitHub SSH key: $key_path"
		ssh-keygen -t ed25519 -C "${email:-$USER@$(hostname -s)}" -f "$key_path" -N ""
	else
		info "Already present: $key_path"
	fi

	if [[ ! -f "$public_key_path" ]]; then
		info "Deriving missing public key: $public_key_path"
		ssh-keygen -y -f "$key_path" >"$public_key_path"
	fi

	if gh auth status --hostname github.com >/dev/null 2>&1; then
		local public_key
		public_key=$(awk '{print $1 " " $2}' "$public_key_path")
		if gh api --paginate user/keys --jq '.[].key' | awk '{print $1 " " $2}' | grep -Fqx "$public_key"; then
			info "SSH key is already registered with GitHub"
		else
			info "Adding SSH key to GitHub..."
			gh ssh-key add "$public_key_path" --title "$(hostname -s)-$(date +%Y%m%d)"
		fi
		gh config set git_protocol ssh --host github.com
	else
		info "Run 'gh auth login --git-protocol ssh --scopes admin:public_key' and re-run this installer to register the SSH key."
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

install_brewfile

log "Shell"
install_oh_my_zsh

link_dotfiles
setup_github_ssh

log "Done"
info "Restart your shell (or run 'exec \$SHELL -l')."
