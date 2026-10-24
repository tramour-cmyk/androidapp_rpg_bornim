import json, io, numpy as np
from PIL import Image, ImageDraw, ImageFilter
O='/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/'
fig=Image.open(O+'st.png'); meta=json.load(open(O+'passes/st/meta.json'))
fw,fh=fig.size; S=2
W,Hh=560,700; fx,fy=230,30
tx=fx+meta['torch_uv'][0]*fw; ty=fy+(1-meta['torch_uv'][1])*fh; gx=tx; gy=fy+(1-meta['torch_ground_uv'][1])*fh
img=Image.new('RGB',(W*S,Hh*S)); d=ImageDraw.Draw(img)
import numpy as _np
FEET=fy+int(_np.where(_np.array(fig)[...,3].max(1)>10)[0].max())
horizon=FEET-110
for y in range(Hh*S):
    t=y/(Hh*S); c=(int(12+8*t),int(15+9*t),int(28+10*t)); d.line([(0,y),(W*S,y)],fill=c)
# Mauer hinten (dunkel, kuehl), Boden mit Pflaster
d.rectangle((0,0,W*S,horizon*S),fill=(20,24,38))
rng=np.random.default_rng(3)
y=horizon
while y<Hh+20:
    k=(y-horizon)/(Hh-horizon); ry=3+7*k; rx=ry*2.2
    x=-rng.random()*rx*2
    while x<W+rx:
        cx=x+rng.random()*3; cy=y+rng.random()*2
        dist=np.hypot((cx-gx)/1.0,(cy-gy)*2.6)
        f=np.exp(-dist/95.0)
        base=np.array([58,60,70])*(0.55+0.3*rng.random())
        c=base*(0.22)+np.array([255,150,70])*f*0.6*(0.8+0.3*rng.random())
        d.ellipse(((cx-rx*0.9)*S,(cy-ry*0.8)*S,(cx+rx*0.9)*S,(cy+ry*0.8)*S),fill=tuple(int(min(255,v)) for v in c),outline=(10,9,12),width=S)
        x+=rx*2
    y+=ry*1.25
img=img.resize((W,Hh),Image.LANCZOS).convert('RGBA')
# Lichtschein der Fackel (Abfall)
gl=Image.new('L',(W,Hh),0); dg=ImageDraw.Draw(gl)
for r in range(260,0,-6):
    dg.ellipse((tx-r,ty-r*0.9,tx+r,ty+r*0.9),fill=int(110*(1-r/260)**2))
img=Image.composite(Image.new('RGBA',(W,Hh),(255,150,60,255)),img,gl.filter(ImageFilter.GaussianBlur(8)))
# Schatten der Figur vom Licht weg
sh=Image.new('L',(W,Hh),0); ds=ImageDraw.Draw(sh); feet=FEET-2
ds.polygon([(fx+fw*0.3,feet-4),(fx+fw*0.75,feet-4),(fx+fw*1.7,feet-22),(fx+fw*1.35,feet-30)],fill=150)
ds.ellipse((fx+fw*0.2,feet-9,fx+fw*0.85,feet+7),fill=220)
img=Image.composite(Image.new('RGBA',(W,Hh),(6,6,10,255)),img,sh.filter(ImageFilter.GaussianBlur(4)))
# Fackel: Stab mit Flamme, im Boden
d=ImageDraw.Draw(img)
d.line([(gx,gy),(tx,ty+8)],fill=(30,20,14),width=7); d.line([(gx,gy),(tx,ty+8)],fill=(92,60,36),width=4)
d.polygon([(tx-7,ty+10),(tx,ty-34),(tx+3,ty-18),(tx+8,ty-26),(tx+7,ty+10)],fill=(240,120,30),outline=(20,12,8))
d.polygon([(tx-3,ty+8),(tx,ty-18),(tx+4,ty+8)],fill=(255,220,120))
img.alpha_composite(fig,(fx,fy))
# Mond
d=ImageDraw.Draw(img); d.ellipse((W-80,26,W-44,62),fill=(222,226,214),outline=(16,16,22),width=2)
d.text((10,Hh-20),'Licht: Fackel',fill=(225,200,140))
out=img.convert('RGB')
for q in range(90,20,-3):
    b=io.BytesIO(); out.save(b,'JPEG',quality=q,optimize=True)
    if b.tell()<=60*1024: open(O+'stilisiert.jpg','wb').write(b.getvalue()); print(q,b.tell()); break
