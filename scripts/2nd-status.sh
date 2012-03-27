#!/bin/zsh
#
# xmonad statusline, (c) 2007 by Robert Manea
#
 
# Configuration
DATE_FORMAT='%A, %d.%m.%Y %H:%M:%S'
TIME_ZONES=(Australia/Sydney America/Los_Angeles America/New_York)
WEATHER_FORECASTER=/path/to/dzenWeather.pl
DZEN_ICONPATH=/home/aschmitt/.xmonad/icons
#MAILDIR=
 
# Main loop interval in seconds
INTERVAL=1
 
# function calling intervals in seconds
DATEIVAL=1
NPIVAL=1
GTIMEIVAL=60
MAILIVAL=60
CPUTEMPIVAL=1
WEATHERIVAL=1800
VOLIVAL=2
CRIT="#d74b73"
BAR_FG="#60a0c0"
BAR_BG="#363636"
BIGBAR_W=60
BAR_H=8
 
# Functions
fdate() {
    date +$DATE_FORMAT
}
 
fgtime() {
    local i
 
    for i in $TIME_ZONES
        { print -n "${i:t}:" $(TZ=$i date +'%H:%M')' ' }
}
 
fcputemp() {
   print -n ${(@)$(</proc/acpi/thermal_zone/THRM/temperature)[2,3]}
}
 
fmail() {
    local -A counts; local i
 
    for i in "${MAILDIR:-${HOME}/Mail}"/**/new/*
        { (( counts[${i:h:h:t}]++ )) }
    for i in ${(k)counts}
        { print -n $i: $counts[$i]' ' }
}
 
fweather() {
   $WEATHER_FORECASTER
}

print_vol_info() {
    Perc=$(amixer get Master | grep "Mono:" | awk '{print $4}' | tr -d '[]%')
    Mute=$(amixer get Master | grep "Mono:" | awk '{print $6}')
    if [[ $Mute == "[off]" ]]; then
        print "^fg($COLOR_ICON)^i($DZEN_ICONPATH/volume_off.xbm) "
        print "^fg()off "
        print "$(echo $Perc | dzen2-gdbar -fg $CRIT -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -nonl)"
    else
        print "^fg($COLOR_ICON)^i($DZEN_ICONPATH/volume_on.xbm) "
        print "^fg()${Perc}% "
        print "$(echo $Perc | dzen2-gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BIGBAR_W  -nonl)"
    fi
}

get_now_playing() {
        local state
        local music
        local ptime
 
        print "$(cmus-remote -Q | /home/aschmitt/configs/cmus_status.pl $DZEN_ICONPATH)"
#        state=$(mocp --format "%state")
#        case $state in
#                PLAY)
#                    mocp --format "^fg(grey70)^i(${DZEN_ICONPATH}/mpd.xbm)^fg(grey50) %ct^fg(#803A38)^p(3)^i(${DZEN_ICONPATH}/play.xbm)^fg(grey50)^fg(#60B6EF) %artist - %song^fg()"
#                        ;;
#                PAUSE)
#                    mocp --format "^fg(grey70)^i(${DZEN_ICONPATH}/mpd.xbm)^fg(grey50) %ct^fg(#803A38)^p(3)^i(${DZEN_ICONPATH}/pause.xbm)^fg(grey50)^fg(#60B6EF) %artist - %song^fg()"
#                        ;;
#                STOP)
#                        print "^fg(grey40)^i(${DZEN_ICONPATH}/mpd.xbm)^fg(grey60) (^fg(#803A38)^p(2)^r(7x7)^p(2)^fg(grey60))"
#                        ;;
#        esac
 
}
 

[ -f /tmp/status_dzen.pid ] && { kill `cat /tmp/status_dzen.pid`; rm /tmp/status_dzen.pid; }
echo $$ > /tmp/status_dzen.pid

# Main
 
# initialize data
DATECOUNTER=$DATEIVAL;MAILCOUNTER=$MAILIVAL;GTIMECOUNTER=$GTIMEIVAL;CPUTEMPCOUNTER=$CPUTEMPIVAL;WEATHERCOUNTER=$WEATHERIVAL
 
while true; do
   if [ $DATECOUNTER -ge $DATEIVAL ]; then
     PDATE=$(fdate)
     DATECOUNTER=0
   fi
 
#   if [ $MAILCOUNTER -ge $MAILIVAL ]; then
#     TMAIL=$(fmail)
#       if [ $TMAIL ]; then
#         PMAIL="^fg(khaki)^i(${DZENICONPATH}/mail.xpm)^p(3)${TMAIL}"
#       else
#         PMAIL="^fg(grey60)^i(${DZENICONPATH}/envelope.xbm)"
#       fi
#     MAILCOUNTER=0
#   fi
 
   if [ $GTIMECOUNTER -ge $GTIMEIVAL ]; then
     PGTIME=$(fgtime)
     GTIMECOUNTER=0
   fi
 
   # if [ $NPCOUNTER -ge $NPIVAL ]; then
   #  NOW_PLAYING=$(get_now_playing)
   #  NPCOUNTER=0
   # fi

   # if [ $VOLCOUNTER -ge $VOLIVAL ]; then
   #  VOLUME=$(print_vol_info)
   #  VOLCOUNTER=0
   # fi

#   if [ $CPUTEMPCOUNTER -ge $CPUTEMPIVAL ]; then
#     PCPUTEMP=$(fcputemp)
#     CPUTEMPCOUNTER=0
#   fi
 
#   if [ $WEATHERCOUNTER -ge $WEATHERIVAL ]; then
#     PWEATHER=$(fweather)
#     WEATHERCOUNTER=0
#   fi
 
   # Arrange and print the status line
STUFF="$VOLUME $NOW_PLAYING         ^fg(white)${PDATE}^fg()"
[ "$OLDSTUFF" = "$STUFF" ] || { echo $STUFF; OLDSTUFF=$STUFF; }
 
   DATECOUNTER=$((DATECOUNTER+1))
   MAILCOUNTER=$((MAILCOUNTER+1))
   GTIMECOUNTER=$((GTIMECOUNTER+1))
   CPUTEMPCOUNTER=$((CPUTEMPCOUNTER+1))
   WEATHERCOUNTER=$((WEATHERCOUNTER+1))
   NPCOUNTER=$((NPCOUNTER+1))
   VOLCOUNTER=$((VOLCOUNTER+1))
 
   sleep $INTERVAL
done
