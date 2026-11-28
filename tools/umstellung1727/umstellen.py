#!/usr/bin/env python3
"""1727 Umstellung der Vorgangsliste (Bauliste Schritt 1; Chef 21.11., 22:11: Umstellungswerkzeug in Spikes Spur, 1739).

Stellt einen docs-Ordner um, nie den laufenden: die Liste selbst stellt erst der Umschalt-Commit um (Schritt 8, kein
Parallelbetrieb wie 275.2, `tools/umstellung2752/README.md`), Rückweg `git revert` dieses einen Commits.

  umstellen.py DOCS [--bericht DATEI] [--trocken]

Was geschieht (Muster `docs/entwurf/1727-muster/LISTE-VORGAENGE.md`):
- Spalten neu: Nr. | Titel | Block | Bereich | Kl. | wartet auf | Bezug | Zweig | *Stand* | *Sitzung* | *Runde* | *Kosten*.
  Besitzer und Build fallen aus der Liste; beide stehen in der Vorgangsdatei unter „## Herkunft“ (Build trägt Automatik B
  bis zum Build-Auftrag). Erledigte Zeilen bleiben, wie sie sind (räumt `lauf.py --aufraeumen` ab).
- Titel kurz: das ganze alte Titelfeld (Chefzitat) steht wörtlich in der Vorgangsdatei, Zeile „Herkunft: …“ (Feld, das
  `chef_fund.py` liest); der neue Titel ist der Text nach „Von X (…):“ bis zum ersten „;“ bzw. höchstens KURZ Zeichen.
- Bereich: `bereiche.einordnen`; Vorgänge aus Block 4 (Spalte „Vorgänge“ in `chefsache/themenbloecke.md`, auch Unternummern)
  → „E Kataloge“ (VA 20.11., 08:21). Block aus dem Bereich nach `themenbloecke.md` (VA 20.11., 07:47: Vorgang trägt nur den
  Bereich, Block rechnet das Werkzeug); G Regeln → Block 10 (VA 20.11., 09:27), sonst 9 „Übriges“.
- Kl.: „M“ mit „„jetzt““ im Titel → „Eilt“ (Eilt setzt nur der Chef; „jetzt“ ist sein Wort, 383); M? bleibt (Bericht).
- wartet auf: Diogenes → Prüfer, Ford → Disponent, Perikles → Arbeitsplaner; Tom, Jerry, Spike, Homer → Bericht HAND.
- Bezug: Vorgangsnummern im alten Titel, die in Liste oder Archiv stehen (ohne Datum, Lauf, Build, Commit, Messwert mit Einheit
  oder Pfeil, ohne zweistellige); Hilfe zum Finden, kein Urteil: Zahlen wie „Mittel 360“ können durchrutschen.
- Folge der Zeilen (VA 21.11., 20:51 Büro-Liste): Eilt, Muss, M?, Kür, „nach Meilenstein“; darin Fund des Chefs („Von Chef“)
  zuerst, dann Block nach `themenbloecke.md`, dann Eingang (Nummer); erledigte Zeilen am Ende.
- Bericht: Zahlen, EILT (für den Hinweis ab dem vierten, VA 21.11., 11:36), HAND, KURZ (gekürzte Titel), BEREICH (unbekannt).
Zweiter Lauf ändert nichts (Kopf erkannt).
"""
import os, re, sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import bereiche  # noqa: E402

KOPF_ALT = ["Nr.", "Titel", "Besitzer", "Kl.", "Stand", "wartet auf", "Zweig", "Build", "Bereich", "Kosten"]
KOPF_NEU = ["Nr.", "Titel", "Block", "Bereich", "Kl.", "wartet auf", "Bezug", "Zweig", "*Stand*", "*Sitzung*", "*Runde*", "*Kosten*"]
KURZ = 120
PROFIL = {"Diogenes": "Prüfer", "Ford": "Disponent", "Perikles": "Arbeitsplaner"}
HANDROLLEN = ("Tom", "Jerry", "Spike", "Tuffy", "Homer")
ZUSATZ_BLOCK = {"G Regeln": "10", "E Kataloge": "4"}
KL_RANG = {"Eilt": 0, "M": 1, "M?": 2, "K": 3}
EINLEITUNG = ("Eine Zeile je Vorgang (1727). Schreibt nur `vorgang.py`. Stand, Sitzung, Runde und Kosten rechnet das Werkzeug aus den "
              "Aufträgen (kursiv), niemand trägt sie ein. Block rechnet das Werkzeug aus dem Bereich (`chefsache/themenbloecke.md`). "
              "Folge: Eilt, Muss, Kür; darin Fund des Chefs, Block, Eingang. Herkunft, Chefzitat und alter Besitzer stehen in "
              "`docs/vorgang/<Nr>.md`. Umgestellt mit `tools/umstellung1727/umstellen.py`, Rückweg `git revert`.")


def zellen(z):
    return [x.strip() for x in z.strip().strip("|").split(" | ")]


def bloecke(docs):
    """(Folge der Blocknummern, Bereich → Block, Vorgang → Block, Block → Name)."""
    try: t = open(os.path.join(docs, "chefsache", "themenbloecke.md"), encoding="utf-8").read()
    except OSError: t = ""
    folge, nach_bereich, nach_nr, name = [], dict(ZUSATZ_BLOCK), {}, {}
    for z in t.splitlines():
        if not re.match(r"\| \d+ \|", z): continue
        c = zellen(z)
        if len(c) < 7: continue
        folge.append(c[0]); name[c[0]] = re.sub(r"\s*\(.*", "", c[1])
        for b in re.split(r",\s*", c[5]):
            if b and b != "–": nach_bereich[b] = c[0]
        for n in re.split(r",\s*", c[6]):
            if n and n != "–": nach_nr[n] = c[0]
    if "9" not in folge: folge.append("9"); name.setdefault("9", "Übriges")
    return folge, nach_bereich, nach_nr, name


def block_nr(nr, nach_nr):
    """Block über die Vorgangsnummer, auch für Unternummern (458.3 → 458)."""
    n = nr
    while n:
        if n in nach_nr: return nach_nr[n]
        n = n.rsplit(".", 1)[0] if "." in n else re.sub(r"[a-z]+$", "", n) if re.search(r"[a-z]$", n) else ""
    return None


def bekannte(docs):
    s = set()
    for f in ("LISTE-VORGAENGE.md", "LISTE-VORGAENGE-ARCHIV.md"):
        try:
            for z in open(os.path.join(docs, f), encoding="utf-8"):
                m = re.match(r"\| (\d[0-9a-zA-Z.]*) \|", z)
                if m: s.add(m.group(1))
        except OSError:
            pass
    return s


def bezug(nr, titel, nummern):
    t = re.sub(r"\b\d\d\.\d\d\.(\d{4})?", " ", titel)            # Daten
    t = re.sub(r"\b\d\d:\d\d\b|\b\d\d:\dx\b", " ", t)             # Uhrzeiten
    t = re.sub(r"\b(Lauf|Läufe|Build|Commit|Zeile|Teil|Stufe)\s+[\d, ]+", " ", t)
    t = re.sub(r"`[^`]*`", " ", t)
    t = re.sub(r"\d+(?:[.,]\d+)?\s*(?:→|->|–|-|bis|von|zu|statt|auf)\s*\d+", " ", t)   # Messwerte „131→110“, „3 bis 5“
    t = re.sub(r"\d+(?:[.,]\d+)?\s*(?:cm|mm|m|km|ms|s|h|min|Min\.?|%|\$|Tsd\.?|KB|MB|GB|Bilder|Bytes?|Ecken|Dreiecke|×|x)\b", " ", t)
    t = re.sub(r"\d+(?:[.,]\d+)?\s*(?:%|\$|×|°)", " ", t)
    aus = []
    for n in re.findall(r"(?<![\w.$/→])(\d{2,4}(?:\.\d+)*[a-z]?)(?![\w$%→°]|\.\d|,\d)", t):
        if len(n.split(".")[0].rstrip("abcdefghijklmnopqrstuvwxyz")) < 3: continue  # zweistellige sind meist Zahlen, keine Vorgänge
        if n != nr and n in nummern and n not in aus: aus.append(n)
    return aus


def kurz(titel):
    t = re.sub(r"^Von [^:(]+?(?:\s*\((?:[^()]|\([^()]*\))*\))?[:,]\s*", "", titel)
    t = re.sub(r"\s*·\s*(„jetzt“|zurück t\d+|wiederholt).*$", "", t)
    tiefe = 0
    for i, c in enumerate(t):  # bis zum ersten „; “ außerhalb von Klammern
        tiefe += (c in "(„") - (c in ")“")
        if c == ";" and tiefe <= 0 and t[i + 1:i + 2] == " ": t = t[:i]; break
    t = t.strip()
    if len(t) > KURZ:
        t = t[:KURZ].rsplit(" ", 1)[0].rstrip(",:;")
        if t.count("(") > t.count(")"): t = t[:t.rfind("(")].rstrip(",:; ")
        if t.count("„") > t.count("“"): t = t[:t.rfind("„")].rstrip(",:; ")
        t += " …"
    return t


def herkunft_text(nr, alt, titel_neu):
    d = dict(zip(KOPF_ALT, alt))
    return ("## Herkunft\n\nUmgestellt 1727 (`tools/umstellung1727/umstellen.py`); wörtlich aus der alten Vorgangsliste:\n\n"
            "Herkunft: %s\n\n- Besitzer bis 1727: %s\n- Stand bis 1727: %s\n- Build: %s\n" % (d["Titel"], d["Besitzer"], d["Stand"], d["Build"]))


def vorgangsdatei(docs, nr, alt, titel_neu, trocken):
    p = os.path.join(docs, "vorgang", "%s.md" % nr)
    try: text = open(p, encoding="utf-8").read()
    except OSError: text = ""
    if "## Herkunft" in text: return False
    if not text:
        text = "# %s · %s\n\nVorgangsdatei (1727 Gesamtbild 0a). Übergaben schreibt nur `vorgang.py` (1760).\n" % (nr, titel_neu)
    text = text.rstrip("\n") + "\n\n" + herkunft_text(nr, alt, titel_neu)
    if not trocken:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, "w", encoding="utf-8").write(text)
    return True


def runden(docs, nr):
    try: return open(os.path.join(docs, "vorgang", "%s.md" % nr), encoding="utf-8").read().count("\n## Auftrag")
    except OSError: return 0


def umstellen(docs, trocken=False):
    pfad = os.path.join(docs, "LISTE-VORGAENGE.md")
    text = open(pfad, encoding="utf-8").read()
    L = text.split("\n")
    kopf_i = next((i for i, z in enumerate(L) if z.startswith("| Nr. |")), None)
    if kopf_i is None: raise SystemExit("umstellen: Kopf der Vorgangsliste fehlt")
    if zellen(L[kopf_i]) == KOPF_NEU: return None  # schon umgestellt
    if zellen(L[kopf_i]) != KOPF_ALT: raise SystemExit("umstellen: unbekannter Kopf %r" % L[kopf_i])
    ende = kopf_i + 2
    while ende < len(L) and L[ende].startswith("|"): ende += 1
    folge, nach_bereich, nach_nr, _ = bloecke(docs)
    nummern = bekannte(docs)
    B = dict(eilt=[], hand=[], kurz=[], bereich=[], mfrage=[], dateien=0, offen=0, erledigt=0)
    neu = []
    for z in L[kopf_i + 2:ende]:
        alt = zellen(z)
        if len(alt) != len(KOPF_ALT): raise SystemExit("umstellen: Zeile mit %d Zellen: %s" % (len(alt), z[:80]))
        d = dict(zip(KOPF_ALT, alt))
        nr = d["Nr."]
        erledigt = d["Stand"].startswith("erledigt")
        titel = d["Titel"] if erledigt else kurz(d["Titel"])
        if not erledigt and titel != d["Titel"] and len(d["Titel"]) > KURZ: B["kurz"].append(nr)
        bereich = bereiche.einordnen(d["Bereich"])
        bn = block_nr(nr, nach_nr)
        if bn == "4" and not erledigt: bereich = "E Kataloge"
        if bereich.startswith("?"): B["bereich"].append("%s (%s)" % (nr, d["Bereich"]))
        block = bn or nach_bereich.get(bereich, "9")
        kl = d["Kl."]
        if kl == "M" and "„jetzt“" in d["Titel"] and not erledigt: kl = "Eilt"; B["eilt"].append(nr)
        if kl == "M?": B["mfrage"].append(nr)
        warte = []
        for w in re.split(r",\s*", d["wartet auf"]):
            k = w.split(" ")[0] if w else w
            if k in PROFIL: w = PROFIL[k] + w[len(k):]
            elif k in HANDROLLEN and not erledigt: B["hand"].append("%s wartet auf %s" % (nr, w))
            if w: warte.append(w)
        if d["Besitzer"] == "Ideen" and not erledigt and not d["Stand"].startswith("Idee"):
            B["hand"].append("%s Besitzer Ideen, Stand %s" % (nr, d["Stand"].split(",")[0]))
        bz = ", ".join(bezug(nr, d["Titel"], nummern)) or "–"
        stand = d["Stand"] or "–"
        zeile = [nr, titel, block, bereich, kl, ", ".join(warte) or "–", bz, d["Zweig"] or "–",
                 "*%s*" % stand, "*–*", "*%d*" % runden(docs, nr), "*%s*" % (d["Kosten"] or "–")]
        if not erledigt and vorgangsdatei(docs, nr, alt, titel, trocken): B["dateien"] += 1
        B["erledigt" if erledigt else "offen"] += 1
        stufe = 4 if "nach Meilenstein" in d["Stand"] else KL_RANG.get(kl, 3)
        fund = 0 if re.match(r"Von Chef\b", d["Titel"]) else 1
        eingang = [int(x) if x.isdigit() else 0 for x in re.findall(r"\d+|[a-z]+", nr)]
        schluessel = (1 if erledigt else 0, stufe, fund, folge.index(block) if block in folge else len(folge), eingang)
        neu.append((schluessel, "| " + " | ".join(zeile) + " |"))
    neu.sort(key=lambda x: x[0])
    vor = L[:kopf_i]
    # Einleitung: Absatz nach der Überschrift ersetzen, Regeltexte tauscht der Umschalt-Commit mit Edit (wie 275.2 TEXTE.md)
    vor = [vor[0], "", EINLEITUNG, ""] + [z for z in vor[1:] if z.startswith("- ")] + [""]
    aus = vor + ["| " + " | ".join(KOPF_NEU) + " |", "|" + "---|" * len(KOPF_NEU)] + [z for _, z in neu] + L[ende:]
    if not trocken: open(pfad, "w", encoding="utf-8").write("\n".join(aus))
    return B


def bericht(B):
    if B is None: return "schon umgestellt, nichts geändert"
    z = ["Zeilen offen %d, erledigt %d; Vorgangsdateien mit Herkunft neu %d" % (B["offen"], B["erledigt"], B["dateien"]),
         "EILT %d: %s%s" % (len(B["eilt"]), ", ".join(B["eilt"]) or "–", " (ab dem vierten Hinweis an den Chef, VA 21.11., 11:36)" if len(B["eilt"]) > 3 else ""),
         "M? %d: %s" % (len(B["mfrage"]), ", ".join(B["mfrage"]) or "–"),
         "KURZ %d Titel gekürzt (ganzer Titel in Herkunft): %s" % (len(B["kurz"]), ", ".join(B["kurz"][:40]) + (" …" if len(B["kurz"]) > 40 else ""))]
    z += ["BEREICH unbekannt: " + b for b in B["bereich"]]
    z += ["HAND " + h for h in B["hand"]]
    return "\n".join(z)


if __name__ == "__main__":
    a = sys.argv[1:]
    if not a or a[0].startswith("-"): print(__doc__); sys.exit(2)
    B = umstellen(a[0], trocken="--trocken" in a)
    t = bericht(B)
    if "--bericht" in a: open(a[a.index("--bericht") + 1], "w", encoding="utf-8").write(t + "\n")
    print(t)
