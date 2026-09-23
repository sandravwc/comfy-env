#!/usr/bin/env bash
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS* && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.epel.cloud|g' /etc/yum.repos.d/CentOS*
yum install neovim bash-completion git -y
yum install https://github.com/fastfetch-cli/fastfetch/releases/download/1.6.3/fastfetch-1.6.3-Linux.rpm -y
wget -O bat.zip https://github.com/sharkdp/bat/releases/download/v0.7.1/bat-v0.7.1-x86_64-unknown-linux-musl.tar.gz && tar xzf bat.zip -C /usr/local/ && mv /usr/local/bat-v0.7.1-x86_64-unknown-linux-musl/bat /usr/local/bin/
mkdir -p /root/workdir
git clone https://github.com/akinomyoga/ble.sh.git /root/workdir/ble.sh
cd /root/workdir/ble.sh && make install INSDIR=/usr/local/lib/blesh
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

install -Dm0644 "$DIR/files/bash_profile" /root/.bash_profile

cat <<- 'BASHRC' > /root/.bashrc
if [[ $- == *i* ]] # execute if in interactive shell
then
  PS1='\[\033[1;37m\][`date +%H:%M:%S`]\[\033[1;36m\][\[\033[1;31m\]\u\[\033[1;33m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;36m\]]\[\033[1;31m\]\\$\[\033[0m\] '
  shopt -s extglob
  source -- /usr/local/lib/blesh/ble.sh --attach=none
  eval "$(atuin init bash)"
  bind -x '"\C-q": __atuin_history'
  [[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
  alias cat='bat --style=plain --paging=never'
  if [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]]
  then
    source /usr/share/bash-completion/bash_completion
  fi
fi 
  
umask 022
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias ..='cd ..'
alias ...='cd ../..'
alias vi='nvim'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

if [[ $- == *i* ]] # execute if in interactive shell
then
 [[ ! ${BLE_VERSION-} ]] || ble-attach
fi
BASHRC

mkdir -p /root/.config/nvim
install -Dm0644 "$DIR/files/init.vim" /root/.config/nvim/init.vim

cat <<- 'MOTDSH' > /etc/profile.d/motd.sh
#!/usr/bin/env bash
fastfetch \
  --logo none \
  --structure kernel:os:packages:uptime:memory:cpu:disk:shell:localip:publicip
MOTDSH

install -Dm0644 "$DIR/files/blerc" /root/.blerc

install -Dm0644 "$DIR/files/atuin.toml" /root/.config/atuin/config.toml

install -Dm0644 "$DIR/files/screenrc" /root/.screenrc

rm -f /root/anaconda-ks.cfg /root/changelog.txt /root/original-ks.cfg /root/postinstall.sh /root/bat.zip
rm -rf /root/workdir/ble.sh
