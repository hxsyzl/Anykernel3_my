# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Dragon kernel hxsyzl@coolapk
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

## AnyKernel install
dump_boot;

# Check if erofs is present in /vendor/etc/fstab.qcom
# If erofs exists, flash dtbo.img; otherwise skip it
check_and_flash_dtbo() {
  local fstab_file="/vendor/etc/fstab.qcom";
  local has_erofs=0;
  
  ui_print " " "Checking for erofs in $fstab_file...";
  
  if [ -f "$fstab_file" ]; then
    if grep -q -i "erofs" "$fstab_file"; then
      has_erofs=1;
      ui_print " " "erofs detected! Flashing dtbo.img...";
    else
      ui_print " " "No erofs found. Skipping dtbo.img...";
    fi
  else
    ui_print " " "Warning: $fstab_file not found. Skipping dtbo.img...";
  fi
  
  if [ "$has_erofs" -eq 1 ]; then
    flash_generic dtbo;
  fi
}

# Repack and flash boot image
repack_ramdisk;
flash_boot;

# Conditionally flash dtbo based on erofs detection
check_and_flash_dtbo;
## end install

