##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
PosTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "   Bluetooth Library Patcher   "
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
    
  check_os_and_set_vars
  
  check_lib
  
  extract
  
  patch_lib
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code

check_os_and_set_vars() {
  if [ $API == 29 ] ; then
    ui_print "- Android 10 detected"
    library="libbluetooth.so"
    path="$MODPATH/system/lib64/libbluetooth.so"
    pre_hex="C8000034F4031F2AF3031F2AE8030032"
    post_hex="C8000035F4031F2AF3031F2AE8031F2A"
  elif [ $API == 28 ] ; then
    ui_print "- Android Pie detected"
    library="libbluetooth.so"
    path="$MODPATH/system/lib64/libbluetooth.so"
    pre_hex="88000034E803003248070035"
    post_hex="88000035E8031F2A48070035"
  elif [ $API == 27 ] ; then
    ui_print "- Android Oreo 8.1 detected"
    library="bluetooth.default.so"
    path="$MODPATH/system/lib64/hw/bluetooth.default.so"
    path2="$MODPATH/system/lib/hw/bluetooth.default.so"
    pre_hex="88000034E803003228050035"
    pre_hex2="0978019009B1012032E07748"
    post_hex="88000035E8031F2A28050035"
    post_hex2="0978019009B9002032E07748"
  elif [ $API == 26 ] ; then
    ui_print "- Android Oreo 8.0 detected"
    library="bluetooth.default.so"
    path="$MODPATH/system/lib64/hw/bluetooth.default.so"
    path2="$MODPATH/system/lib/hw/bluetooth.default.so"
    pre_hex="88000034E803003228050035"
    pre_hex2="0190087808B1012031E07548"
    post_hex="88000035E8031F2A28050035"
    post_hex2="0190087808B9002031E07548"
  else
    abort "- Only for Android 10, Pie or Oreo!"
  fi
}

check_lib() {
  if [ "$library"=="libbluetooth.so" ] && [ ! -f "/sbin/.magisk/mirror/system/lib64/$library" ] ; then
    abort "- No $library library found!"
  elif [ "$library"=="bluetooth.default.so" ] && [ [ ! -f "/sbin/.magisk/mirror/system/lib64/hw/$library" ] ||  [ ! -f "/sbin/.magisk/mirror/system/lib64/hw/$library" ] ] ; then
    abort "- No $library libraries found!"
  fi
}

extract() {
  if [ "$library"=="libbluetooth.so" ] ; then
    mkdir -p $MODPATH/system/lib64
    ui_print "- Extracting $library library from system"
    cp -f /sbin/.magisk/mirror/system/lib64/$library $path
  else
    mkdir -p $MODPATH/system/lib64/hw $MODPATH/system/lib/hw
    ui_print "- Extracting $library libraries from system"
    cp -f /sbin/.magisk/mirror/system/lib64/hw/$library $path
    cp -f /sbin/.magisk/mirror/system/lib/hw/$library $path2
  fi
}

hex_patch() {
  /data/adb/magisk/magiskboot hexpatch $1 $2 $3 2>&1
}

patch_lib() {
  ui_print "- Patching it"
  if [ ! echo $(hex_patch $path $pre_hex $post_hex) | grep -Fq "[$pre_hex]->[$post_hex]" ] ; then
    abort "- Library not supported!"
  fi
  if [ "$library"=="bluetooth.default.so" ] && [ ! echo $(hex_patch $path2 $pre_hex2 $post_hex2) | grep -Fq "[$pre_hex2]->[$post_hex2]" ] ; then
    abort "- Library not supported!"
  fi
}
