# BluetoothLibraryPatcher
# hexpatch script
# by 3arthur6

bb=/data/adb/magisk/busybox
qcom=`$bb grep -qw androidboot.hardware=qcom /proc/cmdline && echo 'true' || echo 'false'`

# default(mostly arm64 exynos)=1   arm=2   qcom=3
variant=`if ! $IS64BIT; then echo 2; elif $qcom; then echo 3; else echo 1; fi`

hex=( \
# default
[130]=........f3031f2af4031f2a3e000014 [1130]=1f2003d5f3031f2af4031f2a3e000014 \
[129]=........f4031f2af3031f2ae8030032 [1129]=1f2003d5f4031f2af3031f2ae8031f2a \
[128]=88000034e803003248070035 [1128]=1f2003d5e8031f2a48070035 \
[127]=88000034e803003228050035 [1127]=1f2003d5e8031f2a28050035 \
[126]=${hex[127]} [1126]=${hex[1127]} \
# arm
[229]=..b100250120 [1229]=00bf00250020 \
[228]=..b101200028 [1228]=00bf00200028 \
[237]=09b1012032e0 [1227]=00bf002032e0 \
[236]=08b1012031e0 [1226]=00bf002031e0 \
[235]=087850bbb548 [1225]=0878bde0b548 \
[234]=007840bb6a48 [1224]=002028e06a48 \
# qcom
[330]=88000054691180522925c81a6900003720008052 [1330]=04000014691180522925c81a69000037e0031f2a \
[329]=88000054691180522925c81a69000037e0030032 [1329]=04000014691180522925c81a69000037e0031f2a \
[328]=7f1d0071e91700f9e83c0054 [1328]=e0031f2ae91700f9e8010014)


if $qcom && ! `$bb xxd -p $libpath|$bb tr -d '\n'|$bb grep -qm1 ${hex[$variant$API]}` ; then
  variant='1'
fi
if ( ! $IS64BIT && [[ $API -ge 28 ]] ) || ( [[ $variant == 1 ]] && [[ $API -ge 29 ]] ) ; then
  hex[$variant$API]=`$bb xxd -p $libpath|$bb tr -d '\n'|$bb grep -om1 ${hex[$variant$API]}`
fi
if [[ -z ${hex[$variant$API]} ]] ; then
  if `$bb xxd -p $libpath|$bb tr -d '\n'|$bb grep -qm1 ${hex[1$variant$API]}` ; then
    hex[$variant$API]=${hex[1$variant$API]}
  else
    hex[$variant$API]=not_found
  fi
fi
echo -e "${hex[$variant$API]}\n${hex[1$variant$API]}\n$($bb grep -o androidboot.bootloader=.* /proc/cmdline|$bb cut -d ' ' -f1|$bb cut -d '=' -f2)" > $TMPDIR/patch