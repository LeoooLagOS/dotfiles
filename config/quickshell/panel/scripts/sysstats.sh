#!/usr/bin/env bash
# Prints one JSON line with system stats for the panel's System zone.

read -r _ u n s i w q sq st _ < /proc/stat
t1=$((u+n+s+i+w+q+sq+st)); i1=$((i+w))
sleep 0.4
read -r _ u n s i w q sq st _ < /proc/stat
t2=$((u+n+s+i+w+q+sq+st)); i2=$((i+w))
dt=$((t2-t1)); cpu=0; [ "$dt" -gt 0 ] && cpu=$(( (100 * (dt - (i2-i1))) / dt ))

mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_avail=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)

# CPU package temperature (coretemp), falling back to the first thermal zone
temp=0
for h in /sys/class/hwmon/hwmon*; do
  if [ "$(cat "$h/name" 2>/dev/null)" = "coretemp" ]; then temp=$(( $(cat "$h/temp1_input") / 1000 )); break; fi
done
[ "$temp" -eq 0 ] && [ -r /sys/class/thermal/thermal_zone0/temp ] && temp=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))

read -r disk_used disk_total < <(df -B1 --output=used,size / | tail -1)

bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
bat_status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
# Compact uptime: "3d 4h", "1h 44m", "12m"
up=$(cut -d. -f1 /proc/uptime); d=$((up/86400)); h=$((up%86400/3600)); m=$((up%3600/60))
if [ "$d" -gt 0 ]; then uptime="${d}d ${h}h"; elif [ "$h" -gt 0 ]; then uptime="${h}h ${m}m"; else uptime="${m}m"; fi

printf '{"cpu":%d,"memUsed":%d,"memTotal":%d,"temp":%d,"diskUsed":%d,"diskTotal":%d,"battery":%d,"batteryStatus":"%s","uptime":"%s"}\n' \
  "$cpu" $(( (mem_total-mem_avail)*1024 )) $((mem_total*1024)) "$temp" "$disk_used" "$disk_total" "${bat:-0}" "${bat_status:-Unknown}" "$uptime"
