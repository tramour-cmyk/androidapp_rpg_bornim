cd /home/user/androidapp_rpg_bornim
OUT=$HOME/grak V3=$HOME/v3cc0 GERUEST=cc0 CC0=$HOME/cc0g CC0_RUHE=Grak_Lauer_Loop CC0_GEH=Grak_Pirsch_Loop CC0_HIEB=Grak_Hieb ART=hobgoblin_captain ~/bl/bin/python -I tools/blender348/goblin.py > ~/grak-bau.log 2>&1 || tail -30 ~/grak-bau.log
grep -h "GRAK_ARME\|BEWEGUNG" ~/grak/_hobgoblin_captain-hauptmann/rig.py.log | cut -c1-420
~/bl/bin/python -I tools/blender348/mess/haltung.py ~/grak/_hobgoblin_captain-hauptmann/held3-rig.blend 2>&1 | grep -E "^(Stehen|Gehen|Hieb)"
