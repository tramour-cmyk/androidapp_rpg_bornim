# 348.13a: Stärken im selben Augenblick, Magenta zaehlen. Aufruf: REIHE=1.0,1.3 bash tusche_probe.sh [ablage]
# 348.13a: Kampfort Goblins, Stärken des Umrisses im selben Augenblick, je normal und magenta
set -e
O=${1:-/home/user/kprobe}; mkdir -p $O
cd /home/user/k34813/godot
TUSCHE=licht TUSCHE_REIHE=${REIHE:-1.0,1.6,2.2,3.0} GEGNER=GOBLINS OHNEUI=1 VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json \
  timeout 600 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . --rendering-driver vulkan --rendering-method mobile \
  --resolution 1080x2340 -- --bild=$O/gob.png > $O/godot.log 2>&1 || true
grep -E "SCRIPT ERROR|SHADER ERROR|^Bild" $O/godot.log | head
python3 - $O <<'PY'
import sys,glob,numpy as np
from PIL import Image
for f in sorted(glob.glob(sys.argv[1]+'/gob-*-m.png')):
    a=np.asarray(Image.open(f).convert('RGB')).astype(int)
    m=(a[...,0]-a[...,1]>50)&(a[...,2]-a[...,1]>50)
    print(f.split('/')[-1], int(m.sum()))
PY
