cd /home/user/androidapp_rpg_bornim
OUT=$HOME/kob V3=$HOME/v3cc0 GERUEST=cc0 CC0=$HOME/cc0k CC0_RUHE=Kobold_Lauer_Loop CC0_GEH=Kobold_Pirsch_Loop CC0_HIEB=Kobold_Hieb ART=kobold ~/bl/bin/python -I tools/blender348/goblin.py > ~/kob-bau.log 2>&1 || tail -30 ~/kob-bau.log
grep -E "GLB|FERTIG" ~/kob-bau.log | cut -c1-200
for k in kappe schild fell; do echo "== $k"; grep -h "BEWEGUNG" ~/kob/_kobold-$k/rig.py.log | cut -c1-200; ~/bl/bin/python -I tools/blender348/mess/haltung.py ~/kob/_kobold-$k/held3-rig.blend 2>&1 | grep -E "^(Stehen  0|Gehen  0|Hieb  7)"; done
