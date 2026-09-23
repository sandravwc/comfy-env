#!/usr/bin/env bash
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
hostname=$(hostname)
source /etc/os-release
MAJOR_VERSION="${VERSION_ID%%.*}"
if [[ "$MAJOR_VERSION" == "8" ]]; then
    powertools="powertools"
elif [[ "$MAJOR_VERSION" == "9" ]]; then
    powertools="crb"
else
    echo "Error: Unsupported AlmaLinux major version ($MAJOR_VERSION)." >&2
    exit 1
fi
dnf install --assumeyes --enablerepo="${powertools}" \
  btop \
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

install -Dm0644 "$DIR/files/blerc" /root/.blerc

install -Dm0644 "$DIR/files/atuin.toml" /root/.config/atuin/config.toml

install -Dm0644 "$DIR/files/dnf-automatic.conf" /etc/dnf/automatic.conf
sed -i "s/@HOSTNAME@/$hostname/" /etc/dnf/automatic.conf

install -Dm0644 "$DIR/files/dnf-automatic-timer.conf" /etc/systemd/system/dnf-automatic.timer.d/override.conf

install -Dm0644 "$DIR/files/screenrc" /root/.screenrc

systemctl enable --now dnf.automatic.timer
echo "command[check_security_updates]=/usr/lib64/nagios/plugins/check_updates --quiet --security-only" >> /etc/nagios/nrpe_local.cfg
rm -f /root/anaconda-ks.cfg /root/changelog.txt /root/original-ks.cfg /root/postinstall.sh 
rm -rf /root/workdir/ble.sh
