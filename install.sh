#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

dotfiles=(
	.gitconfig
	.tmux.conf
	.wezterm.lua
	.zshrc
)

for dotfile in "${dotfiles[@]}"; do
	source_path="$script_dir/$dotfile"
	destination_path="$HOME/$dotfile"

	if [[ -L "$destination_path" && "$(readlink -- "$destination_path")" == "$source_path" ]]; then
		echo "Already installed: $destination_path"
		continue
	fi

	if [[ -e "$destination_path" || -L "$destination_path" ]]; then
		backup_path="$destination_path.backup.$(date +%Y%m%d%H%M%S)"
		mv -- "$destination_path" "$backup_path"
		echo "Backed up $destination_path to $backup_path"
	fi

	ln -s -- "$source_path" "$destination_path"
	echo "Installed $destination_path"
done