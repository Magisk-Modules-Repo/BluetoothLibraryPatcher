# BluetoothLibraryPatcher
# by 3arthur6

set_vars() {
  model=`grep -o androidboot.em.model=.* /proc/cmdline | cut -d ' ' -f1 | cut -d '=' -f2`
  qcom=`grep -oqw androidboot.hardware=qcom /proc/cmdline && echo 'true' || echo 'false'`

  if [ -z $model ] ; then
    abort "- Only for Samsung devices!"
  fi
  if $BOOTMODE ; then
    ui_print "- Magisk Manager installation"
    sys="/sbin/.magisk/mirror/system"
  else
    ui_print "- Recovery installation"
    sys=`find $ANDROID_ROOT -mindepth 1 -maxdepth 2 -path "*system/build.prop" | xargs dirname`
  fi
  if [ $API == 29 ] ; then
    ui_print "- $model on Android 10 detected"
    mod_path="$MODPATH/system/lib64/libbluetooth.so"
    sys_path="$sys/lib64/libbluetooth.so"
    if $qcom ; then
      pre_hex="88000054691180522925C81A69000037E0030032"
      post_hex="04000014691180522925C81A69000037E0031F2A"
    else
      pre_hex="C8000034F4031F2AF3031F2AE8030032"
      post_hex="1F2003D5F4031F2AF3031F2AE8031F2A"
    fi
  elif [ $API == 28 ] ; then
    ui_print "- $model on Android Pie detected"
    mod_path="$MODPATH/system/lib64/libbluetooth.so"
    sys_path="$sys/lib64/libbluetooth.so"
    if $qcom ; then
      pre_hex="7F1D0071E91700F9E83C0054"
      post_hex="E0031F2AE91700F9E8010014"
    elif echo $model | grep -Eq 'SM-A600([FGNPTU]|FN|GN|T1)' ; then
      mod_path=`echo $mod_path | tr -d '64'`
      sys_path=`echo $sys_path | tr -d '64'`
      pre_hex="19B101200028"
      post_hex="00BF00200028"
    elif echo $model | grep -Eq 'SM-A105([FGMN]|FN)' ; then
      mod_path=`echo $mod_path | tr -d '64'`
      sys_path=`echo $sys_path | tr -d '64'`
      pre_hex="18B101200028"
      post_hex="00BF00200028"
    else
      pre_hex="88000034E803003248070035"
      post_hex="1F2003D5E8031F2A48070035"
    fi
  elif [ $API == 27 ] ; then
    ui_print "- $model on Android Oreo 8.1 detected"
    mod_path="$MODPATH/system/lib64/hw/bluetooth.default.so"
    sys_path="$sys/lib64/hw/bluetooth.default.so"
    pre_hex="88000034E803003228050035"
    post_hex="1F2003D5E8031F2A28050035"
  elif [ $API == 26 ] ; then
    ui_print "- $model on Android Oreo 8.0 detected"
    mod_path="$MODPATH/system/lib64/hw/bluetooth.default.so"
    sys_path="$sys/lib64/hw/bluetooth.default.so"
    pre_hex="88000034E803003228050035"
    post_hex="1F2003D5E8031F2A28050035"
  else
    abort "- Only for Android 10, Pie or Oreo!"
  fi
}

extract() {
  if [ ! -f $sys_path ] ; then
    abort "- Aborting! Library not found!"
  elif [ $API -ge 28 ] ; then
    mkdir -p $MODPATH/system/lib64
    ui_print "- Copying library from system to module"
    cp -af $sys_path $mod_path
  else
    mkdir -p $MODPATH/system/lib64/hw
    ui_print "- Copying library from system to module"
    cp -af $sys_path $mod_path
  fi
}

hex_patch() {
  /data/adb/magisk/magiskboot hexpatch $1 $2 $3 2>&1
}

is_lib_patched() {
  /data/adb/magisk/busybox xxd -p $sys_path | tr -d '\n' | grep -iq $post_hex
}

patch_lib() {
  ui_print "- Patching it"
  if ! echo `hex_patch $mod_path $pre_hex $post_hex` | grep -Fq "[$pre_hex]->[$post_hex]" ; then
    rm -rf $MODPATH
    if is_lib_patched ; then
      abort "- Aborting! Library already patched!"
    else
      ui_print "- Aborting! Library not supported!"
      abort "- Ask for support at XDA forum"
    fi
  fi
}

set_vars

extract

patch_lib
