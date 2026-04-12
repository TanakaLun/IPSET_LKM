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

if [ "$KSU" ] || [ "$APATCH" ]; then
    ui_print "- Detected KernelSU/APatch environment"
    
    if [ "$KSU" ]; then
        BIN_DIR="/data/adb/ksu/bin"
    else
        BIN_DIR="/data/adb/ap/bin"
    fi
    
    mkdir -p "$BIN_DIR"
    
    TARGET_LINK="$BIN_DIR/ipset"
    
    if [ -f "$TARGET_LINK" ]; then
        if [ ! -L "$TARGET_LINK" ] && cmp -s "$TARGET_LINK" "$TARGET_DIR/bin/ipset"; then
            ui_print "- ipset binary already exists at $TARGET_LINK, skipping symlink"
        else
            ui_print "- Overwriting existing ipset at $TARGET_LINK"
            rm -f "$TARGET_LINK"
            ln -s "$TARGET_DIR/bin/ipset" "$TARGET_LINK"
        fi
    elif [ -L "$TARGET_LINK" ]; then
        rm -f "$TARGET_LINK"
        ln -s "$TARGET_DIR/bin/ipset" "$TARGET_LINK"
        ui_print "- Symbolic link created at $TARGET_LINK"
    else
        ln -s "$TARGET_DIR/bin/ipset" "$TARGET_LINK"
        ui_print "- Symbolic link created at $TARGET_LINK"
    fi

elif [ "$MAGISK_VER_CODE" ]; then
    ui_print "- Detected Magisk environment"
    
    mkdir -p "$MODPATH/system/bin"
    
    if [ -f "$MODPATH/bin/ipset" ]; then
        mv "$MODPATH/bin/ipset" "$MODPATH/system/bin/ipset"
        ui_print "- ipset moved to $MODPATH/system/bin for Magisk mount"
    else
        ui_print "! ipset binary not found in bin folder"
        abort
    fi
    
    set_perm "$MODPATH/system/bin/ipset" 0 0 0755
        
    ui_print "- ipset will be mounted to /system/bin via Magisk"
    
else
    ui_print "! Unsupported or recovery environment"
    abort
fi

ui_print "- Binary Installation completed."

[ -d "$MODPATH/netfilter" ] && {
    rm -rf "/data/adb/netfilter"
    mv "$MODPATH/netfilter" "/data/adb/"
    chmod -R 755 "/data/adb/netfilter"
    ui_print "- IPSET LKM has been installed"
}