import numpy as np, sys
from PIL import Image, ImageDraw
from scipy import ndimage as nd
rng=np.random.default_rng(7)
d=np.load(sys.argv[1]); img=d['img'].copy(); LIT=d['LIT']; ZM=d['ZM']; MAT=d['MAT']; mask=d['mask']; names=list(d['names'])
H,W,_=img.shape; SS=2; OW,OH=W//SS,H//SS
CX,CY=OW*0.5,OH*0.44; SC=0.85
YAW=np.radians(16.0); PITCH=np.radians(-4.0)
cy_,sy_=np.cos(YAW),np.sin(YAW); cp,sp=np.cos(PITCH),np.sin(PITCH)
R=np.array([[cy_,0,sy_],[0,1,0],[-sy_,0,cy_]])@np.array([[1,0,0],[0,cp,-sp],[0,sp,cp]])
def pr(p):
    w=R@(np.array(p,float)*SC); return ((CX+w[0])*SS,(CY-w[1])*SS)
def bez(a,b,c,n=24):
    t=np.linspace(0,1,n)[:,None]; a,b,c=[np.array(v,float).reshape(-1) for v in (a,b,c)]; return (1-t)**2*a+2*(1-t)*t*b+t*t*c
M=lambda k: MAT==names.index(k)
litS=nd.gaussian_filter(LIT,3*SS)
INK=np.array([0.05,0.03,0.035])
# ---- 2D features painted into a layer
lay=Image.fromarray((np.clip(img,0,1)*255).astype('uint8'))
dr=ImageDraw.Draw(lay,'RGBA')
def col(c,a=255): return tuple(int(255*np.clip(x,0,1)) for x in c)+(a,)
def stroke(pts,w0,w1,c,a=255,wmid=None):
    pts=[tuple(p) for p in pts]; n=len(pts)
    for i in range(n-1):
        t=i/(n-1); w=w0+(w1-w0)*t if wmid is None else (w0+(wmid-w0)*2*t if t<.5 else wmid+(w1-wmid)*(2*t-1))
        dr.line([pts[i],pts[i+1]],fill=col(c,a),width=max(1,int(round(w))))
        r=w/2; dr.ellipse([pts[i+1][0]-r,pts[i+1][1]-r,pts[i+1][0]+r,pts[i+1][1]+r],fill=col(c,a))
def litat(x,y): return float(litS[int(np.clip(y,0,H-1)),int(np.clip(x,0,W-1))])
# eyes: recolour eyeball outside the almond as lid skin
eyeM=M('eyes'); skinA=np.array([0.80,0.56,0.42]); eyeA=np.array([0.86,0.82,0.76])
gz=R.T@np.array([0.05,0.02,1.0]); gz/=np.linalg.norm(gz)
alm=Image.new('L',(W,H),0); ad=ImageDraw.Draw(alm)
eyes=[]
for s in(-1,1):
    ic=(s*18,1,74); oc=(s*43,5,64)
    up=bez([pr(ic)],[pr((s*29,15,82))],[pr(oc)])
    lo=bez([pr(ic)],[pr((s*31,-6,79))],[pr(oc)])
    ad.polygon([tuple(p) for p in np.vstack([up,lo[::-1]])],fill=255)
    eyes.append((s,up,lo))
almA=np.array(alm)>0
out=eyeM&~almA
img2=np.array(lay).astype(float)/255
img2[out]=img2[out]*(skinA/eyeA)
# whites darker below upper lid (lid shadow) and towards the corners
lay=Image.fromarray((np.clip(img2,0,1)*255).astype('uint8')); dr=ImageDraw.Draw(lay,'RGBA')
for s,up,lo in eyes:
    c=np.array((s*30,3,66))+np.array([14,10,14])*gz
    cx,cy=pr(c); r=6.2*SC*SS
    lv=litat(cx,cy+4)
    # clip iris to almond
    irl=Image.new('RGBA',(W,H),(0,0,0,0)); idr=ImageDraw.Draw(irl)
    base=np.array([0.50,0.34,0.18])*(0.35+0.9*lv)
    idr.ellipse([cx-r*0.92,cy-r,cx+r*0.92,cy+r],fill=col(base))
    idr.ellipse([cx-r*0.5,cy-r*0.15,cx+r*0.6,cy+r*0.85],fill=col(base*1.35+0.05,150))
    idr.ellipse([cx-r*0.42,cy-r*0.45,cx+r*0.42,cy+r*0.45],fill=col((0.03,0.02,0.02)))
    idr.ellipse([cx-r*0.95,cy-r*1.0,cx+r*0.95,cy-r*0.25],fill=col((0.05,0.03,0.03),110))  # lid shadow on iris
    idr.ellipse([cx-r*0.62-2.2,cy+r*0.28-2.2,cx-r*0.62+2.2,cy+r*0.28+2.2],fill=col((1.0,0.85,0.6)))
    idr.ellipse([cx+r*0.25-1.2,cy-r*0.35-1.2,cx+r*0.25+1.2,cy-r*0.35+1.2],fill=col((0.9,0.8,0.7),180))
    a=np.array(irl); a[...,3]=np.where(almA,a[...,3],0); irl=Image.fromarray(a)
    lay=Image.alpha_composite(lay.convert('RGBA'),irl).convert('RGB'); dr=ImageDraw.Draw(lay,'RGBA')
    # upper lid (thick, tapered), lower lid fine, crease fine
    upx=np.vstack([up, up[-1]+(up[-1]-up[-3])*0.8])
    stroke(upx,1.5*SS,1.0*SS,INK,255,wmid=2.6*SS)
    stroke(lo[6:-3],0.4*SS,0.4*SS,INK*2+0.15,90)
    cr=bez([pr((s*20,9,78))],[pr((s*30,20,82))],[pr((s*42,11,67))])
    stroke(cr,0.4*SS,0.4*SS,INK,150,wmid=0.9*SS)
    # brow: a heavy wedge, inner end low (frown)
    top=bez([pr((s*8,17,84))],[pr((s*26,30,86))],[pr((s*52,21,64))])
    bot=bez([pr((s*12,10,84))],[pr((s*28,17,86))],[pr((s*52,17,64))])
    bc=np.array([0.13,0.08,0.05])
    dr.polygon([tuple(p) for p in np.vstack([top,bot[::-1]])],fill=col(bc))
    for i in range(16):
        t=rng.uniform(0.05,0.9); j=int(t*23)
        p0=bot[j]+(top[j]-bot[j])*rng.uniform(0.1,0.5); p1=top[min(23,j+3)]+(rng.normal(0,1.5),rng.normal(0,1.5))
        stroke([p0,p1],0.6*SS,0.3*SS,bc*2.4+np.array([0.15,0.07,0.0])*litat(*p0),170)
    stroke(top,0.4*SS,0.4*SS,INK,200,wmid=1.0*SS)
    # crow's feet
    for k in(-1,0,1):
        stroke([pr((s*46,4+k*5,62)),pr((s*55,4+k*8,52))],0.6*SS,0.2*SS,INK,90)
# nose: shadow-side bridge line, nostril wings, tip
stroke(bez([pr((7,12,78))],[pr((10,-6,90))],[pr((9,-22,100))]),0.3*SS,0.9*SS,INK,150)
for s in(-1,1):
    stroke(bez([pr((s*4,-35,97))],[pr((s*19,-38,90))],[pr((s*20,-24,84))]),0.9*SS if s>0 else 0.6*SS,0.3*SS,INK,230)
stroke(bez([pr((-6,-37,99))],[pr((0,-39,101))],[pr((6,-37,99))]),0.5*SS,0.5*SS,INK,120)
# naso-labial folds
for s in(-1,1): stroke(bez([pr((s*22,-24,84))],[pr((s*34,-38,80))],[pr((s*38,-50,74))]),0.8*SS,0.2*SS,INK,110 if s<0 else 170)
# forehead lines, scar over the right brow
for yy,a in((44,70),(52,50)): stroke(bez([pr((-26,yy,78))],[pr((0,yy+3,84))],[pr((26,yy,78))]),0.2*SS,0.2*SS,INK,a,wmid=0.6*SS)
# mouth under the moustache
stroke(bez([pr((-17,-54,92))],[pr((0,-56,100))],[pr((17,-54,92))]),0.6*SS,0.6*SS,INK,240,wmid=2.0*SS)
img=np.array(lay).astype(float)/255
# ---- strands in beard and hair
st=Image.new('RGBA',(W,H),(0,0,0,0)); sd=ImageDraw.Draw(st)
bM=M('beard'); hM=M('hair')
hx,hy=pr((0,0,0)); _,mouthY=pr((0,-55,95)); _,chinY=pr((0,-150,45)); tipx,_=pr((0,-150,45))
ys,xs=np.nonzero(bM)
for i in rng.choice(len(xs),520):
    x,y=xs[i],ys[i]; t=np.clip((y-mouthY)/(chinY-mouthY),0,1)
    if y<mouthY: dx=(x-hx)*0.9
    else: dx=(tipx-x)*(0.25+0.5*t)/(abs(tipx-x)+40)*40*0.05+(x-tipx)*0.15*(1-t)
    dv=np.array([dx/40.0,1.0]); dv/=np.linalg.norm(dv); L=rng.uniform(16,34)*SS/2*1.2
    cur=rng.normal(0,0.3)
    pts=[(x+dv[0]*L*u+cur*L*u*u*dv[1],y+dv[1]*L*u-cur*L*u*u*dv[0]) for u in np.linspace(0,1,6)]
    lv=litS[y,x]
    if rng.random()<0.55: c=(0.06,0.035,0.025); a=150
    else: c=np.array([0.55,0.33,0.18])*(0.3+1.2*lv)+0.02; a=int(90+120*lv)
    sd.line(pts,fill=col(c,a),width=1+int(rng.random()<0.4))
ys,xs=np.nonzero(hM)
for i in rng.choice(len(xs),600):
    x,y=xs[i],ys[i]; dv=np.array([(x-hx)*0.7,-(y-hy+80*SS)]); dv/=np.linalg.norm(dv)+1e-9; L=rng.uniform(12,30)*SS/2*1.2
    pts=[(x+dv[0]*L*u,y+dv[1]*L*u) for u in np.linspace(0,1,5)]
    lv=litS[y,x]
    c=(0.05,0.03,0.02) if rng.random()<0.6 else np.array([0.5,0.32,0.2])*(0.25+1.3*lv)+np.array([0.05,0.07,0.12])*0.5
    sd.line(pts,fill=col(c,150),width=1+int(rng.random()<0.3))
sa=np.array(st).astype(float)/255; keep=(bM|hM); keep=nd.binary_erosion(keep,iterations=2)
al=sa[...,3]*keep; img=img*(1-al[...,None])+sa[...,:3]*al[...,None]
# mail texture on the cloth: small scale rings, steel rivets/rim
cM=M('cloth')
yy,xx=np.mgrid[0:H,0:W]
ring=(np.sin(xx*0.9+((yy//6)%2)*np.pi)*np.sin(yy*1.05))>0.55
img[cM&ring]*=0.72
# ---- ink: outer contour heavy in the dark, thin where lit
dO,ind=nd.distance_transform_edt(~mask,return_indices=True)
lo=litS[ind[0],ind[1]]
w=SS*(0.9+2.8*(1-np.clip(lo*1.6,0,1)))
a=np.clip(w-dO+0.5,0,1)*(~mask)
# inner: depth breaks and material borders (not eyes), fine
Zp=np.pad(ZM,1,mode='edge'); dz=np.maximum.reduce([np.abs(ZM-Zp[1:-1,2:]),np.abs(ZM-Zp[1:-1,:-2]),np.abs(ZM-Zp[2:,1:-1]),np.abs(ZM-Zp[:-2,1:-1])])
Mp=np.pad(MAT,1,mode='edge'); mc=(MAT!=Mp[1:-1,2:])|(MAT!=Mp[2:,1:-1])
eye=names.index('eyes'); mc&=(MAT!=eye)&(Mp[1:-1,2:]!=eye)&(Mp[2:,1:-1]!=eye)
seed=mask&((dz>6.0)|mc)
seed=nd.binary_erosion(mask,iterations=1)&seed
dI=nd.distance_transform_edt(~seed)
wi=SS*(0.35+1.0*(1-np.clip(litS*1.8,0,1)))
ai=np.clip(wi-dI+0.5,0,1)*mask*0.9
A=np.maximum(a,ai)
img=img*(1-A[...,None])+INK*A[...,None]
# ---- embers in the night
out=Image.fromarray((np.clip(img,0,1)*255).astype('uint8')).resize((OW,OH),Image.LANCZOS)
MS=nd.binary_dilation(mask[::SS,::SS],iterations=6)
gl=Image.new('RGB',(OW,OH),(0,0,0)); gd=ImageDraw.Draw(gl)
for i in range(30):
    x=rng.uniform(20,OW-20); y=OH-rng.power(1.6)*OH*0.8
    if MS[min(OH-1,int(y)),min(OW-1,int(x))]: continue
    r=rng.uniform(0.8,2.0); b=rng.uniform(0.5,1)
    gd.ellipse([x-r,y-r,x+r,y+r],fill=(int(255*b),int(170*b),int(70*b)))
from PIL import ImageFilter, ImageChops
g2=gl.filter(ImageFilter.GaussianBlur(3))
out=ImageChops.add(out,ImageChops.add(gl,g2))
out.save(sys.argv[2]+'.png'); out.save(sys.argv[2]+'.webp',quality=86,method=6)
