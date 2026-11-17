#!/usr/bin/env python3
"""Figurenkatalog (649.2, 649b A): alles zu einer Monsterart an einer Stelle, erzeugt aus den Quellen des Spiels.

    python3 tools/figuren.py                  # Abschnitt „Monster im Spiel (erzeugt)“ als Markdown
    python3 tools/figuren.py --luecken        # nur die Lücken (Klang, Bewegung, Handlung, Aussehen unter drei, Chef 08.11.)
    python3 tools/figuren.py --pruefen DATEI  # Exit 1, wenn der Abschnitt in DATEI (LISTE-FIGUREN.md) veraltet ist
    python3 tools/figuren.py --modelle DIR    # dazu Bewegungen aus gebauten Modellen (*.glb, *.bin in DIR, Kampfbau)

Keine eigene Datendatei (649b: „keine neue Datei, die still veraltet“): das Werkzeug liest nur, was das Spiel schon liest.
Art und Name: werte.json „kennungen“ (Quelle seit 870.3/1385); Werte: „monster“; Regeln und Beute: „monsterregeln“;
Handlungen: „absichten“ „je_art“; Begleiter: „merkmale“ „rudel“; Klänge: kampfklang.json und die Dateien in
daten/klang/sfx (je Anlass die Zahl der Fassungen); Auftritt: karten.json „begegnungen“ (Karte, Tag/Nacht, Anteil);
Kampfgruppe: aufruf.gd gegner() (Aufstellung je Kartengruppe); Aussehen: Felle aus der Tabelle, Kits aus figur.gd;
Bewegungen: Animationen der Modelle (Karte: godot/tiere/*.glb; Kampf: --modelle, die Modelle baut erst der Kampfbau).
Ändert nichts im Spiel. Build 2 (Code liest aus der Tabelle) wartet auf das neue Gegnerverhalten (1589, 1605).
"""
import json
import re
import struct
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
WERTE = WURZEL / "tools/sim444/werte.json"
KLANG = WURZEL / "godot/daten/klang/kampfklang.json"
SFX = WURZEL / "godot/daten/klang/sfx"
KARTEN = WURZEL / "godot/daten/karten.json"
AUFRUF = WURZEL / "godot/kampf/aufruf.gd"
FIGUR = WURZEL / "godot/kampf/figur.gd"
MARS = WURZEL / "godot/regeln/mars.gd"
TIERE = WURZEL / "godot/tiere"

ANFANG = "<!-- figuren.py: Anfang (erzeugt, nicht von Hand ändern; python3 tools/figuren.py) -->"
ENDE = "<!-- figuren.py: Ende -->"

# Kits je Art: Name der Liste in figur.gd (die Werte liest das Werkzeug dort, damit nichts doppelt steht)
KITS = {"wolf": "WOLF_COATS", "goblin": "GOBLIN_KITS", "goblin_archer": "SCOUT_KITS", "goblin_shaman": "SHAMAN_KITS",
        "kobold": "KOBOLD_KITS", "hobgoblin_captain": "GRAK_KITS", "bugbear": "KROGG_KITS", "skeleton": "SKELETT_KITS",
        "zombie": "WIEDERGAENGER_KITS"}
# Karte: Modell je Art in godot/tiere (Streuner)
KARTENMODELL = {"wolf": "wolf.glb", "dire_wolf": "wolf.glb", "giant_rat": "ratte.glb", "boar": "wildschwein.glb"}
# Einmalige Figuren (eine Form, DESIGN-STIL „Ausnahme einmalige Monster“): Aussehen ohne drei Varianten
EINMALIG = {"dire_wolf", "bugbear", "hobgoblin_captain"}
ANLAESSE = ["angriff", "schmerz", "tod", "idle"]
ANLASS_DE = {"angriff": "Angriff", "schmerz": "Treffer", "tod": "Tod", "idle": "Stimme"}


def lade(p):
    return json.loads(Path(p).read_text(encoding="utf-8"))


def gd_liste(text, name):
    m = re.search(r"^const %s\s*:?=\s*(\[[^\]]*\])" % re.escape(name), text, re.M)
    return re.findall(r'"([^"]+)"', m.group(1)) if m else []


def gd_konstanten(text):
    return dict(re.findall(r'^const ([A-Z_]+)\s*:?=\s*"([^"]+)"', text, re.M))


def aufstellungen(text, konst):
    """aufruf.gd gegner(): Kartengruppe -> Liste der Kennungen (Mars.X und Figur.X aufgelöst)."""
    kopf = text.find("var lineup: Array = {")
    rumpf = text[kopf:text.find("}.get(foe", kopf)]
    aus = {}
    for name, inhalt in re.findall(r'"([A-Z0-9]+)":\s*\[(.*?)\]\],?\s*(?:#.*)?$', rumpf, re.M):
        arten = []
        for e in re.findall(r'\[[^\[\]]*\]', inhalt + "]"):
            teile = [t.strip() for t in e.strip("[]").split(",")]
            if len(teile) < 2:
                continue
            a = teile[1]
            if a.startswith(("Mars.", "Figur.")):
                a = konst.get(a.split(".", 1)[1], a)
            arten.append(a.strip('"'))
        aus[name] = arten
    m = re.search(r"^const ART := \{(.*?)\}", text, re.M)
    art = {}
    if m:
        for g, a in re.findall(r'"([A-Z0-9]+)":\s*Mars\.([A-Z_]+)', m.group(1)):
            art[g] = konst.get(a, a)
    return aus, art


def glb_bewegungen(p):
    b = p.read_bytes()
    if b[:4] != b"glTF":
        return []
    lang = struct.unpack("<I", b[12:16])[0]
    j = json.loads(b[20:20 + lang])
    return [a.get("name", "") for a in j.get("animations", [])]


def klangzahl():
    zahl = {}
    for f in SFX.iterdir() if SFX.exists() else []:
        m = re.match(r"(.+)_\d+\.(ogg|wav|mp3)$", f.name)
        if m:
            zahl[m.group(1)] = zahl.get(m.group(1), 0) + 1
    return zahl


def zahl(x):
    return ("%g" % x).replace(".", ",") if isinstance(x, float) else str(x)


def sammeln(modelle=None):
    w = lade(WERTE)
    kl = lade(KLANG)
    karten = lade(KARTEN)["karten"]
    fig = FIGUR.read_text(encoding="utf-8")
    konst = gd_konstanten(MARS.read_text(encoding="utf-8"))
    konst.update(gd_konstanten(fig))
    aufst, art_von = aufstellungen(AUFRUF.read_text(encoding="utf-8"), konst)
    kz = klangzahl()
    rudel = w.get("merkmale", {}).get("rudel", {})
    absichten = w.get("absichten", {}).get("je_art", {})
    gebaut = {}
    if modelle:
        for f in sorted(Path(modelle).iterdir()):
            if f.suffix in (".glb", ".bin"):
                gebaut[f.stem] = glb_bewegungen(f)
    figuren = []
    for k, t in w["kennungen"].items():
        if k.startswith("_"):
            continue
        werte = w["monster"].get(t.get("art", ""), {})
        regeln = w.get("monsterregeln", {}).get(k, {})
        h = absichten.get(k, absichten.get("_sonst"))
        herkunft = "" if k in absichten else "allgemein"
        while isinstance(h, str):
            herkunft = h
            h = absichten.get(h, absichten.get("_sonst"))
        handlungen = list(dict.fromkeys(x[0] for x in (h or [])))
        stimme = kl.get("stimme", {}).get(k, {}).get("stimme", "")
        treffer = kl.get("fx_klang", {}).get(kl.get("monster_fx", {}).get(k, ""), "")
        klaenge = {a: kz.get(("idle_%s" if a == "idle" else "%s_" + a) % stimme, 0) if stimme else 0 for a in ANLAESSE}
        auftritt = []
        for kn, kv in karten.items():
            b = kv.get("begegnungen") or {}
            for zeit, schl in (("Tag", "tabelle"), ("Nacht", "nacht")):
                tab = b.get(schl) or []
                summe = sum(g for _, g in tab) or 1
                for a, g in tab:
                    if a == k:
                        auftritt.append("%s %s %d %%" % (kn, zeit, round(100 * g / summe)))
        gruppe = t.get("kartengruppe", "")
        mit = []
        if gruppe == "RUDEL":
            jw = rudel.get("Jungwolf", {})
            n = jw.get("anzahl")
            mit.append("Leitwolf mit %s Jungwolf" % ("–".join(map(str, n)) if isinstance(n, list) else n))
        elif gruppe in aufst:
            glieder = [art_von.get(gruppe, a) for a in aufst[gruppe]]
            if gruppe == "GRIMM":
                lw = rudel.get("Leibwache", {})
                mit.append("mit Leibwache: %s × Wolf" % lw.get("anzahl", "?"))
            else:
                mit.append("%d × %s" % (len(glieder), k) if len(set(glieder)) <= 1 else ", ".join(glieder))
        aussehen = t.get("felle") or (gd_liste(fig, KITS[k]) if k in KITS else [])
        bew_karte = glb_bewegungen(TIERE / KARTENMODELL[k]) if k in KARTENMODELL and (TIERE / KARTENMODELL[k]).exists() else []
        bew_kampf = sorted({b for stem, bs in gebaut.items() if stem == k or stem.startswith(k + "-") for b in bs})
        figuren.append({
            "kennung": k, "de": t.get("de", ""), "en": t.get("en", ""), "gruppe": t.get("gruppe", ""), "werte": werte,
            "regeln": regeln, "handlungen": handlungen, "handlungen_von": herkunft, "stimme": stimme, "treffer": treffer,
            "klaenge": klaenge, "auftritt": auftritt, "kartengruppe": gruppe, "mit": mit, "aussehen": aussehen,
            "vierbeiner": bool(t.get("vierbeiner")), "ruhe": t.get("ruhe", []), "sitz": t.get("sitz", []), "bew_karte": bew_karte, "bew_kampf": bew_kampf,
        })
    return figuren


def luecken(figuren, modelle=False):
    aus = []
    for f in figuren:
        k = f["kennung"]
        if not f["werte"]:
            aus.append((k, "keine Werte in „monster“"))
        if len(set(f["handlungen"])) < 2:
            aus.append((k, "nur eine Handlung (%s; Chef 08.11. „mehr als eine Handlung je Monsterart“)" % (", ".join(f["handlungen"]) or "–")))
        if not f["stimme"]:
            aus.append((k, "ohne Stimme (kampfklang.json „stimme“)"))
        for a, n in f["klaenge"].items():
            if f["stimme"] and n < 3:
                aus.append((k, "Klang %s: %d Fassungen (%s)" % (ANLASS_DE[a], n, ("idle_%s" if a == "idle" else "%s_" + a) % f["stimme"])))
        if k not in EINMALIG and f["aussehen"] and len(f["aussehen"]) < 3:
            aus.append((k, "Aussehen: %d Varianten" % len(f["aussehen"])))
        if f["vierbeiner"] and not f["ruhe"] and f["auftritt"]:
            aus.append((k, "ohne Ruhebewegung auf der Karte („ruhe“)"))
        if modelle and not f["bew_kampf"]:
            aus.append((k, "kein gebautes Kampfmodell im Verzeichnis"))
    return aus


def seite(figuren, modelle=False):
    z = [ANFANG, "", "## Monster im Spiel (erzeugt, 649.2)", "",
         "Erzeugt von `tools/figuren.py` aus den Quellen, die das Spiel liest (Kopf des Werkzeugs); ändern dort, nicht hier. "
         "Klänge: Zahl der Fassungen je Anlass (Ziel drei). Bewegungen im Kampf stehen erst nach dem Kampfbau fest "
         "(`--modelle`); hier die der Kartenmodelle.", "",
         "| Kennung | Name | Gruppe | Stufe, Leben, Schutz, Angriff/Abwehr, Schaden | Art, Schwäche | Handlungen | Sonderregel, Beute | Auftritt | Kampfgruppe |",
         "|---|---|---|---|---|---|---|---|---|"]
    for f in figuren:
        w, r = f["werte"], f["regeln"]
        werte = "%s, %s, %s, %s/%s, %s" % tuple(zahl(w.get(x, "–")) for x in ("stufe", "leben", "ruestung", "angriff", "abwehr", "schaden")) if w else "–"
        schw = ", ".join("%s ×%s" % (s, zahl(v)) for s, v in (w.get("schwaeche") or {}).items())
        beute = ", ".join("%s %d %%" % (b, round(100 * c)) for b, c in r.get("beute", []))
        sonder = ", ".join(x for x in (r.get("sonder", ""), r.get("typ", "")) if x)
        hand = ", ".join(f["handlungen"]) + (" (%s)" % f["handlungen_von"] if f["handlungen_von"] == "allgemein" else " (wie %s)" % f["handlungen_von"] if f["handlungen_von"] else "")
        z.append("| `%s` | %s / %s | %s | %s | %s | %s | %s | %s | %s |" % (
            f["kennung"], f["de"], f["en"], f["gruppe"], werte, ", ".join(x for x in (w.get("art", ""), schw) if x) or "–",
            hand or "–", "; ".join(x for x in (sonder, beute) if x) or "–", ", ".join(f["auftritt"]) or "–",
            (f["kartengruppe"] + ": " if f["kartengruppe"] else "") + ", ".join(f["mit"]) if f["kartengruppe"] else "–"))
    z += ["", "### Klang, Aussehen, Bewegungen", "",
          "| Kennung | Stimme | Angriff | Treffer | Tod | Stimme (Ruhe) | Trefferklang | Aussehen | Ruhe auf der Karte | Bewegungen (Karte) |" + (" Bewegungen (Kampf) |" if modelle else ""),
          "|---|---|---|---|---|---|---|---|---|---|" + ("---|" if modelle else "")]
    for f in figuren:
        kl = f["klaenge"]
        z.append("| `%s` | %s | %s | %s | %s | %s | %s | %s | %s | %s |%s" % (
            f["kennung"], f["stimme"] or "–", kl["angriff"], kl["schmerz"], kl["tod"], kl["idle"], f["treffer"] or "–",
            ", ".join(f["aussehen"]) or "Kaufhäute (erst im Kampfbau)", ", ".join(f["ruhe"] + f["sitz"]) or "–", ", ".join(f["bew_karte"]) or "–",
            (" %s |" % (", ".join(f["bew_kampf"]) or "–")) if modelle else ""))
    lk = luecken(figuren, modelle)
    z += ["", "### Lücken (%d)" % len(lk), ""]
    z += ["- `%s`: %s" % (k, t) for k, t in lk] or ["- keine"]
    z += ["", ENDE]
    return "\n".join(z) + "\n"


def main(argv):
    modelle = argv[argv.index("--modelle") + 1] if "--modelle" in argv else None
    figuren = sammeln(modelle)
    if "--luecken" in argv:
        lk = luecken(figuren, bool(modelle))
        for k, t in lk:
            print("%s: %s" % (k, t))
        print("%d Lücken bei %d Arten" % (len(lk), len(figuren)))
        return 0
    text = seite(figuren, bool(modelle))
    if "--pruefen" in argv:
        datei = Path(argv[argv.index("--pruefen") + 1])
        alt = datei.read_text(encoding="utf-8")
        a, e = alt.find(ANFANG), alt.find(ENDE)
        if a < 0 or e < 0:
            print("figuren.py: kein erzeugter Abschnitt in %s" % datei)
            return 1
        if alt[a:e + len(ENDE)] + "\n" != text:
            print("figuren.py: Abschnitt in %s veraltet; neu erzeugen: python3 tools/figuren.py" % datei)
            return 1
        print("figuren.py: Abschnitt aktuell (%d Arten)" % len(figuren))
        return 0
    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
