import io, json
from PIL import Image, ImageDraw, ImageFont
O='/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/aldric/'
F=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',15); FS=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',10)
def jpg(img,p):
    for q in range(90,20,-3):
        b=io.BytesIO(); img.save(b,'JPEG',quality=q,optimize=True)
        if b.tell()<=60*1024: open(p,'wb').write(b.getvalue()); print(p,img.size,q,b.tell()); return
im=Image.open(O+'nah.png'); bg=Image.new('RGBA',im.size,(34,30,28,255)); bg.alpha_composite(im); jpg(bg.convert('RGB'),O+'aldric-nah.jpg')
ab={'nase_laenge':'NaseL','nase_breite':'NaseB','nase_kruemmung':'NaseK','kinn':'Kinn','wangen':'Wangen','augenabstand':'Augen','brauen':'Brauen','falten':'Falten','wangenknochen':'WKnochen','lider':'Lider','bart':'Bart','haar':'Haar'}
names={'aldric':'Ältester Aldric','jorin':'Wache Jorin','osric':'Bruder Osric'}
cells=[]
for w in ['aldric','jorin','osric']:
    k=Image.open(O+'k%s.png'%w); c=Image.new('RGBA',(k.width,k.height+80),(34,30,28,255)); c.alpha_composite(k)
    d=ImageDraw.Draw(c); d.text((c.width/2-d.textlength(names[w],font=F)/2,k.height+4),names[w],fill=(225,200,140),font=F)
    r=json.load(open(O+'%s-regler.json'%w)); items=['%s %+.1f'%(ab[x],v) for x,v in r.items()]
    for i in range(4): d.text((8,k.height+24+i*13),'   '.join(items[i*3:i*3+3]),fill=(200,195,185),font=FS)
    cells.append(c.convert('RGB'))
W=sum(c.width for c in cells)+8*4; s=Image.new('RGB',(W,cells[0].height+16),(18,16,20)); x=8
for c in cells: s.paste(c,(x,8)); x+=c.width+8
jpg(s,O+'drei-koepfe.jpg')
