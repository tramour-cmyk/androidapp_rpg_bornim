import sys
from PIL import Image
ims=[Image.open(p).convert('RGBA') for p in sys.argv[2:]]
h=max(i.height for i in ims); W=sum(i.width for i in ims)+10*len(ims)
bg=Image.new('RGBA',(W,h),(120,128,110,255)); x=0
for i in ims: bg.alpha_composite(i,(x,0)); x+=i.width+10
bg.convert('RGB').save(sys.argv[1])
