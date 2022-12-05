#!/bin/bash
# Install sing-box.

set -eux pipefail

# Export Qubes DNS nameserver NS1 and NS2
# shellcheck source=/dev/null
. /var/run/qubes/qubes-ns

REMOTE="https://git.sr.ht/~qubes/proxy/blob/main"
WORKDIR="/tmp"
INET4_ADDR="$(echo "${NS1}" | sed 's/[0-9]*$/0/')"

cd "${WORKDIR}"

curl --proto '=https' -tlsv1.2 -sSfL "${REMOTE}/restrict-firewall" -o restrict-firewall
curl --proto '=https' -tlsv1.2 -sSfL "${REMOTE}/sing-box.service" -o sing-box.service
curl --proto '=https' -tlsv1.2 -sSfL "${REMOTE}/sing-box.json" -o sing-box.json

sed -i "s#10.139.1.0#${INET4_ADDR}#" sing-box.json

sudo install -Dm644 -t /rw/config/proxy "${WORKDIR}/sing-box.json"
sudo install -Dm644 -t /rw/config/proxy "${WORKDIR}/sing-box.service"
sudo install -Dm755 -t /rw/config/qubes-firewall.d "${WORKDIR}/restrict-firewall"

sudo cp /rw/config/rc.local /rw/config/rc.local.old
echo 'cp /rw/config/proxy/sing-box.service /etc/systemd/system/sing-box.service' | sudo tee -a /rw/config/rc.local
echo 'systemctl --no-block restart sing-box.service' | sudo tee -a /rw/config/rc.local

url="$(curl -sSfL https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep browser_download_url | grep linux-amd64.tar.gz | cut -d\" -f4)"
curl --proto '=https' -tlsv1.2 -sSfL "${url}" | tar -zx --strip-components=1

sudo install -Dm755 -t /rw/usrlocal/bin "${WORKDIR}/sing-box"

curl --proto '=https' -tlsv1.2 -sSfL https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db -o geoip.db
curl --proto '=https' -tlsv1.2 -sSfL https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db -o geosite.db

sudo install -Dm644 -t /rw/config/proxy "${WORKDIR}/geoip.db"
sudo install -Dm644 -t /rw/config/proxy "${WORKDIR}/geosite.db"
