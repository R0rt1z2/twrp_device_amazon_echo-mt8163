#!/sbin/sh

PATH=/sbin:/system/sbin:/system/bin:/system/xbin
DATA=/dev/block/platform/bootdevice/by-name/userdata
LOG=/tmp/e2fsck-data.log

led_render() { :; }
[ -f /sbin/led-common.sh ] && . /sbin/led-common.sh

[ -b "${DATA}" ] || exit 0

exec >> ${LOG} 2>&1

led_render fsck
echo "--- e2fsck ${DATA} ---"
e2fsck -v -f -y -C 0 -E fragcheck,discard ${DATA}
rc=$?
echo "--- e2fsck exit ${rc} ---"
led_render off

setprop twrp.e2fsck.data ${rc}
exit 0
