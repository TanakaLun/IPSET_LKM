#!/system/bin/sh
if ! command -v ksud >/dev/null 2>&1; then
    ui_print "! ksud command not found. This module requires ksud support."
    abort
fi

MODID=$(grep_prop id "$MODPATH/module.prop")
if [ -z "$MODID" ]; then
    ui_print "! Failed to read module ID."
    abort
fi

TARGET_DIR="/data/modules/$MODID"
mkdir -p "$TARGET_DIR"
if [ -d "$MODPATH/bin" ]; then
    cp -rf "$MODPATH/bin" "$TARGET_DIR/"
else
    ui_print "! bin folder not found in module."
    abort
fi

set_perm_recursive "$TARGET_DIR/bin" 0 0 0755 0755

if [ -L "/data/adb/ksu/bin/ipset" ]; then
    rm -f "/data/adb/ksu/bin/ipset"
elif [ -e "/data/adb/ksu/bin/ipset" ]; then
    ui_print "! File exists at /data/adb/ksu/bin/ipset and is not a symlink"
    abort
fi
ln -s "$TARGET_DIR/bin/ipset" "/data/adb/ksu/bin/ipset"

ui_print "Binary Installation completed. Binary placed in $TARGET_DIR/bin"

[ -d "$MODPATH/netfilter" ] && {
    rm -rf "/data/adb/netfilter"
    mv "$MODPATH/netfilter" "/data/adb/"
    chmod -R 755 "/data/adb/netfilter"
    ui_print "- IP-SET has been installed"
}