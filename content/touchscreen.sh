#!/bin/bash
# utf-8
# 先通过lsusb/xinput/xrandr 等命令确定如下硬件信息:

# 前屏幕VID:PID和显示接口(16进制)
VIDF=093a
PIDF=2510
PORTF=eDP-1

# 后屏幕VID:PID和显示接口(16进制)
VIDB=093a
PIDB=2510
PORTB=eDP-1

# 先修改为10进制。如果xinput list-props [n] 的“Device Product ID”为16进制的，注释掉这四行
# 或者这里直接填写Device Product ID里面的结果，先VID后PID。
# 字母O，不是数字0
VIDF_O=$((16#$VIDF))
PIDF_O=$((16#$PIDF))
VIDB_O=$((16#$VIDB))
PIDB_O=$((16#$PIDB))

# =========自动处理步骤，请勿随意修改==========

for I in $(xinput list --id-only)
do
# 根据设备ID取其序号
    CUR_FIRST=$(xinput list-props $I|grep "Device Product ID"|awk -F : '{print $2}'|awk -F , '{print $1}'|awk '{print $1}')
    CUR_SECOND=$(xinput list-props $I|grep "Device Product ID"|awk -F : '{print $2}'|awk -F , '{print $2}'|awk '{print $1}')
# 前屏映射
    if [ "$VIDF_O" == "$CUR_FIRST" ] && [ "$PIDF_O" == "$CUR_SECOND" ];
    then
		  xinput map-to-output $I $PORTF
    fi
# 后屏映射
    if [ "$VIDB_O" == "$CUR_FIRST" ] && [ "$PIDB_O" == "$CUR_SECOND" ];
    then
		  xinput map-to-output $I $PORTB
    fi
done

exit 0
