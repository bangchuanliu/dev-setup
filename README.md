# dev-setup

Shared macOS development tools and dotfiles. This repository deliberately owns
only common configuration; agent projects and their project-specific installers
live elsewhere (for example, `~/agent-files`).

## Fresh-machine setup

Clone this repository, then run its one installer:

```sh
./install.sh
```

The installer is safe to re-run. It installs Homebrew when necessary, installs
the tools listed in [`init.md`](init.md), installs oh-my-zsh, and links the
tracked dotfiles into `$HOME`. After it finishes, restart the shell:

```sh
exec "$SHELL" -l
```

Then authenticate GitHub if needed:

```sh
gh auth login
```

You can now start an agent session with `pi` and run any project-specific setup
from your agent-files repository.

## Tracked configurations

| Repo path | Links to |
|---|---|
| `.gitconfig` | `~/.gitconfig` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.wezterm.lua` | `~/.wezterm.lua` |
| `.zshrc` | `~/.zshrc` |
| `.config/herdr/config.toml` | `~/.config/herdr/config.toml` |

Each destination is a symlink. Edits made in this repository therefore take
effect immediately without re-running the installer. If a destination already
exists but is not this repository's symlink, the installer backs it up as
`<file>.backup.<timestamp>` before linking it.

To track a new dotfile, add it to the repository and append its `$HOME`-relative
path to the `dotfiles` array in `install.sh`.

## Machine-local overrides

**This repository is public.** Internal hostnames, work aliases, credentials,
and other machine-specific settings must stay out of tracked dotfiles. Keep them
in an untracked file such as `~/.zshrc.local` (already gitignored).

Never commit internal infrastructure details to this repository.
