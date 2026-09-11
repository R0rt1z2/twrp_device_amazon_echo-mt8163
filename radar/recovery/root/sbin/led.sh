#!/sbin/sh

LED_COUNT=12

ISSI_DEV=/sys/bus/i2c/devices/0-003f
LP55_SYSFS=/sys/class/leds

if [ -w ${ISSI_DEV}/frame ]; then
    led_show() {
        _frame=$(printf '%02x%02x%02x' "$@")
        echo "${_frame}" > ${ISSI_DEV}/frame
    }
else
    led_show() {
        _n=0
        while [ $# -ge 3 ]; do
            _chip=$((_n / 3))
            _base=$(((_n % 3) * 3))
            echo "$1" > ${LP55_SYSFS}/lp55231:${_chip}:channel${_base}/brightness
            echo "$2" > ${LP55_SYSFS}/lp55231:${_chip}:channel$((_base + 1))/brightness
            echo "$3" > ${LP55_SYSFS}/lp55231:${_chip}:channel$((_base + 2))/brightness
            shift 3
            _n=$((_n + 1))
        done
    }
fi
