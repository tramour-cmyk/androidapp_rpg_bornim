# 1543: muss_vorn ordnet je Besitzer Muss vor M? vor Kür vor „nach Meilenstein“, stabil, andere Besitzer bleiben. Aufruf: python3 tools/vorgang_ordnen_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import vorgang
K = "| Nr. | Vorgang | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
z = lambda nr, b, kl, st="startbar": "| %s | T%s | %s | %s | %s | – | – | – | E Kampf | – |" % (nr, nr, b, kl, st)
text = K + "\n".join([z(1, "Tom", "K"), z(2, "Jerry", "K"), z(3, "Jerry", "K", "nach Meilenstein"), z(4, "Tom", "M"),
                      z(5, "Jerry", "M"), z(6, "Jerry", "M?"), z(7, "Jerry", "M")]) + "\n"
neu, n = vorgang.muss_vorn(text)
reihe = lambda t, b: [d["nr"] for d in vorgang.startbar.vorgangsliste(t) if d["besitzer"] == b]
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)
soll("Jerry: Muss stabil vorn, M?, Kür, nach Meilenstein", reihe(neu, "Jerry"), ["5", "7", "6", "2", "3"])
soll("Tom: Muss vor Kür", reihe(neu, "Tom"), ["4", "1"])
soll("Plätze je Besitzer bleiben", [d["besitzer"] for d in vorgang.startbar.vorgangsliste(neu)], ["Tom", "Jerry", "Jerry", "Tom", "Jerry", "Jerry", "Jerry"])
soll("zweiter Lauf ändert nichts", vorgang.muss_vorn(neu)[1], 0)
soll("Zahl verschobener Zeilen", n, 7)
sys.exit(fehl)
