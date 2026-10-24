import json, io
from PIL import Image, ImageDraw, ImageFilter
O='/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/'
def jpg(img,p):
    for q in range(90,20,-3):
        b=io.BytesIO(); img.save(b,'JPEG',quality=q,optimize=True)
        if b.tell()<=60*1024: open(p,'wb').write(b.getvalue()); print(p,img.size,q,b.tell()); return
im=Image.open(O+'stk.png'); m=json.load(open(O+'passes/stk/meta.json'))
bg=Image.new('RGBA',im.size,(0,0,0,255)); bg.alpha_composite(im)
x=m['torch_uv'][0]*im.width; y=(1-m['torch_uv'][1])*im.height
gl=Image.new('L',im.size,0); d=ImageDraw.Draw(gl)
for r in range(40,0,-3): d.ellipse((x-r,y-r,x+r,y+r),fill=int(200*(1-r/40)**2))
bg=Image.composite(Image.new('RGBA',im.size,(255,190,90,255)),bg,gl.filter(ImageFilter.GaussianBlur(3)))
d=ImageDraw.Draw(bg); d.rectangle((x-3,y-3,x+3,y+3),fill=(255,236,170))
im2=bg.convert('RGB').resize((im.width*2,im.height*2),Image.LANCZOS)
jpg(im2,O+'stilisiert-karte.jpg')
