# BluetoothLibraryPatcher
# hexpatch script
# by 3arthur6

bb=/data/adb/magisk/busybox
qcom=`$bb grep -qw androidboot.hardware=qcom /proc/cmdline && echo 'true' || echo 'false'`

# default(mostly arm64 exynos)=1   arm=2   qcom=3
var=`if ! $IS64BIT || [[ $API -le 25 ]]; then echo 2; elif $qcom && [[ $API -le 30 ]]; then echo 3; else echo 1; fi`

hex=( \
# default
[131]=........f9031f2af3031f2a41000014 [1131]=1f2003d5f9031f2af3031f2a48000014 \
[130]=........f3031f2af4031f2a3e000014 [1130]=1f2003d5f3031f2af4031f2a3e000014 \
[129]=........f4031f2af3031f2ae8030032 [1129]=1f2003d5f4031f2af3031f2ae8031f2a \
[128]=88000034e803003248070035 [1128]=1f2003d5e8031f2a48070035 \
[127]=${hex[126]}                                 [1127]=${hex[1126]} \
[126]=88000034e803003228050035 [1126]=1f2003d5e8031f2a28050035 \
# arm
[230]=18b14ff0000b00254ae0 [1230]=00204ff0000b002554e0 \
[229]=..b100250120 [1229]=00bf00250020 \
[228]=..b101200028 [1228]=00bf00200028 \
[227]=09b1012032e0 [1227]=00bf002032e0 \
[226]=08b1012031e0 [1226]=00bf002031e0 \
[225]=087850bbb548 [1225]=08785ae1b548 \
[224]=007840bb6a48 [1224]=0078c4e06a48 \
# qcom
[330]=${hex[329]} [1330]=${hex[3129]} \
[329]=88000054691180522925c81a69000037........ [1329]=04000014691180522925c81a69000037e0031f2a \
[328]=7f1d0071e91700f9e83c0054 [1328]=e0031f2ae91700f9e8010014 \
# what is happening samsung
[429]=....0034f3031f2af4031f2a....0014 [1429]=1f2003d5f3031f2af4031f2a47000014 \
# what again (T510)
[529]=44387810b1002400254ae0 [1529]=44387800200024002556e0 \
[530]=18b100244ff0000b4de0 [1530]=002000244ff0000b57e0 \
# ... (T595)
[629]=90387810b1002400254ae0 [1629]=90387800200024002558e0 \
# A105F
[630]=18b100244ff0000b4de0 [1630]=002000244ff0000b57e0 )

if [[ $var == 3 ]] && ! `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[$var$API]}` ; then
  if `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[1$var$API]}` ; then
    hex[$var$API]=already
  else
    var=1
  fi
fi
if ( [[ $var == 1 ]] && [[ $API -ge 29 ]] ) || ( [[ $var == 2 ]] && [[ $API -ge 28 ]] ) ; then
  hex[$var$API]=`$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -om1 ${hex[$var$API]}`
fi
if [[ -z `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -om1 ${hex[$var$API]}` ]] ; then
  if `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[1$var$API]}` ; then
    hex[$var$API]=already
  elif [[ $var == 1 ]] && [[ $API == 29 ]] && hex[4$API]=`$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -om1 ${hex[4$API]}` && [[ ! -z ${hex[4$API]} ]] ; then
    var=4
  elif [[ $var == 2 ]] && [[ $API -ge 29 ]] ; then
    if `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[5$API]}` ; then
      var=5
    elif `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[6$API]}` ; then
      var=6
    fi
  fi
fi
echo -e "${hex[$var$API]}\n${hex[1$var$API]}\nvar=$var\nbl=$($bb grep -o androidboot.bootloader=.* /proc/cmdline|$bb cut -d ' ' -f1|$bb cut -d '=' -f2)" > $TMPDIR/patch
