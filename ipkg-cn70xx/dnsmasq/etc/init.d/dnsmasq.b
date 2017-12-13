#!/bin/sh /etc/rc.common
# Copyright (C) 2007-2012 OpenWrt.org

START=98

USE_PROCD=1
PROG=/usr/sbin/dnsmasq

DNS_SERVERS=""
DOMAIN=""

ADD_LOCAL_DOMAIN=1
ADD_LOCAL_HOSTNAME=1

CONFIGFILE="/var/etc/dnsmasq.b.conf"

xappend() {
        local value="$1"

        echo "${value#--}" >> $CONFIGFILE
}

service_triggers()
{
        procd_add_reload_trigger "dhcp"
}

boot() {
        # Will be launched through hotplug
        return 0
}

start_service() {
        include /lib/functions

        config_load 'acl'
        config_get_bool enabled acl 'enabled' '0'
        [ "$enabled" -eq 0 ] && return 0

        procd_open_instance
        procd_set_param command $PROG -C $CONFIGFILE -k -p 15353
        procd_set_param file $CONFIGFILE
        procd_close_instance

        # before we can call xappend
        mkdir -p $(dirname $CONFIGFILE)

        echo "# auto-generated config file from /etc/config/dhcp" > $CONFIGFILE

        # if we did this last, we could override auto-generated config
        [ -f /etc/dnsmasq.b.conf ] && {
                xappend "--conf-file=/etc/dnsmasq.b.conf"
        }

        args=""
        echo >> $CONFIGFILE
}

reload_service() {
        rc_procd start_service "$@"
        return 0
}

