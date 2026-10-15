# 80a: drei Entwürfe für Kaels Familienzeichen (Messing, über der Tür in Aschfurt, auf der Laterne); Aufruf: python3 -I tools/entwurf/80a_zeichen.py, schreibt 80a_zeichen.png ins aktuelle Verzeichnis
import math, random
from PIL import Image, ImageDraw, ImageFilter, ImageFont
def arc(cx,cy,r,a0,a1,n=40): return [(cx+r*math.cos(math.radians(a0+(a1-a0)*k/n)),cy+r*math.sin(math.radians(a0+(a1-a0)*k/n))) for k in range(n+1)]
MARKS={
 'A':("Raute mit Balken",[[(0,-1),(0.72,0),(0,1),(-0.72,0),(0,-1)],[(-0.98,0),(0.98,0)]]),
 'B':("Laterne am Haken",[arc(0,-0.82,0.16,0,360,30),[(-0.42,-0.42),(0,-0.66),(0.42,-0.42),(-0.42,-0.42)],[(-0.34,-0.42),(-0.34,0.62),(0.34,0.62),(0.34,-0.42)],[(0,-0.3),(0,0.5)],[(-0.46,0.8),(0.46,0.8)]]),
 'C':("Mühlrad",[arc(0,0,0.68,0,360,90),arc(0,0,0.12,0,360,20)]+[[(0.12*math.cos(a),0.12*math.sin(a)),(0.68*math.cos(a),0.68*math.sin(a))] for a in [k*math.pi/3+math.pi/6 for k in range(6)]]+[[(0.68*math.cos(a),0.68*math.sin(a)),(1.0*math.cos(a),1.0*math.sin(a))] for a in [k*math.pi/4 for k in range(8)]]),
}
def draw_mark(d,key,cx,cy,s,w,col):
    for pl in MARKS[key][1]:
        pts=[(cx+x*s,cy+y*s) for x,y in pl]
        d.line(pts,fill=col,width=w,joint='curve')
        for p in (pts[0],pts[-1]): d.ellipse([p[0]-w/2,p[1]-w/2,p[0]+w/2,p[1]+w/2],fill=col)
SS=3
def panel_brass(key):
    W=340; im=Image.new('RGB',(W*SS,W*SS),(0x24,0x22,0x1F)); d=ImageDraw.Draw(im)
    # iron plate with rivets
    d.rounded_rectangle([20*SS,20*SS,(W-20)*SS,(W-20)*SS],12*SS,fill=(0x2E,0x2A,0x26),outline=(0x18,0x16,0x14),width=3*SS)
    for x,y in [(40,40),(W-40,40),(40,W-40),(W-40,W-40)]: d.ellipse([(x-6)*SS,(y-6)*SS,(x+6)*SS,(y+6)*SS],fill=(0x3A,0x35,0x30))
    c=W/2*SS; s=105*SS
    draw_mark(d,key,c+3*SS,c+3*SS,s,22*SS,(0x14,0x12,0x10))      # shadow
    draw_mark(d,key,c,c,s,22*SS,(0x8A,0x70,0x34))                 # brass
    draw_mark(d,key,c-2*SS,c-2*SS,s,8*SS,(0xB8,0x98,0x52))        # highlight
    return im.resize((W,W),Image.LANCZOS)
def panel_door(key,seed):
    W=340; rnd=random.Random(seed); im=Image.new('RGB',(W*SS,W*SS),(0x14,0x12,0x10)); d=ImageDraw.Draw(im)
    # wall plaster above, lintel beam, door top
    d.rectangle([0,0,W*SS,W*SS],fill=(0x6A,0x60,0x52))
    d.rectangle([0,90*SS,W*SS,250*SS],fill=(0x4A,0x36,0x24))      # lintel
    for k in range(40):
        y=rnd.uniform(92,248)*SS; d.line([(0,y),(W*SS,y+rnd.uniform(-6,6)*SS)],fill=(0x40,0x2E,0x1E),width=SS)
    d.rectangle([60*SS,250*SS,280*SS,W*SS],fill=(0x2A,0x20,0x16))  # door
    c=W/2*SS; cy=170*SS; s=62*SS
    draw_mark(d,key,c+2*SS,cy+2*SS,s,13*SS,(0x6E,0x56,0x3A))      # carved edge light
    draw_mark(d,key,c,cy,s,13*SS,(0x22,0x18,0x10))                # carved groove
    # soot rising from the left, half covers the mark
    soot=Image.new('L',im.size,0); sd=ImageDraw.Draw(soot)
    for k in range(260):
        x=rnd.uniform(-40,190)*SS; y=rnd.uniform(0,W)*SS; r=rnd.uniform(20,60)*SS
        a=int(max(0,1-x/(230*SS))*rnd.uniform(120,230)); sd.ellipse([x-r,y-r,x+r,y+r],fill=a)
    soot=soot.filter(ImageFilter.GaussianBlur(25*SS))
    im=Image.composite(Image.new('RGB',im.size,(0x10,0x0C,0x0A)),im,soot)
    # empty hook right of the door
    d=ImageDraw.Draw(im); hx=300*SS; hy=280*SS
    d.line([(hx,hy),(hx+16*SS,hy)],fill=(0x1A,0x18,0x16),width=5*SS)
    d.arc([hx+8*SS,hy,hx+26*SS,hy+22*SS],270,180,fill=(0x1A,0x18,0x16),width=5*SS)
    return im.resize((W,W),Image.LANCZOS)
def panel_tiny(key):
    # front pane of the lantern in the game: about 11 x 15 pixels, brass on brown horn
    pw,ph=11,15; im=Image.new('RGB',(pw*SS*8,ph*SS*8),(0x4E,0x3C,0x26)); d=ImageDraw.Draw(im)
    s=4.2*SS*8; draw_mark(d,key,pw*SS*4,ph*SS*4,s,int(1.3*SS*8),(0x8A,0x70,0x34))
    small=im.resize((pw,ph),Image.LANCZOS); big=small.resize((pw*14,ph*14),Image.NEAREST)
    out=Image.new('RGB',(340,340),(0x1A,0x18,0x16)); out.paste(big,((340-pw*14)//2,(340-ph*14)//2)); return out
f=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf',22)
f2=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf',17)
sheet=Image.new('RGB',(3*360+20,3*360+120),(0x10,0x10,0x14)); d=ImageDraw.Draw(sheet)
for col,lab in enumerate(["Messing (Vorlage)","über der Tür in Aschfurt, halb verrußt","auf der Laterne im Spiel (Pixel, vergrößert)"]):
    d.text((20+col*360,10),lab,font=f2,fill=(0xEB,0xE1,0xC8))
for row,key in enumerate("ABC"):
    y=40+row*360
    for col,p in enumerate([panel_brass(key),panel_door(key,row),panel_tiny(key)]): sheet.paste(p,(20+col*360,y))
    d.text((20,y+342-24),f"{key}  {MARKS[key][0]}",font=f,fill=(0xD8,0xB8,0x6A))
sheet.save('80a_zeichen.png'); print('ok')
