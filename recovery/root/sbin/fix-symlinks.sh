#!/sbin/sh

PATH=/sbin:/system/sbin:/system/bin:/system/xbin
BYNAME=/dev/block/platform/bootdevice/by-name

if strings ${BYNAME}/MISC | grep -q "wipe_data"; then
    dd if=/dev/zero of=${BYNAME}/MISC
fi

PROTECTED="lk tee1 tee2"

for part in ${PROTECTED}; do
    [ -e ${BYNAME}/${part} ] || continue

    real=$(readlink -f ${BYNAME}/${part})

    rm -f ${BYNAME}/${part}
    [ -n "${real}" ] && ln -s "${real}" ${BYNAME}/${part}_real
    ln -s /dev/null ${BYNAME}/${part}
done

# We flash our recovery to swdl, so point recovery at it
if [ -e ${BYNAME}/swdl ]; then
    real=$(readlink -f ${BYNAME}/swdl)

    rm -f ${BYNAME}/recovery
    [ -n "${real}" ] && ln -s "${real}" ${BYNAME}/recovery
fi
