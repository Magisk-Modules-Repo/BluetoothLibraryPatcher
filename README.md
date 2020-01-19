# Bluetooth Library Patcher

## Description

This module attends to avoid losing bluetooth pairings after reboot or airplane mode switch on rooted samsung devices.

It patches on the fly the bluetooth library.

It is reported to work on exynos S10e, S10, S10+, N9, N10+, us snapdragon S10+, chinese snapdragon N10+ and S10+ on Android 10 / One UI 2. Also works with N9 on Pie. So it is expected to work with other devices and older OS.

It supports Android 10 and should also work with Pie and Oreo (8.0/8.1).

## Credits

• @topjohnwu for magisk and magiskboot used here for its easy-to-use hexpatcher

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
