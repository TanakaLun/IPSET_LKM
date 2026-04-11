#!/system/bin/sh
MODID=$(grep_prop id "$MODPATH/module.prop")
if [ -z "$MODID" ]; then
    ui_print "! Failed to read module ID."
    abort
fi

TARGET_DIR="/data/adb/modules/$MODID"
mkdir -p "$TARGET_DIR"
if [ -d "$MODPATH/bin" ]; then
    cp -rf "$MODPATH/bin" "$TARGET_DIR/"
else
    ui_print "! bin folder not found in module."
    abort
fi

set_perm_recursive "$TARGET_DIR/bin" 0 0 0755 0755
set_perm_recursive "$MODPATH/bin" 0 0 0755 0755

BIN_DIR=$(echo "$PATH" | tr ':' '\n' | grep '/data/.*bin' | head -1)

TARGET_LINK="$BIN_DIR/ipset"
[ -L "$TARGET_LINK" ] && rm -f "$TARGET_LINK"
if [ -e "$TARGET_LINK" ]; then
    ui_print "! File exists at $TARGET_LINK and is not a symlink"
    abort
fi

ln -s "$TARGET_DIR/bin/ipset" "$TARGET_LINK"

ui_print "- Binary Installation completed. Binary placed in $TARGET_DIR/bin"

[ -d "$MODPATH/netfilter" ] && {
    rm -rf "/data/adb/netfilter"
    mv "$MODPATH/netfilter" "/data/adb/"
    chmod -R 755 "/data/adb/netfilter"
    ui_print "- IPSET has been installed"
}