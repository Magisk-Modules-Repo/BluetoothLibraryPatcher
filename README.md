# Bluetooth Library Patcher

## Description

This module attends to avoid losing bluetooth pairings after reboot or airplane mode switch on rooted samsung devices.

It patches on the fly the bluetooth library.

It is reported to work on exynos S10e, S10, S10+, N9, N10+, us snapdragon S10+, chinese snapdragon N10+ and S10+ on Android 10 / One UI 2. Also works with exynos N9 and chinese/global snapdragon N10 on Pie. So it is expected to work with other devices and older OS.

It supports Android 10 and should also work with Pie and Oreo (8.0/8.1).

If it fails on your device, please post your /system/lib64/libbluetooth.so and /system/build.prop files on XDA thread and I will be able to add support for it.

## Credits

• @topjohnwu for magisk and magiskboot used here for its easy-to-use hexpatcher

## Source code

[Github](https://github.com/Magisk-Modules-Repo/BluetoothLibraryPatcher)

## Support

[XDA](https://forum.xda-developers.com/galaxy-note-9/development/zip-libbluetooth-patcher-fix-losing-t4017735)

## Changelog

### v1.0

- Initial release

### v1.1

- Add verification point, to know if we successfully hexpatch

### v1.2

- Add recovery installation support

### v1.3

- Modify hexpatch (more safer patch)

### v1.4

- Add support for chinese variants

### v1.5

- Check we try to apply the patch on a Samsung device & add missing chinese Note10+ 5G variant

### v1.6

- Fix brand and model detection for magisk manager and recovery installation

### v1.7

- Add support for chinese/global snapdragon on Pie
- Add support for chinese/global S/N9 snapdragon on Q & simplify the hexpatch
