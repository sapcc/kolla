#!/bin/bash

if [[ ! -d "/var/log/kolla/barbican" ]]; then
    mkdir -p /var/log/kolla/barbican
fi
if [[ $(stat -c %a /var/log/kolla/barbican) != "755" ]]; then
    chmod 755 /var/log/kolla/barbican
fi

source /usr/local/bin/kolla_barbican_extend_start
