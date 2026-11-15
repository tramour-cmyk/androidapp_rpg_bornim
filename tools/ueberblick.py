#!/usr/bin/env python3
"""Überblick für den Chef (1313, Chef 15.11., 19:37): Themenblöcke mit Stand und die nächsten 20 Vorgänge in Reihenfolge.

„das sind die nächsten 20 Aufgaben, die kommen, in der richtigen Reihenfolge … Welche Nummer ist das? Um was geht's da? …
Und wenn einer fertig ist, dann rückt halt das nächste hinten nach. Oder wenn was vorgezogen wird, muss die Liste auch
aktualisiert werden. Das muss auf Chefsache direkt sichtbar stehen.“

Steht oben in `docs/chefsache/README.md` (zug-index.py rechnet ihn bei jedem Lauf neu, also bei jedem Push auf die Vorgangsliste).
Reihenfolge der 20: erst was sofort geht (startbar, in Arbeit), dann was wartet; darin „jetzt“ (jüngstes zuerst: was der Chef zuletzt
vorzieht, steht auf Rang 1), dann Muss,
dann Kür; darin nach Themenblock, dann nach dem Rang beim Besitzer (`startbar.plan`, also `vorgang.py rang`). Nicht in den 20:
ruht, nach Meilenstein, Idee, Dauer, aufgeteilt, Pflege-Zeilen, „gebaut“ (fährt mit dem nächsten Build oder wartet auf Diogenes)
und was in einem Build auf deinen Test wartet (Zählzeile darunter; Sokrates 15.11., 20:05). Vorziehen heißt: „jetzt“ oder
`vorgang.py rang` beim Besitzer.

Aufruf: python3 tools/ueberblick.py   (Markdown auf stdout)
"""
import os, re, sys, datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar as s

# Themenblöcke: Reihenfolge und Zuschnitt legt der Chef fest (Vorlage Perikles 15.11., 1313). Zuordnung ohne Raten:
# zuerst Nummer (Vorsilbe), sonst Bereich der Zeile; was keinem Block zufällt, steht unter „Übriges“.
# Reihenfolge wie „Teilprojekte bis Kapitel 1 fertig“ in PROJEKTPLAN.md (1061, Chef 12.11., 17:42).
# Chef 15.11., 20:08: „Kapitel 1 nach vorne macht keinen Sinn, weil Umzug und Kampf passt und Godot besser nutzen, alles auch
# zu Kapitel 1 abschließen passt“: Überschrift KAPITEL1 über allen Blöcken mit "kap1"; Abgleich alt (1280, 1281) bei Welt.
KAPITEL1 = "Kapitel 1 fertig (Godot, BRS)"
BLOECKE = [
    ("Umzug BRS, SRD ablösen", {"nr": ("870", "882", "1279"), "kap1": True}),
    ("Kampf passt", {"bereich": ("E Kampf", "G Balance"), "kap1": True}),
    ("Kleiderschrank und Modelle (Held, Leute, Monster)", {"bereich": ("E Figuren",), "kap1": True}),
    ("Welt, Karten, Bild, Ton, Bedienung (auch was gegenüber Kotlin fehlt)",
     {"nr": ("1280", "1281"), "bereich": ("E Welt", "E Oberfläche", "E Klang", "G Stil", "G Story", "Q QS"), "kap1": True}),
    ("Godot besser nutzen (Technik, Build, Leistung)", {"bereich": ("E Technik",), "kap1": True}),
    ("Werkzeuge und Abläufe der Firma", {"bereich": ("B Steuerung", "B Abläufe", "B Werkzeuge", "Q QM")}),
    ("Marktstart", {"bereich": ("M Markt", "M Veröffentlichung")}),
]
UEBRIG = "Übriges"
RUHT = ("ruht", "nach Meilenstein", "Idee", "Dauer", "aufgeteilt", "erledigt", None)
JETZT_ZEIT = re.compile(r"„jetzt“ (\d\d)\.(\d\d)\.(?:,? (\d\d):(\d\d))?")
ANZAHL = 20


def block(d):
    for k, (_, regel) in enumerate(BLOECKE):
        if any(d["nr"] == n or d["nr"].startswith(n + ".") for n in regel.get("nr", ())):
            return k
    for k, (_, regel) in enumerate(BLOECKE):
        if (d.get("bereich") or "") in regel.get("bereich", ()):
            return k
    return len(BLOECKE)


def name(k):
    return BLOECKE[k][0] if k < len(BLOECKE) else UEBRIG


def worum(titel, n=80):
    t = re.sub(r"^Von [^:(]+(?:\([^)]*\))?[^:]*:\s*", "", titel)  # „Von Sokrates (Chef …): …“ → Inhalt
    t = re.sub(r"\s*·\s*„jetzt“.*$", "", t)
    t = re.sub(r"\s*·\s*zurück t\d+.*$", "", t)
    t = re.sub(r"\s*\([^()]*\)", "", t).strip(" ;,")
    return t if len(t) <= n else t[:n - 1].rstrip() + "…"


def wartet_auf_test(d):
    """Liegt bei dir: in einem Build, „zu testen“ (schon vorgelegt, auch „ohne Rückmeldung t<n>“) oder gebaut mit t<n> im Feld."""
    if d["wort"] == "zu testen": return True
    return d["wort"] == "gebaut" and (str(d.get("build") or "").strip().isdigit() or any(re.fullmatch(r"t\d+", t) for t in d["warte"]))


def bei_diogenes(d):
    """Werkzeug gebaut: wartet nur noch auf „greift“ von Diogenes (724 A), keine Arbeit, die kommt."""
    return s.b_gebaut(d) and not s.b_nicht_auf_main(d)


def jetzt_von(d):
    m = JETZT_ZEIT.search(d["titel"] + " " + d["stand"])
    if not m: return None
    tag = s.jahr_von(int(m.group(1)), int(m.group(2)))
    return datetime.datetime(tag.year, tag.month, tag.day, int(m.group(3) or 0), int(m.group(4) or 0))


def kurzstand(d, grund):
    if grund is None: return {"in Arbeit": "in Arbeit"}.get(d["wort"], "startbar")
    g = re.sub(r"\s*\(.*$", "", grund)
    return g[:40]


def rang_je_besitzer():
    """Nummer → (Platz beim Besitzer, Grund der Sperre oder None) aus startbar.plan (eigene Zeilen)."""
    aus = {}
    for r in sorted({d["besitzer"] for d in s.zeilen_liste()} - {"Ideen"}):
        try: zs = s.plan(r)
        except Exception: continue
        k = 0
        for z in zs:
            if "fuer" in z[3]: continue
            aus[z[0]] = (k, z[4]); k += 1
    return aus


def rechnen():
    zs = [d for d in s.zeilen_liste() if d["wort"] not in ("erledigt",) and d["besitzer"] != "Ideen" and d["nr"] not in s.SONDER]
    rang = rang_je_besitzer()
    kommt, test, pruef, gebaut = [], [], [], []
    for d in zs:
        if wartet_auf_test(d): test.append(d); continue
        if bei_diogenes(d): pruef.append(d); continue
        if d["wort"] == "gebaut": gebaut.append(d); continue  # Sokrates 20:05: fährt mit dem nächsten Build, keine Arbeit, die kommt
        if d["wort"] in RUHT or d["kl"] in ("–", "-"): continue
        k, grund = rang.get(d["nr"], (999, s.sperre(d)))
        j = jetzt_von(d)
        muss = d["kl"] == "M"
        # erst, was sofort geht (startbar, in Arbeit), dann was noch wartet, auch bei „jetzt“ (Sokrates 20:05); darin „jetzt“, Muss, Kür
        key = (0 if grund is None else 1, 0 if j else 1, 0 if muss else 1, -(j or datetime.datetime.min).timestamp() if j else 0, block(d), k)
        kommt.append((key, d, grund))
    kommt.sort(key=lambda x: x[0])
    return zs, kommt, test, pruef, gebaut


def md():
    zs, kommt, test, pruef, gebaut = rechnen()
    # Stand = letzte Änderung der Vorgangsliste (Berliner Zeit), nicht die Uhr: sonst schriebe jeder Lauf die Übersicht neu
    stand = s._git("-c", "log.showSignature=false", "log", "-1", "--date=format-local:%d.%m., %H:%M", "--format=%cd", "--",
                   os.path.join(s.DOCS, s.LISTE)).stdout.strip() or s.JETZT.strftime("%d.%m., %H:%M")
    aus = ["## Überblick", "",
           "Vom Werkzeug gerechnet (`tools/ueberblick.py`, 1313), Vorgangsliste vom %s, neu bei jeder Änderung. "
           "Reihenfolge der Blöcke und ihren Zuschnitt legst du fest; vorziehen: sag es, wir setzen den Rang beim Besitzer." % stand, "",
           "**Themenblöcke**", "", "| Block | offen | Muss | in Arbeit | zum Testen | ruht | nächster |", "|---|---|---|---|---|---|---|"]
    erst = {}
    for key, d, grund in kommt:
        erst.setdefault(block(d), d)
    kopf = False
    for k in list(range(len(BLOECKE))) + [len(BLOECKE)]:
        je = [d for d in zs if block(d) == k]
        if not je: continue
        kap1 = k < len(BLOECKE) and BLOECKE[k][1].get("kap1")
        if kap1 and not kopf:
            aus.append("| **%s** | | | | | | |" % KAPITEL1); kopf = True
        n = erst.get(k)
        aus.append("| %s | %d | %d | %d | %d | %d | %s |" % (
            ("↳ " if kap1 else "") + name(k), len(je), sum(d["kl"] == "M" for d in je), sum(d["wort"] == "in Arbeit" for d in je),
            sum(wartet_auf_test(d) for d in je), sum(d["wort"] in RUHT for d in je),
            ("%s (%s) %s" % (n["nr"], n["besitzer"], worum(n["titel"], 50))) if n else "–"))
    aus += ["", "**Die nächsten %d**" % ANZAHL, "", "| # | Nr. | Wer | Worum | Kl. | Block | Stand |", "|---|---|---|---|---|---|---|"]
    for i, (key, d, grund) in enumerate(kommt[:ANZAHL], 1):
        aus.append("| %d | %s | %s | %s | %s | %s | %s |" % (i, d["nr"], d["besitzer"], worum(d["titel"]).replace("|", "/"),
                                                         d["kl"], name(block(d)).split(" (")[0].split(":")[0], kurzstand(d, grund)))
    aus += ["", "Danach %d weitere offen. Bei dir zum Testen (vorgelegt): %d. Gebaut, fährt mit dem nächsten Build: %d. "
            "Werkzeug gebaut, Prüfung Diogenes: %d. Ruhend oder nach dem Meilenstein: %d." % (
        max(0, len(kommt) - ANZAHL), len(test), len(gebaut), len(pruef), sum(d["wort"] in RUHT for d in zs))]
    return "\n".join(aus)


if __name__ == "__main__":
    print(md())
