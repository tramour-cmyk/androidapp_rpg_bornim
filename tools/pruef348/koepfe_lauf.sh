# 376.1 (Chef 19:40: gekauften Kopf anpassen, Form, Bart, Farbe, Haar) Kopfblatt, nach figuren_lauf.sh (braucht dessen Ablage).
# Je Zeile eine Kauffigur in unserer Kleidung (kauf_kleid.py, kopf.py), Standbilder (figurenprobe.gd --teil=koepfe), Blatt koepfe_blatt.py
# Aufruf: bash koepfe_lauf.sh [ablage]  -> <ablage>/aus/3761-koepfe.jpg
set -e
A=${1:-/home/user/q376}
O=$A/out; G=$A/godot; F=$A/figk; S=$A/aus
R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
K=$A/kauf/src
mkdir -p $F $S; rm -f $F/q_k*
# Kennung | Form | Haar | Bart | Haarfarbe | Haut | Stoppeln | Beschriftung
cat > $F/koepfe.txt <<'T'
q_k01|gekauft|Hair_SimpleParted||braun|mittel|0|Form: wie gekauft
q_k02|schmal|Hair_SimpleParted||braun|mittel|0|Form: schmal
q_k03|rund|Hair_SimpleParted||braun|mittel|0|Form: rund
q_k04|kantig|Hair_SimpleParted||braun|mittel|0|Form: kantig
q_k05|hager|Hair_SimpleParted||braun|mittel|0|Form: hager
q_k06|gekauft|Hair_SimpleParted|Hair_Beard,Hair_Moustache|braun|mittel|0|Bart: Voll + Schnurrbart
q_k07|gekauft|Hair_SimpleParted|Hair_Beard|braun|mittel|0|Bart: Kinnbart
q_k08|gekauft|Hair_SimpleParted|Hair_Moustache|braun|mittel|0|Bart: Schnurrbart
q_k09|gekauft|Hair_SimpleParted|Hair_MuttonChops|braun|mittel|0|Bart: Koteletten + Schnurrb.
q_k10|gekauft|Hair_SimpleParted|Hair_Beard,Hair_Moustache|grau|mittel|0|Bart: Voll, grau
q_k11|kantig|Hair_Buzzed|Hair_Beard|schwarz|gebraeunt|0|kurz, schwarz, gebräunt, Kinnb.
q_k12|schmal|Hair_Long||blond|hell|0|lang, blond, hell
q_k13|rund|Hair_Ponytail|Hair_MuttonChops|rot|mittel|0|Zopf, rot, Kotel.
q_k14|hager|Hair_Balding|Hair_Moustache|grau|warm|0|Halbglatze, grau, warm, Schnurrb.
q_k15|gekauft|Hair_SlickBack|Hair_Beard|dunkel|dunkel|0|Seiten kurz, dunkel, Kinnb.
T
while IFS='|' read k fo h b fa hu st t; do
  OUT=$O ZIEL=$F Q=~/cc0 KAUF=$K KOERPER=Regular_Male_FullBody KENNUNG=$k FORM=$fo HAAR=$h BART=$b FARBE=$fa HAUT=$hu STOPPELN=$st \
    $B -I $R/tools/blender348/v3/kauf_kleid.py 2>&1 | grep -E "Error|Trace" || true
  [ -f $F/$k.glb ] || { echo "FEHLT $k"; exit 1; }
done < $F/koepfe.txt
cp $R/godot/skripte/figurenprobe.gd $R/godot/skripte/kamera.gd $G/skripte/
UAL=$A/ual.glb
[ -f $UAL ] || cp "$(find $K/678371987 -path "*Unreal-Godot/UAL1.glb" | head -1)" $UAL
rm -rf $A/bild_koepfe; mkdir -p $A/bild_koepfe
cd $G
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json timeout 1200 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . \
  --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 -- --figuren=$A/bild_koepfe --quelle=$F --ual=$UAL --teil=koepfe \
  > $A/godot_koepfe.log 2>&1 || echo "godot $?"
grep -h "SCRIPT ERROR" $A/godot_koepfe.log | head -3 || true
python3 -I $R/tools/pruef348/koepfe_blatt.py $A/bild_koepfe $F/koepfe.txt $S/3761-koepfe.jpg
