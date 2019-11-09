#!/bin/sh
state=$(sudo sysctl hw.acpi.acline)
state=${state#*\:}
e_life=$(sudo sysctl hw.acpi.battery.life)
e_life=${e_life#*\:}
res=$(echo "scale=3;$e_life" | bc -l)
if [ "$state" = "0" -a  $(echo "$res<0.15" | bc -l) -eq 1 ];then
	mpg123 ~/.fvwm/sounds/no-power.mp3
	state="Discharging"
else
	state="Charging"
fi
res=$(echo "$res * 100" | bc)
echo $state"  "${res%00}%
if [ $(echo "$res<0.3" | bc -l) -eq 1 ]; then
	sudo s2ram
fi
