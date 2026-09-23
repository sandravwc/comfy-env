# termux-setup

Termux comfy environment + ssh mesh config, used across POCO F5 Pro, Nothing Phone 2, Huawei MatePad.

Details/gotchas: see the `notes` Logseq graph, `android⁄*` pages (mysql/proot/dotnet/etc are separate topics; `android⁄termux-setup` covers this specifically).

- `comfy_script.sh` — base rice (ble.sh, bashrc, atuin, screenrc). Locale (`C.UTF-8`) and `$USER` fixes are NOT in this script, applied separately after — see the logseq page.
- `ssh_config` — full mesh, `name-type-os` host aliases.
- `termux-boot-wake-lock.sh` — drop into `~/.termux/boot/` on each device, needs Termux:Boot + Termux:API apps installed (same build source as Termux itself — Google Play Termux is deprecated upstream, don't mix sources).
