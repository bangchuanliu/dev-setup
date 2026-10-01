# dotfiles

dev configs

## Setup

Fresh macOS machine - installs Homebrew, WezTerm, iTerm2, then links the dotfiles:

```sh
./bootstrap.sh
```

Dotfiles only (Homebrew and the terminal apps already installed):

```sh
./install.sh
```

Both are idempotent and safe to re-run. `install.sh` symlinks each tracked dotfile into
`$HOME`, backing up anything already there to `<file>.backup.<timestamp>`.

### Tracked files

| Repo path | Links to |
|---|---|
| `.gitconfig` | `~/.gitconfig` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.wezterm.lua` | `~/.wezterm.lua` |
| `.zshrc` | `~/.zshrc` |
| `.config/herdr/config.toml` | `~/.config/herdr/config.toml` |

To track a new dotfile, add it to the repo and append its `$HOME`-relative path to the
`dotfiles` array in `install.sh`.

### Machine-local overrides

**This repo is public.** Internal hostnames, work aliases, credentials, and anything else
machine-specific must stay out of the tracked dotfiles. Keep them in an untracked file
such as `~/.zshrc.local` (already gitignored) and source it from your local shell config.

Never commit internal infrastructure details to this repo.

## Manual steps

Not covered by the scripts:

- Font: [Meslo Dotted](https://github.com/powerline/fonts/tree/master/Meslo%20Dotted) - use `Meslo LG L DZ Regular`
- Set up an SSH key for GitHub
- Install oh-my-zsh


