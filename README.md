# comfy-env

Shell environment bootstrap scripts: ble.sh, bashrc, nvim, atuin, screen, motd.
One script per target, shared config payloads in `files/`. Clone the repo and run
the script for the box — it copies out of `files/` next to it, so it is not a
single-file curl target any more.

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
| `motd.sh` | `/etc/profile.d/motd.sh` | el, el-k8s, el-zfs (+ zpool-bar line) |
| `dnf-automatic.conf` | `/etc/dnf/automatic.conf` | el, el-zfs, el-k8s (`upgrade_type = security`) |
| `dnf-automatic-timer.conf` | `dnf-automatic.timer.d/override.conf` | el, el-zfs, el-k8s |

`@HOSTNAME@` in `dnf-automatic.conf` is substituted at install time. Edit
`atuin.toml` (`sync_address`) before running.

Targets whose config is unique keep an inline heredoc: `el7` bashrc/motd,
`proxmox` bashrc/motd, `termux` bashrc, `el-zfs` zpool-bar.

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

`screenrc` maps Alt+Enter (ESC CR) to Ctrl+J, so Claude Code inserts a newline instead of submitting inside screen.

## ble.sh completion quoting

`blerc` carries four hooks that make tab completion quote with `'...'` instead
of backslashes (rsync/scp dequote, requote threshold patch, ambiguous common
prefix, menu cycling). Needs ble.sh 0.4; 0.3.x has no requote support at all.
