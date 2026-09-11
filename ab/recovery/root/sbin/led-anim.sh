#!/sbin/sh

PATH=/sbin:/system/sbin:/system/bin:/system/xbin

. /sbin/led-common.sh

TICK_SECONDS=0.1

state=idle
progress=0
last=""
tick=0

while true; do
    [ -f /tmp/led.state ] && read state progress rest < /tmp/led.state
    state=${state:-idle}
    progress=${progress:-0}

    if [ "${state} ${progress}" != "${last}" ]; then
        [ "${state}" != "${last% *}" ] && tick=0
        last="${state} ${progress}"
    fi

    led_render "${state}" "${progress}" "${tick}"
    tick=$((tick + 1))

    sleep ${TICK_SECONDS}
done
