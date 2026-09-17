#!/usr/bin/env bash
# comfy bash env for Termux (native, no proot)

pkg install -y \
  neovim \
  bash-completion \
  bat \
  fzf \
  git \
  make \
  gawk \
  fastfetch \
  screen

mkdir -p "$HOME/workdir"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/atuin"

git clone https://github.com/akinomyoga/ble.sh.git "$HOME/workdir/ble.sh"
cd "$HOME/workdir/ble.sh" && make install INSDIR="$HOME/.local/lib/blesh"

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

cat <<- 'BASHRC' > "$HOME/.bashrc"
# exports paths and other variables first
source "$HOME/.atuin/bin/env"
export ATUIN_NOBIND="true"
export PATH="$PATH:$HOME/bin"
export HISTTIMEFORMAT="%F %T "
export HISTSIZE="100000"
export LS_OPTIONS='--color=auto'

if [[ $- == *i* ]] # execute if in interactive shell
then
  PS1='\[\033[1;37m\][`date +%H:%M:%S`]\[\033[1;36m\][\[\033[1;31m\]\u\[\033[1;33m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;36m\]]\[\033[1;31m\]\\$\[\033[0m\] '
  shopt -s extglob
  source -- "$HOME/.local/lib/blesh/ble.sh" --attach=none
  eval "$(atuin init bash)"
  bind -x '"\C-q": __atuin_history'
  if [[ -f "$PREFIX/share/bash-completion/bash_completion" ]]; then
    source "$PREFIX/share/bash-completion/bash_completion"
  fi
  if [[ -f "$PREFIX/share/fzf/key-bindings.bash" ]]; then
    source "$PREFIX/share/fzf/key-bindings.bash"
  fi
  alias cat='bat --style=plain --paging=never'
fi

umask 022
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias ..='cd ..'
alias ...='cd ../..'
alias vi='nvim'

if [[ $- == *i* ]] # execute if in interactive shell
then
  [[ ! ${BLE_VERSION-} ]] || ble-attach
  fastfetch
fi
BASHRC

cat <<- 'BLESHRC' > "$HOME/.blerc"
ble-bind -f 'M-B' 'backward-cword'
ble-bind -f 'M-F' 'forward-cword'
bleopt complete_auto_complete=
bleopt complete_auto_history=
bleopt complete_ambiguous=
bleopt prompt_eol_mark=''
bleopt complete_menu_filter=
ble-import -d integration/fzf-completion
ble-import -d integration/fzf-key-bindings
BLESHRC

cat <<- 'INITVIM' > "$HOME/.config/nvim/init.vim"
set number
set expandtab ts=2 sw=2 ai
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list
set mouse=
INITVIM

cat <<- 'ATUIN' > "$HOME/.config/atuin/config.toml"
style = "full"
enter_accept = true
records = true
auto_sync = true
sync_frequency = 0
sync_address = "http://<atuin-server>:8888"
ATUIN

cat <<- 'SCREENRC' > "$HOME/.screenrc"
termcapinfo xterm* ti@:te@
logfile "screenlog_%S.log"
deflog on
SCREENRC

rm -rf "$HOME/workdir/ble.sh"
