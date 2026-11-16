import os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim, handgemenge as hg, glut2_lesen as G
HIER=os.path.dirname(os.path.abspath(__file__))
W=sim.lade(os.path.join(HIER,"werte.json")); H=sim.lade(os.path.join(HIER,"handgemenge.json"))
W["monster"]["Rudel"]=dict(W["monster"]["Wolf"],rudel="Jungwolf"); G.GEGENWERT["Rudel"]=1
H["tempo_gegner"]["Rudel"]=H["tempo_gegner"]["Wolf"]
rng=random.Random(1411); n=600
herk=list(sim.ohne_info(W["herkuenfte"]))
fb={hk: sim.fortschritt_alle(W,hk,25,rng,True)["fert_bei"] for hk in herk}
for vn,vo in {"heute":{},"A+B":{"groesse_ab1":True,"preis":True}}.items():
    z={"S":0,"N":0,"W":0,"=":0}
    for hk in herk:
        for gg,sf in G.FAELLE:
            h=hg.held_bei(W,hk,sf,fb[hk])
            w={k:G.wert(G.messe(W,H,h,gg,n,rng,dict(vo,politik=p,nachlegen_schaden=0.25))) for k,p in (("S","schlag_haltung"),("N","nachlegen"),("W","warten"))}
            b=max(w,key=w.get); z["=" if w[b]-sorted(w.values())[-2]<3 else b]+=1
    print(vn,z,"von",len(herk)*len(G.FAELLE))
