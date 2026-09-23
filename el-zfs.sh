#!/usr/bin/env bash
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dnf install --assumeyes --enablerepo=powertools \
  btop  \
  fzf \
  bat \
  neovim \
  bash-completion \
  fastfetch \
  glibc-langpack-en \
  git \
  dnf-automatic \
  nagios-plugins-check-updates \
  perl-Params-Validate \
  perl-Math-Calc-Units \
  perl-Class-Accessor \
  perl-Config-Tiny

mkdir -p /root/.config/nvim
mkdir -p /root/workdir
mkdir -p /root/bin
git clone https://github.com/akinomyoga/ble.sh.git /root/workdir/ble.sh
cd /root/workdir/ble.sh && make install INSDIR=/usr/local/lib/blesh
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

install -Dm0644 "$DIR/files/bash_profile" /root/.bash_profile

install -Dm0644 "$DIR/files/bashrc" /root/.bashrc

install -Dm0644 "$DIR/files/init.vim" /root/.config/nvim/init.vim

install -Dm0755 "$DIR/files/motd.sh" /etc/profile.d/motd.sh
printf '\n/root/bin/zpool-bar\n' >> /etc/profile.d/motd.sh

install -Dm0644 "$DIR/files/blerc" /root/.blerc

install -Dm0644 "$DIR/files/atuin.toml" /root/.config/atuin/config.toml

cat <<- 'ZPOOLBAR' > /root/bin/zpool-bar
#!/usr/bin/env bash

max_usage=90
bar_width=50
white="\e[39m"
green="\e[1;32m"
red="\e[1;31m"
dim="\e[2m"
undim="\e[0m"

printf "\nzpool status:\n"
zpool status -x | sed -e 's/^/  /'

mapfile -t zpools < <(zpool list -Ho name,cap,size)
printf "\nzpool usage:\n"

for line in "${zpools[@]}"; do

  usage=$(echo "$line" | awk '{print $2}' | sed 's/%//')
  used_width=$((($usage*$bar_width)/100))

  if [ "${usage}" -ge "${max_usage}" ]; then
    color=$red
  else
    color=$green
  fi

  bar="[${color}"
  for ((i=0; i<$used_width; i++)); do
    bar+="="
  done

  bar+="${white}${dim}"
  for ((i=$used_width; i<$bar_width; i++)); do
    bar+="="
  done
  bar+="${undim}]"

  echo "${line}" | awk '{ printf("%-30s%+3s used out of %+5s\n", $1, $2, $3); }' | sed -e 's/^/  /'
  echo -e "${bar}" | sed -e 's/^/  /'
done
ZPOOLBAR

install -Dm0644 "$DIR/files/dnf-automatic.conf" /etc/dnf/automatic.conf
sed -i "s/@HOSTNAME@/$hostname/" /etc/dnf/automatic.conf

install -Dm0644 "$DIR/files/dnf-automatic-timer.conf" /etc/systemd/system/dnf-automatic.timer.d/override.conf

install -Dm0644 "$DIR/files/screenrc" /root/.screenrc

echo "command[check_security_updates]=/usr/lib64/nagios/plugins/check_updates --quiet --security-only" >> /etc/nagios/nrpe_local.cfg
systemctl enable --now dnf-automatic.timer
chmod +x /root/bin/zpool-bar
rm -f /root/anaconda-ks.cfg /root/changelog.txt /root/original-ks.cfg /root/postinstall.sh 
rm -rf /root/workdir/ble.sh
