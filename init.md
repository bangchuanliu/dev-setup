# Fresh-machine requirements

`install.sh` is the single setup command for this repository. On a fresh macOS
machine, clone this repository and run it:

```sh
./install.sh
```

It installs the following shared development tools, then symlinks the tracked
dotfiles into `$HOME`.

## Installed automatically

| Type | Tools |
|---|---|
| Homebrew formulae | GitHub CLI (`gh`), Pi agent (`pi`) |
| Homebrew casks | Meslo LG Nerd Font, iTerm2, Eclipse Temurin JDK, Superwhisper, WezTerm |
| Shell | oh-my-zsh |
| Configurations | Git, tmux, WezTerm, zsh, and herdr (see `README.md`) |

The installer is idempotent: already installed packages and correct symlinks are
left in place. Existing non-symlink config files are backed up before linking.

## Manual setup after installation

- Authenticate GitHub and create/use an SSH key as appropriate for the machine:

  ```sh
  gh auth login
  ```

- Restart the shell so the linked zsh configuration and oh-my-zsh load:

  ```sh
  exec "$SHELL" -l
  ```

- Start Pi with `pi`. Agent-specific repositories and their own setup commands
  belong outside this common-config repository (for example, in `~/agent-files`).
