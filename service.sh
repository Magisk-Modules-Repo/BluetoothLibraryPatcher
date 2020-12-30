# BluetoothLibraryPatcher
# ota survival script
# by 3arthur6

previouslibmd5sum_tmp

if [[ $previouslibmd5sum != `md5sum $(find $(magisk --path)/.magisk/mirror/system/lib*|grep -E "\/(libbluetooth|bluetooth\.default)\.so$"|tail -n 1)|cut -d " " -f1` ]] ; then
  magisk --install-module /data/adb/modules/BluetoothLibraryPatcher/install.zip
else
  exit
fi
