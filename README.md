# comfy-env

Shell environment bootstrap scripts: ble.sh, bashrc, nvim, atuin, screen, and a
fastfetch login summary — a `/etc/profile.d/motd.sh`, not `/etc/motd` or
`update-motd.d`.

One script per target, shared config payloads in `files/`, optional user tools
in `bin/`. Clone the repo and run the script for the box; it copies out of
`files/` next to it, so there is no longer a single-file curl-to-shell install
of the script itself. The scripts do still fetch from the internet, see below.

## what it fetches

Run as root, these pull from outside the distro repos. Read before executing:

| source | what | where |
|---|---|---|
| `git clone github.com/akinomyoga/ble.sh` | built from source | all |
| `curl https://setup.atuin.sh \| sh` | upstream installer, piped to a shell | all but termux |
| `curl https://alessandromrc.github.io/fastfetch-installer/installer.sh \| bash` | third party, not the fastfetch project | proxmox |
| `bat` 0.7.1, `fastfetch` 1.6.3 release binaries, fzf clone | pinned old versions, no repo package on EL7 | el7 |
| CentOS 7 repos repointed to `vault.epel.cloud` | EL7 is EOL, mirrorlist is dead | el7 |

The ble.sh clone is removed again at the end of each script.

| script | target |
|---|---|
| `el.sh` | Enterprise Linux 8/9, generic |
| `el-zfs.sh` | Enterprise Linux 8+, ZFS host (adds `zpool-bar`) |
| `el-k8s.sh` | Enterprise Linux 8/9, Kubernetes node |
| `el7.sh` | Enterprise Linux 7 (vault repos) |
| `proxmox.sh` | Proxmox VE |
| `termux/comfy_script.sh` | Termux (native, no proot, no atuin) |

EL and Proxmox scripts run as root and install dnf-automatic / packages as needed.

## files/

| file | target | used by |
|---|---|---|
| `bashrc` | `/root/.bashrc` | el, el-zfs, el-k8s |
| `bash_profile` | `/root/.bash_profile` | el, el-zfs, el7, el-k8s (+ krew/kube lines) |
| `blerc` | `~/.blerc` | all |
| `init.vim` | `~/.config/nvim/init.vim` | all |
| `screenrc` | `~/.screenrc` | all |
| `atuin.toml` | `~/.config/atuin/config.toml` | all but termux |
| `motd.sh` | `/etc/profile.d/motd.sh`, fastfetch on login | el, el-k8s, el-zfs (+ zpool-bar line) |
| `dnf-automatic.conf` | `/etc/dnf/automatic.conf` | el, el-zfs, el-k8s (`upgrade_type = security`) |
| `dnf-automatic-timer.conf` | `dnf-automatic.timer.d/override.conf` | el, el-zfs, el-k8s |

`@HOSTNAME@` in `dnf-automatic.conf` is substituted at install time. Edit
`atuin.toml` (`sync_address`) before running -- the committed value is a
placeholder.

Targets whose config is unique keep an inline heredoc: `el7` bashrc/motd,
`proxmox` bashrc/motd, `termux` bashrc, `el-zfs` zpool-bar.

## bin/

Optional command line tools. Nothing installs these; copy the ones you want.

### environment

| variable | used by | meaning |
|---|---|---|
| `FOAM_VAULT` | `newnote`, `notes2tldr` | path to the notes vault. **Required**, no default; both refuse to run without it |
| `CLAUDE_CONFIG_DIR` | `claude-sessions` | Claude Code config dir, default `~/.claude` |
| `TEALDEER_CACHE_DIR`, `TEALDEER_CONFIG_DIR` | `notes2tldr` | honoured indirectly: page directories come from `tldr --show-paths`, so tealdeer's own config and env win |

```sh
export FOAM_VAULT="$HOME/workdir/notes"   # in ~/.bashrc
```

Anything that does not source `~/.bashrc` (cron, systemd, git hooks) needs
`FOAM_VAULT` passed explicitly.

```sh
install -m0755 bin/claude-sessions ~/.local/bin/
```

| script | what | needs |
|---|---|---|
| `claude-sessions` | list every Claude Code session on the machine, newest first, with cwd and opening prompt -- `claude --resume` only offers sessions matching `$PWD` | python3 |
| `imgtool` | pick an image with fd+fzf (chafa preview), then convert / resize / rename / open | fd, fzf, chafa, imagemagick |
| `notes2tldr` | turn `cheat sheet/*.md` notes into tealdeer `.patch.md` pages, appended below the official tldr examples | python3, tealdeer |
| `newnote` | create a Foam vault page with this vault's frontmatter and link it from its category hub (Foam has no post-create hook, so the hub link is manual otherwise) | python3 |

Server side utilities that every box of that type wants (`zpool-bar` on ZFS
hosts) stay in their bootstrap script instead -- they are not optional there.

## history

`bash_profile` / the inline bashrcs use:

```sh
shopt -s histappend
PROMPT_COMMAND='history -a'
```

Do **not** use `bleopt history_share=1`. In ble.sh 0.4.0-devel4
`ble/builtin/history/.initialize` clamps `rskip` (a line count from `wc -l`)
with `max-min+1` (an entry count). With `HISTTIMEFORMAT` set every entry is two
lines, so half of HISTFILE is re-read as new on each shell start and appended
back. A handful of shells over a few days turned 11k real entries into 1M
(34 MB) on the workstation.

## termux

- `comfy_script.sh`: base setup. Locale (`C.UTF-8`) and `$USER` fixes are applied separately afterwards, see notes `android/termux-setup`.
- `ssh_config`: full mesh, `name-type-os` host aliases.
- `termux-boot-wake-lock.sh`: goes in `~/.termux/boot/`, needs Termux:Boot + Termux:API from the same source as Termux.

## screen

`screenrc`:
- Alt+Enter (ESC CR) is sent as backslash+CR, so Claude Code inserts a newline instead of submitting. For Shift+Enter, bind it to ESC CR in the terminal (Alacritty: `{ key = "Return", mods = "Shift", chars = "\u001B\r" }`).
- `truecolor on`: screen drops 24-bit colors otherwise.
- `C-a h` dumps the whole scrollback (10000 lines) as rendered plain text; the raw `screenlog_*.log` files keep escape codes.

## ble.sh completion quoting

`blerc` carries four hooks that make tab completion quote with `'...'` instead
of backslashes (rsync/scp dequote, requote threshold patch, ambiguous common
prefix, menu cycling). Needs ble.sh 0.4; 0.3.x has no requote support at all.
