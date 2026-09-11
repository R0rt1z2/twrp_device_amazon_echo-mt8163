#!/sbin/sh

_tmp=/tmp/led.state.$$
echo "${1:-idle} ${3:-0} ${2:-none}" > ${_tmp}
mv ${_tmp} /tmp/led.state
