#!/usr/bin/env bash
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
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

git clone https://github.com/akinomyoga/ble.sh.git "$HOME/workdir/ble.sh"
cd "$HOME/workdir/ble.sh" && make install INSDIR="$HOME/.local/lib/blesh"

cat <<- 'BASHRC' > "$HOME/.bashrc"
# exports paths and other variables first
export PATH="$PATH:$HOME/bin"
export HISTTIMEFORMAT="%F %T "
export HISTSIZE="100000"
export HISTFILESIZE="$HISTSIZE"
shopt -s histappend
PROMPT_COMMAND='history -a'
export LS_OPTIONS='--color=auto'

if [[ $- == *i* ]] # execute if in interactive shell
then
  PS1='\[\033[1;37m\][`date +%H:%M:%S`]\[\033[1;36m\][\[\033[1;31m\]\u\[\033[1;33m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;36m\]]\[\033[1;31m\]\\$\[\033[0m\] '
  shopt -s extglob
  source -- "$HOME/.local/lib/blesh/ble.sh" --attach=none
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

install -Dm0644 "$DIR/files/blerc" "$HOME/.blerc"

install -Dm0644 "$DIR/files/init.vim" "$HOME/.config/nvim/init.vim"

install -Dm0644 "$DIR/files/screenrc" "$HOME/.screenrc"

rm -rf "$HOME/workdir/ble.sh"
