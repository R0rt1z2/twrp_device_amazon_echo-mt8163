#!/sbin/sh

LED_DEV=/sys/bus/i2c/devices/0-003f
LED_COUNT=12

led_show() {
    _frame=$(printf '%02x%02x%02x' "$@")
    echo "${_frame}" > ${LED_DEV}/frame
}
