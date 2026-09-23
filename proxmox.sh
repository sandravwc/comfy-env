#!/usr/bin/env bash
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
apt-get install neovim bash-completion bat git make gawk fzf -y
curl -sSL https://alessandromrc.github.io/fastfetch-installer/installer.sh | bash
mkdir -p /root/workdir
git clone https://github.com/akinomyoga/ble.sh.git /root/workdir/ble.sh
cd /root/workdir/ble.sh && make install INSDIR=/usr/local/lib/blesh

install -Dm0644 "$DIR/files/blerc" /root/.blerc

cat <<- 'MOTDSH' > /etc/profile.d/motd.sh
#!/usr/bin/env bash
fastfetch
MOTDSH

cat <<- 'BASHRC' > /root/.bashrc
# export paths and other variables first
source "$HOME/.atuin/bin/env"
export ATUIN_NOBIND="true"
export PATH=$PATH:$HOME/bin
export HISTTIMEFORMAT="%F %T "
export HISTSIZE="100000"
export HISTFILESIZE="$HISTSIZE"
shopt -s histappend
PROMPT_COMMAND='history -a'
export LS_OPTIONS='--color=auto'

if [[ $- == *i* ]] # execute if in interactive shell
then
  PS1='\[\033[1;37m\][`date +%H:%M:%S`]\[\033[1;36m\][\[\033[1;31m\]\u\[\033[1;33m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;36m\]]\[\033[1;31m\]\\$\[\033[0m\] '
  source -- /usr/local/lib/blesh/ble.sh --attach=none
  eval "$(atuin init bash)"
  bind -x '"\C-q": __atuin_history'
  source /usr/share/bash-completion/bash_completion
  source /usr/share/doc/fzf/examples/key-bindings.bash
  alias cat='batcat --style=plain --paging=never'
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
fi
BASHRC

mkdir -p /root/.config/nvim

install -Dm0644 "$DIR/files/init.vim" /root/.config/nvim/init.vim

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

install -Dm0644 "$DIR/files/atuin.toml" /root/.config/atuin/config.toml

install -Dm0644 "$DIR/files/screenrc" /root/.screenrc

