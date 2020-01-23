# BluetoothLibraryPatcher
# by 3arthur6

set_vars() {
  model=`grep -o androidboot.em.model=........ /proc/cmdline | cut -d "=" -f2`

  if [ -z $model ] ; then
    abort "- Only for Samsung devices!"
  fi
  if $BOOTMODE ; then
    ui_print "- Magisk Manager installation"
    sys_path="/sbin/.magisk/mirror/system"
  else
    ui_print "- Recovery installation"
    sys_path=`find $ANDROID_ROOT -mindepth 1 -maxdepth 2 -path "*system/build.prop" | xargs dirname`
  fi
  if [ $API == 29 ] ; then
    ui_print "- $model on Android 10 detected"
    library="libbluetooth.so"
    path="$MODPATH/system/lib64/$library"
    if echo $model | grep -Eq SM-[GN]97[0356]0 ; then
      pre_hex="88000054691180522925C81A69000037E00300326D020014"
      post_hex="04000014691180522925C81A1F2003D5E0031F2A6D020014"
    else
      pre_hex="C8000034F4031F2AF3031F2AE8030032"
      post_hex="1F2003D5F4031F2AF3031F2AE8031F2A"
    fi
  elif [ $API == 28 ] ; then
    ui_print "- $model on Android Pie detected"
    library="libbluetooth.so"
    path="$MODPATH/system/lib64/$library"
    pre_hex="88000034E803003248070035"
    post_hex="1F2003D5E8031F2A48070035"
  elif [ $API == 27 ] ; then
    ui_print "- $model on Android Oreo 8.1 detected"
    library="bluetooth.default.so"
    path="$MODPATH/system/lib64/hw/$library"
    path2="$MODPATH/system/lib/hw/$library"
    pre_hex="88000034E803003228050035"
    pre_hex2="0978019009B1012032E07748"
    post_hex="1F2003D5E8031F2A28050035"
    post_hex2="0978019000BF002032E07748"
  elif [ $API == 26 ] ; then
    ui_print "- $model on Android Oreo 8.0 detected"
    library="bluetooth.default.so"
    path="$MODPATH/system/lib64/hw/$library"
    path2="$MODPATH/system/lib/hw/$library"
    pre_hex="88000034E803003228050035"
    pre_hex2="0190087808B1012031E07548"
    post_hex="1F2003D5E8031F2A28050035"
    post_hex2="0190087800BF002031E07548"
  else
    abort "- Only for Android 10, Pie or Oreo!"
  fi
}

check_lib() {
  if [ $API -ge 28 ] && [ ! -f "$sys_path/lib64/$library" ] ; then
    abort "- No $library library found!"
  elif [ $API -le 27 ] && [ [ ! -f "$sys_path/lib64/hw/$library" ] || [ ! -f "$sys_path/lib/hw/$library" ] ] ; then
    abort "- No $library libraries found!"
  fi
}

extract() {
  if [ $API -ge 28 ] ; then
    mkdir -p $MODPATH/system/lib64
    ui_print "- Copying library from system to module"
    cp -af $sys_path/lib64/$library $path
  else
    mkdir -p $MODPATH/system/lib64/hw $MODPATH/system/lib/hw
    ui_print "- Copying libraries from system to module"
    cp -af $sys_path/lib64/hw/$library $path
    cp -af $sys_path/lib/hw/$library $path2
  fi
}

hex_patch() {
  /data/adb/magisk/magiskboot hexpatch $1 $2 $3 2>&1
}

patch_lib() {
  ui_print "- Patching it"
  if ! echo $(hex_patch $path $pre_hex $post_hex) | grep -Fq "[$pre_hex]->[$post_hex]" ; then
    abort "- Library not supported!"
  fi
  if [ $API -le 27 ] && ! echo $(hex_patch $path2 $pre_hex2 $post_hex2) | grep -Fq "[$pre_hex2]->[$post_hex2]" ; then
    abort "- Library not supported!"
  fi
}

set_vars
  
check_lib
  
extract
  
patch_lib
