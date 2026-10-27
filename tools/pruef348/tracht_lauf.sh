# 376.1 (Chef 15:23) Kauffigur in unserer Kleidung, nach figuren_lauf.sh (braucht dessen Ablage: out/held3-rig.blend, godot/).
# Baut q_tracht (schmal, ohne Bart), _b (mit Bart), _r (rund), _rb (rund mit Bart) mit kauf_kleid.py, dazu q_held zum Vergleich,
# Standbilder (figurenprobe.gd --teil=tracht) und Film (--teil=trachtfilm) -> <ablage>/aus/3761-tracht-*
# Ohne Kaufteile (KAUF leer): freier Koerper Superhero_Male_FullBody mit dessen Kopf. Aufruf: bash tracht_lauf.sh [ablage]
set -e
A=${1:-/home/user/q376}
O=$A/out; G=$A/godot; F=$A/fig; S=$A/aus
R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
K=; [ -n "$(ls -A $A/kauf/src 2>/dev/null)" ] && K=$A/kauf/src
KOPF=; [ -n "$K" ] && KOPF=Regular_Male_OnlyHead
mkdir -p $F $S
for v in "q_tracht:1.0:" "q_tracht_b:1.0:Hair_Beard" "q_tracht_r:1.12:" "q_tracht_rb:1.12:Hair_Beard"; do
  IFS=: read k r b <<< "$v"
  OUT=$O ZIEL=$F Q=~/cc0 KAUF=$K KOPF=$KOPF KENNUNG=$k RUND=$r BART=$b $B -I $R/tools/blender348/v3/kauf_kleid.py 2>&1 | grep -E "KAUFKLEID|HINAUS|VERDECKT|Error"
done
[ -f $F/q_held.glb ] || Q=~/cc0 KAUF=$K OUT=$F FIGUREN=q_held $B -I $R/tools/blender348/v3/quaternius.py | grep -E "FIGUR|FEHLT"
cp $R/godot/skripte/figurenprobe.gd $G/skripte/
UAL=$(find $A/kauf/src/678371987 -path "*Unreal-Godot/UAL1.glb" 2>/dev/null | head -1)
[ -n "$UAL" ] || UAL=$(find ~/cc0/universal-animation-library -name "UAL1_Standard.glb" | head -1)
cp "$UAL" $A/ual.glb; UAL=$A/ual.glb   # Pfad ohne Leerzeichen (Godot-Argumente)
cd $G
for t in tracht trachtfilm; do rm -rf $A/bild_$t; mkdir -p $A/bild_$t
  (VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json timeout 2400 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . \
    --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 -- --figuren=$A/bild_$t --quelle=$F --ual=$UAL --teil=$t \
    > $A/godot_$t.log 2>&1; echo "$t fertig $?") &
done
wait
grep -h "SCRIPT ERROR" $A/godot_tracht*.log | head -3 || true
python3 -I $R/tools/pruef348/figuren_film.py $A/bild_trachtfilm/film $S/3761-tracht-film.mp4
