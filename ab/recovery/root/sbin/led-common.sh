#!/sbin/sh

led_show() { :; }
[ -f /sbin/led.sh ] && . /sbin/led.sh

LED_COUNT=${LED_COUNT:-1}

LED_BLUE="0 128 255"
LED_PURPLE="136 102 255"
LED_RED="255 0 0"
LED_GREEN="0 255 0"
LED_WHITE="255 255 255"
LED_DIM="32 32 32"

LED_LAST=""

led_emit() {
    [ "$*" = "${LED_LAST}" ] && return 0
    LED_LAST="$*"
    led_show "$@"
}

led_fill() {
    _out=""; _i=0
    while [ ${_i} -lt ${LED_COUNT} ]; do
        _out="${_out} $1 $2 $3"
        _i=$((_i + 1))
    done
    led_emit ${_out}
}

led_arc() {
    _pct=$1; _t=$2; shift 2
    _on=$(((_pct * LED_COUNT + 99) / 100))

    _ph=$((_t % LED_BREATH_TICKS))
    [ ${_ph} -ge $((LED_BREATH_TICKS / 2)) ] && _ph=$((LED_BREATH_TICKS - _ph))
    _lvl=$((15 + (85 * _ph) / (LED_BREATH_TICKS / 2)))

    _out=""; _i=0
    while [ ${_i} -lt ${LED_COUNT} ]; do
        if [ ${_i} -lt ${_on} ]; then
            _out="${_out} $1 $2 $3"
        elif [ ${_i} -eq ${_on} ]; then
            _out="${_out} $(($1 * _lvl / 100)) $(($2 * _lvl / 100)) $(($3 * _lvl / 100))"
        else
            _out="${_out} 0 0 0"
        fi
        _i=$((_i + 1))
    done
    led_emit ${_out}
}

led_spin() {
    _t=$1; shift
    _r=$1; _g=$2; _b=$3
    _head=$((_t % LED_COUNT))
    _out=""; _i=0
    while [ ${_i} -lt ${LED_COUNT} ]; do
        _d=$(((_head - _i + LED_COUNT) % LED_COUNT))
        case ${_d} in
            0) _out="${_out} ${_r} ${_g} ${_b}" ;;
            1) _out="${_out} $((_r / 3)) $((_g / 3)) $((_b / 3))" ;;
            2) _out="${_out} $((_r / 8)) $((_g / 8)) $((_b / 8))" ;;
            *) _out="${_out} 0 0 0" ;;
        esac
        _i=$((_i + 1))
    done
    led_emit ${_out}
}

led_spin_opposed() {
    _t=$1; shift
    _head=$((_t % LED_COUNT))
    _far=$(((_head + LED_COUNT / 2) % LED_COUNT))
    _out=""; _i=0
    while [ ${_i} -lt ${LED_COUNT} ]; do
        if [ ${_i} -eq ${_head} ] || [ ${_i} -eq ${_far} ]; then
            _out="${_out} $1 $2 $3"
        else
            _out="${_out} 0 0 0"
        fi
        _i=$((_i + 1))
    done
    led_emit ${_out}
}

LED_BREATH_TICKS=16

led_breathe() {
    _t=$1; shift
    _ph=$((_t % LED_BREATH_TICKS))
    [ ${_ph} -ge $((LED_BREATH_TICKS / 2)) ] && _ph=$((LED_BREATH_TICKS - _ph))
    _lvl=$((25 + (150 * _ph) / LED_BREATH_TICKS))
    led_fill $(($1 * _lvl / 100)) $(($2 * _lvl / 100)) $(($3 * _lvl / 100))
}

led_mix() {
    _pct=$1
    _mr=$((($2 * (100 - _pct) + $5 * _pct) / 100))
    _mg=$((($3 * (100 - _pct) + $6 * _pct) / 100))
    _mb=$((($4 * (100 - _pct) + $7 * _pct) / 100))
}

LED_BLINK_TICKS=50
LED_HOLD_TICKS=80

led_blink_then_hold() {
    _t=$1; shift
    if [ ${_t} -ge ${LED_HOLD_TICKS} ]; then
        led_fill ${LED_DIM}
    elif [ ${_t} -lt ${LED_BLINK_TICKS} ] && [ $(((_t / 3) % 2)) -eq 1 ]; then
        led_fill 0 0 0
    else
        led_fill "$@"
    fi
}

led_render() {
    _s=$1; _p=${2:-0}; _t=${3:-0}
    case "${_s}" in
        boot)     led_spin_opposed "${_t}" ${LED_BLUE} ;;
        idle)     led_fill ${LED_DIM} ;;
        fsck)     led_fill ${LED_WHITE} ;;
        busy)
            if [ "${_p}" -gt 0 ] 2>/dev/null; then
                if [ ${LED_COUNT} -eq 1 ]; then
                    led_mix "${_p}" ${LED_BLUE} ${LED_GREEN}
                    led_breathe "${_t}" ${_mr} ${_mg} ${_mb}
                else
                    led_arc "${_p}" "${_t}" ${LED_BLUE}
                fi
            elif [ ${LED_COUNT} -eq 1 ]; then
                led_breathe "${_t}" ${LED_BLUE}
            else
                led_spin "${_t}" ${LED_BLUE}
            fi
            ;;
        sideload)
            if [ ${LED_COUNT} -eq 1 ]; then
                led_breathe "${_t}" ${LED_PURPLE}
            else
                led_spin "${_t}" ${LED_PURPLE}
            fi
            ;;
        success)  led_blink_then_hold "${_t}" ${LED_GREEN} ;;
        error)    led_blink_then_hold "${_t}" ${LED_RED} ;;
        *)        led_fill 0 0 0 ;;
    esac
}
