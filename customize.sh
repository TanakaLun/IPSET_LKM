#!/system/bin/sh

if [ -z "$KSU" ]; then
    ui_print "! This module only supports KernelSU"
    abort
fi

set_perm "$MODPATH/bin/ipset" 0 0 0777

[ -d "$MODPATH/netfilter" ] && {
    rm -rf "/data/adb/netfilter"
    mv "$MODPATH/netfilter" "/data/adb/"
    chmod -R 755 "/data/adb/netfilter"
    ui_print "- IP-SET Is Installed"
}