#!/bin/sh
# Swap Alt <-> Win (Option <-> Command) on a Windows-layout keyboard plugged into a Mac, per device, so the
# Mac's own keyboard is untouched. Run at login (e.g. a LaunchAgent) and after plugging the keyboard in.
#
# Find your keyboard's VendorID / ProductID (decimal) with:
#   hidutil list --matching keyboard
# and put them below. The two lines here are examples; delete the ones you do not have.
MAP='{"UserKeyMapping":[
{"HIDKeyboardModifierMappingSrc":0x7000000E2,"HIDKeyboardModifierMappingDst":0x7000000E3},
{"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E2},
{"HIDKeyboardModifierMappingSrc":0x7000000E6,"HIDKeyboardModifierMappingDst":0x7000000E7},
{"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x7000000E6}]}'
# E2/E6 = left/right Alt (Option), E3/E7 = left/right Win (Command).

# Example: a USB gaming keyboard (0x258a:0x010c)
/usr/bin/hidutil property --matching '{"VendorID":9610,"ProductID":268}' --set "$MAP" >/dev/null 2>&1
# Example: a Bluetooth keyboard that reports Apple's vendor id (0x05ac:0x024f)
/usr/bin/hidutil property --matching '{"VendorID":1452,"ProductID":591}' --set "$MAP" >/dev/null 2>&1
exit 0
