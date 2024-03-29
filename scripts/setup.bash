#!/bin/bash

zypper in -y caddy curl git libgthread-2_0-0 Mesa python310 screen

firewall-cmd --permanent --add-service=ssh --add-service=http --add-service=https
systemctl restart firewalld


set +H
set-PASS () {
  local passvar=1; local passvar2=2
  while [ "$passvar" != "$passvar2" ]; do echo "Webui password previously unset or input inconsistent."; \
    read -sp 'Password: ' passvar
    echo
    read -sp 'Confirm: ' passvar2
    echo
  done
  phash=$(caddy hash-password --plaintext $passvar)
}
read -p 'Username: ' uname
echo
set-PASS
read -p 'Hostname: ' hname
echo
read -p 'Domain: ' domain
echo


systemctl enable --now caddy
cat <<EOL > /etc/caddy/Caddyfile
{
  local_certs
}

https://$hname, https://diffusion.$domain {
  basicauth * {
    $uname $phash
  }
  reverse_proxy localhost:7860
}

https://focus.$domain {
  basicauth * {
    $uname $phash
  }
  reverse_proxy localhost:7865
}
EOL

cat /etc/caddy/Caddyfile
systemctl restart caddy
