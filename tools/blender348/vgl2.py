import io, numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
O='/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/'
B='/home/user/bornim-main/docs/chefsache/bilder/'
F=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',15)
def bbox(im):
    a=np.array(im)[...,3]; r=np.where(a.max(1)>8)[0]; c=np.where(a.max(0)>8)[0]; return c.min(),r.min(),c.max(),r.max()
def save_jpg(img,path):
    for q in range(90,20,-3):
        buf=io.BytesIO(); img.save(buf,'JPEG',quality=q,optimize=True)
        if buf.tell()<=60*1024: open(path,'wb').write(buf.getvalue()); return q,buf.tell()
def sheet(cols,path,scale):
    cols=[(c.resize((c.width*scale,c.height*scale),Image.NEAREST) if scale>1 else c,l) for c,l in cols]
    Hc=cols[0][0].height; W=sum(c.width for c,_ in cols)+10*(len(cols)+1)
    v=Image.new('RGB',(W,Hc+34),(18,16,20)); d=ImageDraw.Draw(v); x=10
    for c,l in cols:
        v.paste(c,(x,8)); tw=d.textlength(l,font=F); d.text((x+(c.width-tw)/2,Hc+13),l,fill=(220,200,140),font=F); x+=c.width+10
    v.save(path.replace('.jpg','.png')); print(path, v.size, save_jpg(v,path))
def place(fig,bg,cx,feet,h):
    x0,y0,x1,y1=bbox(fig); f=fig.crop((x0,y0,x1+1,y1+1))
    s=h/f.height; f=f.resize((max(1,round(f.width*s)),h),Image.LANCZOS)
    bg=bg.convert('RGBA')
    sh=Image.new('L',bg.size,0); dd=ImageDraw.Draw(sh); rx=f.width*0.33; ry=rx*0.3
    dd.ellipse((cx-rx,feet-ry,cx+rx,feet+ry),fill=150); sh=sh.filter(ImageFilter.GaussianBlur(2))
    bg=Image.composite(Image.new('RGBA',bg.size,(12,10,8,255)),bg,sh)
    bg.alpha_composite(f,(round(cx-f.width/2),feet-h)); return bg.convert('RGB')
# 1) Karte: gleicher Ausschnitt 140x200, Figur 168 px, aus 348-2-ausschnitt
src=Image.open(B+'348-2-ausschnitt.jpg').convert('RGB')
heute=src.crop((120,121,260,321)); tusche=src.crop((525,121,665,321))
ground=src.crop((0,215,140,415))   # Boden gleich daneben aus demselben Bild (ohne Figur)
bl=place(Image.open(O+'kv2.png'),ground,70,184,168)
sheet([(heute,'heute'),(tusche,'mit Tusche (348.2)'),(bl,'Blender v2')],O+'vergleich-v2.jpg',2)
# 2) nah: naechste Ausschnitte (348-2-held, zweifach) neben Blender nah, gleiche Figurhoehe
src2=Image.open(B+'348-2-held.jpg').convert('RGB')
h2=src2.crop((60,30,330,391)); t2=src2.crop((460,30,730,391))
nah=Image.open(O+'v2n.png'); x0,y0,x1,y1=bbox(nah)
# Figurhoehe in 348-2-held: Helm ~45 bis Fuesse ~380 -> 335 px; Ausschnitt 361 hoch, Fuesse bei 350
g2=Image.new('RGB',(270,361),(40,36,30))
gnd=src2.crop((20,30,290,391)).filter(ImageFilter.GaussianBlur(0))
bn=place(nah,Image.open(B+'348-2-ausschnitt.jpg').convert('RGB').crop((2,200,137,380)).resize((270,361),Image.NEAREST),135,350,335)
sheet([(h2,'heute (zweifach)'),(t2,'mit Tusche (zweifach)'),(bn,'Blender v2 nah (verkleinert)')],O+'tmp-nah.jpg',1)
top=Image.open(O+'tmp-nah.png')
gr=Image.open(B+'348-2-ausschnitt.jpg').convert('RGB').crop((2,200,137,380)).resize((270,300),Image.NEAREST)
def small(p, night=False):
    f=Image.open(O+p)
    bgi=Image.new('RGB',(270,300),(14,17,30)) if night else gr
    return place(f,bgi,135,290,270)
row=[(small('v2n0.png'),'neu (Abnutzung 0)'),(small('v2n.png'),'gebraucht (0,7)'),(small('v2t.png',True),'Licht: Fackel')]
W=max(top.width, sum(c.width for c,_ in row)+40); v=Image.new('RGB',(W,top.height+300+40),(18,16,20)); v.paste(top,(0,0))
d=ImageDraw.Draw(v); x=10
for c,l in row:
    v.paste(c,(x,top.height+4)); tw=d.textlength(l,font=F); d.text((x+(c.width-tw)/2,top.height+308),l,fill=(220,200,140),font=F); x+=c.width+10
v.save(O+'vergleich-nah-v2.png'); print('nah-v2', v.size, save_jpg(v,O+'vergleich-nah-v2.jpg'))
