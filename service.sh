# BluetoothLibraryPatcher
# ota survival script
# by 3arthur6

MODDIR=${0%/*}
previouslibmd5sum_tmp

if [[ $previouslibmd5sum != `md5sum $(find $(magisk --path)/.magisk/mirror/system/lib*|grep -E "\/(libbluetooth|bluetooth\.default)\.so$"|tail -n 1)|cut -d " " -f1` ]] ; then
  magisk --install-module $MODDIR/module.zip
else
  exit
fi
