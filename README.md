# comfy-env

Shell environment bootstrap scripts: ble.sh, bashrc, nvim, atuin, screen, motd. One self-contained script per target, config files written from heredocs. Edit the heredocs (e.g. atuin `sync_address`) before running.

| script | target |
|---|---|
| `el.sh` | Enterprise Linux 8/9, generic |
| `el-zfs.sh` | Enterprise Linux 8+, ZFS host (adds `zpool-bar`) |
| `el-k8s.sh` | Enterprise Linux 8/9, Kubernetes node |
| `el7.sh` | Enterprise Linux 7 (vault repos) |
| `proxmox.sh` | Proxmox VE |
| `termux/comfy_script.sh` | Termux (native, no proot, no atuin) |

EL and Proxmox scripts run as root and install dnf-automatic / packages as needed.

## termux

- `comfy_script.sh`: base setup. Locale (`C.UTF-8`) and `$USER` fixes are applied separately afterwards, see notes `android/termux-setup`.
- `ssh_config`: full mesh, `name-type-os` host aliases.
- `termux-boot-wake-lock.sh`: goes in `~/.termux/boot/`, needs Termux:Boot + Termux:API from the same source as Termux.

## screen

`.screenrc` maps Alt+Enter (ESC CR) to Ctrl+J, so Claude Code inserts a newline instead of submitting inside screen.
