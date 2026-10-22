import numpy as np, sys, time
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage as nd
t0=time.time()
OW,OH=480,500; SS=2; W,H=OW*SS,OH*SS
CX,CY=OW*0.5,OH*0.44   # head centre in output px
SC=0.85
YAW=np.radians(16.0); PITCH=np.radians(-4.0)
cy_,sy_=np.cos(YAW),np.sin(YAW); cp,sp=np.cos(PITCH),np.sin(PITCH)
Ry=np.array([[cy_,0,sy_],[0,1,0],[-sy_,0,cy_]]); Rx=np.array([[1,0,0],[0,cp,-sp],[0,sp,cp]])
R=Ry@Rx   # model->world (head)
Rinv=R.T
def smin(a,b,k):
    h=np.clip(0.5+0.5*(b-a)/k,0,1); return b*(1-h)+a*h-k*h*(1-h)
def smax(a,b,k): return -smin(-a,-b,k)
def ell(p,c,r):
    q=(p-np.array(c))/np.array(r); k0=np.linalg.norm(q,axis=1); k1=np.linalg.norm(q/np.array(r),axis=1)
    return k0*(k0-1)/np.maximum(k1,1e-9)
def cap(p,a,b,ra,rb):
    a=np.array(a,float);b=np.array(b,float);ba=b-a;pa=p-a
    h=np.clip((pa@ba)/(ba@ba),0,1); return np.linalg.norm(pa-h[:,None]*ba,axis=1)-(ra+(rb-ra)*h)
def parts(pw):
    # head parts in model space (rotated), body in world (slight yaw only)
    p=(pw@R)/SC   # world->model: p_m = Rinv p_w  (row vectors: p_w @ R)
    skull=ell(p,(0,22,-12),(78,92,88))
    jaw=ell(p,(0,-40,12),(66,58,70))
    skin=smin(skull,jaw,18)
    skin=smin(skin,ell(p,(0,16,64),(62,13,22)),10)          # brow ridge
    for s in(-1,1):
        skin=smin(skin,ell(p,(s*36,-14,46),(28,14,22)),26)   # cheekbones
        skin=smin(skin,ell(p,(s*80,0,-6),(11,24,15)),6)      # ears
        skin=smax(skin,-ell(p,(s*30,3,80),(20,11,13)),9)     # sockets
    skin=smin(skin,cap(p,(0,14,74),(0,-26,100),10,14),6)      # nose
    for s in(-1,1): skin=smin(skin,ell(p,(s*11,-28,88),(10,8,9)),4)
    skin=smin(skin,ell(p,(0,-63,76),(19,6,10)),4)              # lower lip
    neck=cap(p,(0,-80,-16),(0,-175,-18),54,66)
    skin=smin(skin,neck,14)
    eyes=np.minimum(ell(p,(-30,3,66),(14,10,14)),ell(p,(30,3,66),(14,10,14)))
    hair=smax(ell(p,(0,28,-16),(86,98,94)), -(p[:,1]-(22+0.42*p[:,2]+7*np.sin(p[:,0]*0.11+1.0)*np.clip(p[:,2]/60,0,1))),8)
    hair=smin(hair,ell(p,(14,74,52),(40,22,30)),14)
    beard=smin(ell(p,(0,-78,24),(74,64,56)),cap(p,(0,-95,48),(0,-158,44),32,10),16)
    beard=smax(beard,(p[:,1]-(-4-0.56*np.maximum(p[:,2],0))),10)
    beard=smax(beard,-ell(p,(0,-56,92),(18,8,30)),4)        # mouth gap
    for s in(-1,1): beard=smin(beard,cap(p,(s*3,-40,100),(s*40,-62,74),9,6),6)  # moustache
    # body in world coords, scaled
    q=pw/SC
    q=q.copy(); q[:,2]+=0
    torso=ell(q,(0,-350,-20),(200,175,82))
    torso=smin(torso,cap(q,(-130,-222,-20),(130,-222,-20),50,50),40)
    torso=smin(torso,cap(q,(-60,-180,-30),(60,-180,-30),46,46),30)
    steel=np.minimum(ell(q,(-158,-212,-12),(68,46,64)),ell(q,(158,-212,-12),(68,46,64)))
    gorget=smax(ell(q,(0,-188,-6),(84,34,74)),-ell(q,(0,-176,-6),(56,60,62)),4)
    steel=np.minimum(steel,gorget)
    strap=smax(torso-6, np.abs((q[:,1]+260)+0.55*(q[:,0]))-16,2)
    return dict(skin=skin*SC,eyes=eyes*SC,hair=hair*SC,beard=beard*SC,cloth=torso*SC,steel=steel*SC,strap=strap*SC)
def scene(pw):
    d=parts(pw); return np.minimum.reduce(list(d.values()))
# rays
xs=(np.arange(W)+0.5)/SS-CX; ys=CY-(np.arange(H)+0.5)/SS
X,Y=np.meshgrid(xs,ys)
N=W*H; ox=X.ravel(); oy=Y.ravel(); z=np.full(N,400.0)
hit=np.zeros(N,bool); alive=np.ones(N,bool)
for it in range(140):
    idx=np.nonzero(alive)[0]
    if len(idx)==0: break
    d=scene(np.stack([ox[idx],oy[idx],z[idx]],1))
    z[idx]-=d*0.9
    h=d<0.15; hit[idx[h]]=True
    gone=h|(z[idx]<-450); alive[idx[gone]]=False
print('march',time.time()-t0,file=sys.stderr)
hi=np.nonzero(hit)[0]; P=np.stack([ox[hi],oy[hi],z[hi]],1)
e=0.4
def grad(P):
    g=np.zeros_like(P)
    for i in range(3):
        dv=np.zeros(3);dv[i]=e; g[:,i]=scene(P+dv)-scene(P-dv)
    return g/np.linalg.norm(g,axis=1,keepdims=True)
Nn=grad(P)
pd=parts(P); names=list(pd.keys()); mat=np.argmin(np.stack([pd[k] for k in names],1),1)
# fire light: below, in front, a bit left
LP=np.array([-70.0,-300.0,470.0])
Lv=LP-P; dist=np.linalg.norm(Lv,axis=1); L=Lv/dist[:,None]
ndl=np.clip((Nn*L).sum(1),0,1)
# soft shadow
sh=np.ones(len(P)); t=np.full(len(P),3.0)
for it in range(48):
    q=P+Nn*1.0+L*t[:,None]; d=scene(q)
    sh=np.minimum(sh,np.clip(5*d/t,0,1)); t+=np.clip(d,1.5,40)
    if (t>dist).all(): break
sh=np.clip(sh,0,1)
att=(560.0/np.maximum(dist,1))**1.3
lit=ndl*sh*np.clip(att,0,1.6)
def band(v):
    lv=np.array([0.0,0.32,0.62,0.95]); out=np.zeros_like(v)
    for a,b in zip(lv[:-1],lv[1:]):
        out+= (b-a)*np.clip((v-(a+b)/2)/0.11+0.5,0,1)
    return out*0.85+v*0.15
tone=band(np.clip(lit,0,1.2))
V=np.array([0,0,1.0])
rimL=np.array([0.55,0.55,-0.63]); rimL/=np.linalg.norm(rimL)
fres=(1-np.clip(Nn[:,2],0,1))**3
rim=fres*np.clip((Nn*rimL).sum(1)+0.35,0,1)
alb={'skin':(0.80,0.56,0.42),'eyes':(0.86,0.82,0.76),'hair':(0.23,0.15,0.10),'beard':(0.27,0.17,0.11),
     'cloth':(0.30,0.20,0.16),'steel':(0.50,0.52,0.56),'strap':(0.36,0.22,0.12)}
A=np.array([alb[k] for k in names])[mat]
fire=np.array([1.35,0.78,0.40]); amb=np.array([0.10,0.08,0.13]); moon=np.array([0.30,0.42,0.70])
col=A*(amb+fire*tone[:,None])
# warm subsurface at terminator on skin
sk=(np.array(names)[mat]=='skin')
term=np.exp(-((lit-0.25)/0.12)**2)*sk
col+=np.array([0.28,0.06,0.02])*term[:,None]*0.6
col+=moon*rim[:,None]*np.where(np.isin(np.array(names)[mat],['steel']),0.9,0.75)[:,None]
# specular
Hh=(L+V);Hh/=np.linalg.norm(Hh,axis=1,keepdims=True)
nh=np.clip((Nn*Hh).sum(1),0,1)
isst=np.array(names)[mat]=='steel'
spec=np.where(isst,nh**60*0.6,np.where(sk,nh**30*0.18,0))*sh
col+=fire*spec[:,None]
img=np.zeros((N,3)); 
# background: night, warm glow bottom
bgv=np.clip((Y.ravel()-(-330))/600,0,1)
bg=np.stack([0.025+0.02*(1-bgv),0.03+0.005*(1-bgv),0.06*bgv+0.03],1)
glow=np.exp(-(((X.ravel()+60)/260)**2+((Y.ravel()+420)/200)**2))
bg+=np.array([0.35,0.12,0.03])*glow[:,None]
img[:]=bg; img[hi]=col
LIT=np.zeros(N); LIT[hi]=np.clip(lit,0,1)
ZM=np.full(N,-500.0); ZM[hi]=z[hi]; MAT=np.full(N,-1); MAT[hi]=mat
img=img.reshape(H,W,3); LIT=LIT.reshape(H,W); ZM=ZM.reshape(H,W); MAT=MAT.reshape(H,W); mask=hit.reshape(H,W)
np.savez_compressed(sys.argv[1],img=img,LIT=LIT,ZM=ZM,MAT=MAT,mask=mask,names=np.array(names))
print('done',time.time()-t0,file=sys.stderr)
