#!/usr/bin/env bash

if [[ ${UID} == 0 ]]; then
    echo "Configuring supervisord to run as nobody"
    sed -i -e "/nodaemon=true/a \user=nobody" /etc/supervisor/supervisord.conf
    sed -i -e "/user=nobody/a \group=nobody" /etc/supervisor/supervisord.conf
fi
