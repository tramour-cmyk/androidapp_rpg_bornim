#!/usr/bin/env python3
"""1403 (1352a A, 1292 A): Siegquoten aller Herkünfte gegen Rudel, Krogg, Grimmzahn, Grak mit Wundsegen-Grenze und Taumeln 1/5, 1/4, 1/3.
Aufruf: python3 tools/sim444/taumeln_1403.py [Kämpfe]; Unterstufe 1: held_bei(sf-1). Nur Werkzeug."""
import os,sys,random
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
import sim, handgemenge as hg, glut2 as g2
HIER=os.path.dirname(os.path.abspath(__file__))
W=sim.lade(os.path.join(HIER,"werte.json")); H=sim.lade(os.path.join(HIER,"handgemenge.json"))
W["monster"]["Rudel"]=dict(W["monster"]["Wolf"],rudel="Jungwolf"); g2.GEGENWERT["Rudel"]=g2.GEGENWERT["Wolf"]; H["tempo_gegner"]["Rudel"]=H["tempo_gegner"]["Wolf"]
rng=random.Random(1403); n=int(sys.argv[1]) if len(sys.argv)>1 else 1000
herk=list(sim.ohne_info(W["herkuenfte"]))
fb={hk:sim.fortschritt_alle(W,hk,25,rng,True)["fert_bei"] for hk in herk}
F=[("Rudel",1),("Krogg",4),("Grimmzahn",5),("Grak",6)]
V=[("vorher",{}),("1292",{"segen_max":2}),("+T 1/5",{"segen_max":2,"taumeln":0.2}),("+T 1/4",{"segen_max":2,"taumeln":0.25}),("+T 1/3",{"segen_max":2,"taumeln":1/3})]
print("| Herkunft | Gegner | "+" | ".join(v[0] for v in V)+" | taumelt je Kampf (1/5) | Segen je Kampf (1292) |")
print("|"+"---|"*(len(V)+4))
for hk in herk:
  for gg,sf in F:
    h=hg.held_bei(W,hk,sf,fb[hk]); row=[]; extra={}
    for name,o in V:
      o=dict(o,politik="schlag_haltung",wehr_gegen_schuetzen=True)
      r=g2.messe(W,H,h,gg,n,rng,o); row.append(f"{r['quote']*100:.0f}"); extra[name]=r
    print(f"| {hk} | {gg} {sf} | "+" | ".join(row)+f" | {extra['+T 1/5']['taumelt']:.2f} | {extra['1292']['segen']:.2f} |")
