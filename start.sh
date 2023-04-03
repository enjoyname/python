#!/bin/sh

PORT=45602
UUID=792a1f6a-bd99-4eff-9831-acf133ffe7aa
WebPage=https://bing.com
CaddyConfig=https://raw.githubusercontent.com/enjoyname/python/main/etc/Caddyfile
XRayConfig=https://raw.githubusercontent.com/enjoyname/python/main/etc/xray.json
Xray_Newv=`wget --no-check-certificate -qO- https://api.github.com/repos/XTLS/Xray-core/tags | grep 'name' | cut -d\" -f4 | head -1 | cut -b 2-`
# Install XRay
mkdir -p /tmp/app
wget -qO /tmp/app/xray.zip https://github.com/XTLS/Xray-core/releases/download/v$Xray_Newv/Xray-linux-64.zip
unzip -q /tmp/app/xray.zip -d /tmp/app
install -m 755 /tmp/app/xray /usr/local/bin/xray
install -d /usr/local/etc/xray

# Install Web
mkdir -p /usr/share/caddy
echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $WebPage -O /usr/share/caddy/index.html
unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/
mv /usr/share/caddy/*/* /usr/share/caddy/

# Remove Temp Directory
rm -rf /tmp/app

# Configs
mkdir -p /etc/caddy
wget -qO- $CaddyConfig | sed -e "1c :$PORT" | sed -e "s/\$UUID/$UUID/g" >/etc/caddy/Caddyfile
wget -qO- $XRayConfig | sed -e "s/\$UUID/$UUID/g" >/usr/local/etc/xray/xray.json

# Start
/usr/local/bin/xray -config /usr/local/etc/xray/xray.json & 
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
