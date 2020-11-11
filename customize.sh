# BluetoothLibraryPatcher
# by 3arthur6

check() {
  samsung=`grep -Eqw "androidboot.odin_download|androidboot.warranty_bit|sec_debug" /proc/cmdline && echo 'true' || echo 'false'`
  if $BOOTMODE ; then
    ui_print "- Magisk Manager installation"
    sys="`magisk --path`/.magisk/mirror/system"
  else
    ui_print "- Recovery installation"
    sys=`dirname $(find $ANDROID_ROOT -mindepth 1 -maxdepth 2 -path "*system/build.prop")`
  fi
  if ! $samsung ; then
    ui_print "- Only for Samsung devices!"
    abort
  elif ! `grep -qw ro.build.type=user $sys/build.prop` ; then
    ui_print "- Only for Samsung stock based roms!"
    ui_print "- Not relevant for aosp roms!"
    abort
  elif [[ $API -lt 24 ]] ; then
    ui_print "- Only for Android 7.0 (Nougat) and above"
    abort
  fi
}

search() {
  ui_print "- Searching for lib path and relevant hex bytes sequence"
  libpath=`find $sys/lib*|grep -E "\/(libbluetooth|bluetooth\.default)\.so$"|tail -n 1`
  unzip -q $ZIPFILE hexpatch.sh -d $TMPDIR
  chmod 755 $TMPDIR/hexpatch.sh
  unzip -p $ZIPFILE bash.tar.xz|tar x -J -C $TMPDIR bash
  chmod 755 $TMPDIR/bash
  export TMPDIR API IS64BIT libpath
  # Executed though bash for array handling
  $TMPDIR/bash $TMPDIR/hexpatch.sh
}

extract() {
  if [ ! -f $libpath ] ; then
    ui_print "- Library not found!"
    abort
  else
    ui_print "- Copying library from system to module"
    mod_path="$MODPATH/`echo $libpath|grep -o system.*`"
    mkdir -p `dirname $mod_path`
    cp -af $libpath $mod_path
  fi
}

patchlib() {
  ui_print "- Applying patch"
  pre=`cat $TMPDIR/patch|sed -n '1 p'`
  post=`cat $TMPDIR/patch|sed -n '2 p'`
  if [[ $pre == $post ]] ; then
    ui_print "- Library already (system-ly) patched!"
    abort
  elif /data/adb/magisk/magiskboot hexpatch $mod_path $pre $post ; then
    ui_print "- Successfully patched!"
  else
    ui_print "- Library not supported!"
    echo -e "BOOTMODE=$BOOTMODE\nAPI=$API\nIS64BIT=$IS64BIT\nlibpath=$libpath" > $TMPDIR/debug
    tar c -f /sdcard/BluetoothLibPatcher-files.tar $libpath $TMPDIR/patch $TMPDIR/debug
    ui_print  " "
    ui_print "- To get support upload BluetoothLibPatcher-files.tar"
    ui_print 	"  created in your internal storage to the XDA thread"
    abort
  fi
}

check
search
extract
patchlib