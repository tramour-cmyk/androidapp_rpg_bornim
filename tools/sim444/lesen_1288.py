import os, sys, random, statistics
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim, handgemenge as hg, glut2_lesen as G
HIER=os.path.dirname(os.path.abspath(__file__))
W=sim.lade(os.path.join(HIER,"werte.json")); H=sim.lade(os.path.join(HIER,"handgemenge.json"))
W["monster"]["Rudel"]=dict(W["monster"]["Wolf"],rudel="Jungwolf"); G.GEGENWERT["Rudel"]=1
H["tempo_gegner"]["Rudel"]=H["tempo_gegner"]["Wolf"]
rng=random.Random(1411); n=int(sys.argv[1]) if len(sys.argv)>1 else 600
herk=list(sim.ohne_info(W["herkuenfte"]))
fb={hk: sim.fortschritt_alle(W,hk,25,rng,True)["fert_bei"] for hk in herk}
VAR={"heute":{},"A Größe ab Stufe 1":{"groesse_ab1":True},"B falsche Haltung kostet":{"preis":True},"A+B":{"groesse_ab1":True,"preis":True}}
LF=[("Goblin-Späher",2),("Wolf+Goblin-Späher",2),("Riesenspinne",4),("Krogg",4),("Grimmzahn",5),("Grak",6),("Rudel",1),("Skelett",2)]
for vn,vo in VAR.items():
    print("==",vn)
    for us in (1,):
        diffs=[]; rows=[]
        for hk in herk:
            cells=[]
            for gg,sf in LF:
                h=hg.held_bei(W,hk,max(1,sf-us),fb[hk])
                q=[G.messe(W,H,h,gg,n,rng,dict(vo,politik="schlag_haltung",lesestufe=s))["quote"]*100 for s in (0,3)]
                diffs.append(q[1]-q[0]); cells.append(f"{q[0]:.0f}→{q[1]:.0f}")
            rows.append(f"  {hk:16s} "+" | ".join(cells))
        print(f" Unterstufe {us}: Lesen 0→3, Mittel +{statistics.mean(diffs):.1f}, größtes +{max(diffs):.0f}")
        print("\n".join(rows))
    # natürliche Stufe, Unterstufe 0: Mittel aller FAELLE, Krogg min, Runden
    qs=[];kr={};rd=[]
    for hk in herk:
        for gg,sf in G.FAELLE:
            h=hg.held_bei(W,hk,sf,fb[hk]); r=G.messe(W,H,h,gg,n,rng,dict(vo,politik="schlag_haltung"))
            qs.append(r["quote"]*100); rd.append(r["runden"] or 0)
            if gg=="Krogg": kr[hk]=r["quote"]*100
    print(f" natürlich, Stufe gleich: Sieg Mittel {statistics.mean(qs):.1f}, Runden Mittel {statistics.mean(rd):.2f}, Krogg kleinste {min(kr.values()):.0f} ({min(kr,key=kr.get)})")
print("Spalten:",[g for g,_ in LF])
