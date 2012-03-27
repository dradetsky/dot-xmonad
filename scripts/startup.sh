exec trayer \
    --monitor 1 \
    --height 16  --heighttype pixel \
    --width 120 --widthtype pixel \
    --align right \
    --edge top \
    --transparent yes \
    --alpha 0 \
    --tint 0x0 &
exec nm-applet &
