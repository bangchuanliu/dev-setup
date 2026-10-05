# Fresh-machine requirements

`install.sh` is the single setup command for this repository. On a fresh macOS
machine, clone this repository and run it:

```sh
./install.sh
```

It applies the shared Homebrew package manifest in [`Brewfile`](Brewfile), then
symlinks the tracked dotfiles into `$HOME`.

## Installed automatically

| Type | Tools |
|---|---|
| Homebrew formulae | fzf, GitHub CLI (`gh`), Pi agent (`pi`), zoxide |
| Homebrew casks | Meslo LG L DZ for Powerline, iTerm2, Eclipse Temurin JDK, Superwhisper, WezTerm |
| Shell | oh-my-zsh |
| GitHub SSH | An `ed25519` key at `~/.ssh/id_ed25519` (generated when absent) |
| Configurations | Git, tmux, WezTerm, zsh, and herdr (see `README.md`) |

The installer is idempotent: `brew bundle` leaves installed packages in place,
and correct symlinks are left in place. Existing non-symlink config files are
backed up before linking. Add or remove shared Homebrew packages in `Brewfile`.

## Manual setup after installation

- Authenticate GitHub using SSH:

  ```sh
  gh auth login --git-protocol ssh --scopes admin:public_key
  ```

  Re-run `./install.sh` after authentication. It registers the generated
  `~/.ssh/id_ed25519.pub` key with GitHub (unless it is already registered) and
  configures the GitHub CLI to create new clones with SSH, enabling fetch and
  push access without an HTTPS credential prompt.

- Restart the shell so the linked zsh configuration and oh-my-zsh load:

  ```sh
  exec "$SHELL" -l
  ```

- Start Pi with `pi`. Agent-specific repositories and their own setup commands
  belong outside this common-config repository (for example, in `~/agent-files`).
