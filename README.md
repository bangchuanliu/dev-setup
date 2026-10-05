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

Then authenticate GitHub using SSH and re-run the installer once:

```sh
gh auth login --git-protocol ssh --scopes admin:public_key
./install.sh
```

The installer generates `~/.ssh/id_ed25519` when it is absent. After GitHub
login, it registers the public key and configures the GitHub CLI to use SSH for
new clones, so GitHub clone, fetch, and push work without an HTTPS credential
prompt. Existing HTTPS remotes can be changed with `git remote set-url`.

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
and other machine-specific settings must stay out of tracked dotfiles.

For zsh settings, use `~/.zshrc.local`. The tracked `.zshrc` loads this file
when it exists, and the repository's `.gitignore` already excludes `*.local`.
For example:

```sh
cat >> ~/.zshrc.local <<'EOF'
# Personal aliases, private paths, and machine-only environment variables.
alias my-project='cd ~/projects/private-project'
export PATH="$HOME/private/bin:$PATH"
EOF
```

Do not put these settings directly in `.zshrc`: it is a tracked shared config.
For a one-off shared/local distinction while preparing a commit, use
`git add -p .zshrc` to stage only the intended common changes.

Never commit internal infrastructure details to this repository.
