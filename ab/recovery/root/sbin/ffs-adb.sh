#!/sbin/sh

PATH=/sbin:/system/sbin:/system/bin:/system/xbin
FFS=/dev/usb-ffs/adb
GADGET=/sys/class/android_usb/android0

log() {
    echo "ffs-adb: $*" > /dev/kmsg
}

log "gadget=$([ -d ${GADGET} ] && echo yes || echo no) f_ffs=$([ -d ${GADGET}/f_ffs ] && echo yes || echo no) fs=$(grep -c functionfs /proc/filesystems)"
log "functions=$(cat ${GADGET}/functions 2>/dev/null) state=$(cat ${GADGET}/state 2>/dev/null)"

mkdir -p ${FFS}

i=0
while [ ${i} -lt 150 ]; do
    if grep -q functionfs /proc/filesystems; then
        if mount -t functionfs adb ${FFS} -o uid=2000,gid=2000 2>/dev/null; then
            log "mounted after ${i} tries"
            setprop sys.usb.ffs.ready 1
            exit 0
        fi
    fi
    i=$((i + 1))
    sleep 0.1
done

log "gave up, functionfs never registered (gadget=$(cat ${GADGET}/state 2>/dev/null))"
exit 1
