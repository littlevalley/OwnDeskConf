#!/bin/bash
res=$(acpi -b)
res=${res%,*}
res=${res##*:}
state=${res%,*}
e_life=${res##*,}
e_life=${e_life%\%*}
state=$(echo $state | sed s/[[:space:]]//g)
e_life=$(echo $e_life| sed s/[[:space:]]//g)
#echo $e_life
if [ "$e_life" == "Full" ];then
        e_life=100
fi
if [ "$state" == "Discharging"  -a  $(echo "$e_life<15" | bc -l) -eq 1 ];then
	mpg123 ~/.fvwm/sounds/no-power.mp3
fi
echo $state" "${e_life}%
if [ $(echo "$e_life<3" | bc -l) -eq 1 ]; then
	sudo s2ram
fi
