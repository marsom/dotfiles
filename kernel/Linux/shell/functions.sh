# find large folder on filesystem
function find_large_folders_on_fs() {
  if [ -z " $1" ]; then
    du -x --max-depth=1 /
  else
    du -x --max-depth=1 "$@"
  fi
}

# fast reboot, skip bios and hardware stuff
function reboot_fast() {
  echo "Loading current kernel"
  kexec -l /boot/vmlinuz-$(unema -r) --initrd=/boot/initramfs-$(unema -r).img --reuse-cmdline
  echo "please run kexec -e"
}