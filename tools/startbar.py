#!/usr/bin/env python3
"""Startbares je Rolle (166) aus der einen Vorgangsliste `docs/LISTE-VORGAENGE.md` (275.2, Chef 07.11., 21:5x).

Aufruf: python3 tools/startbar.py [--alle] [--stand] [--md] [--loesen] [--liegt]   (--liegt: startbares Muss je Rolle nach Pause, 891)   (Ford ruft es in jedem Lauf, LISTE-BETRIEB.md Schritt 1 und 4)
Eine Tabelle, je Vorgang eine Zeile: Nr. · Titel · Besitzer · Kl. · Stand · wartet auf · Zweig · Build · Bereich · Kosten.
Reihenfolge der Zeilen eines Besitzers = Vorrang. Vorräte `ARBEIT-*.md` haben keine Tabelle mehr, nur Übergabe, Pause und „Zu <Nr>“.
Je Rolle: oberstes startbares Muss und oberste startbare Kür (Kl. „M?“ zählt als Kür), dazu, warum andere Zeilen nicht startbar sind
(--alle: jede Zeile); --stand: „offen n, Muss m, startbar s, gesperrt g“. „Pause bis <Zeit>“ oben im Vorrat sperrt die Rolle.
Stand = ein Wort der Liste WORTE, dahinter nach Komma oder Doppelpunkt höchstens ein kurzer Zusatz; gerechnet wird nur mit dem Wort
(und „in Arbeit bei Spike|Tuffy“, 433).
**Automatik A „wartet auf“** (275.2): Feld mit Nummern, Rollen, Daten (TT.MM.[ HH:MM]) oder „Chef[ <Dateinummer>]“, mit Komma getrennt.
Erfüllt: Nummer erledigt (für die Sperre auch gebaut oder zu testen, 190.1; geschrieben wird nur bei erledigt, D80.3); Datum vorbei;
Chefsache-Datei weg; t<Build> mit Archiveintrag.
Eine Rolle erfüllt sich nie von selbst: die Zeile erscheint bei dieser Rolle als ihre Arbeit (Klasse der wartenden Zeile), bis die Rolle
das Feld mit `vorgang.py warte <Nr> –` leert. Jeder Lauf zeigt erfüllte Felder als „GELÖST“; mit --loesen (lauf.py --sperre) schreibt
er sie: erfüllte Teile fallen weg, ist das Feld leer und das Wort wartet, Chef, ruht oder Dauer, wird die Zeile „startbar, gelöst …“.
Muss durch Wartende (190.3, 162): wartet eine Muss-Zeile auf Nummer X, zählt X als Muss (Ausgabe „↑ Muss: <Rolle> wartet“).
Zeilen mit „wiederholt“ im Titel stehen vor allem anderen, nur die „jetzt“-Zeilen davor (620.1 A).
Ab 6 gebauten oder zu testenden Muss eines Teams (ohne Sammelbuild) sperrt neues Muss bis zum Test, aber nur, wenn es sich mit
Ungetestetem überschneidet (Nummer, Titelwort wie Ort oder Figur, geänderte Datei; 779, Chef 09.11., 17:30); frei bleiben wiederholt,
„jetzt“, Rückläufer mit Build und Angefangenes (620.1 B, Chef 08.11., 10:55/10:57; ein Rückläufer ist ein Fund, den der Chef
zum zweiten Mal meldet, also „wiederholt“ nach 620.1 A; Angefangenes ist kein neues Muss; 729).
Wächter 424: eine sonst startbare Zeile, die Regeln des alten Systems nennt, ruht. Exit 1 bei unlesbaren oder ungültigen Zeilen.
Laufende Sitzungen kennt das Werkzeug nicht; die liest Ford aus list_sessions.
"""
import os, re, sys, datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bereiche  # 651: feste Liste der Bereiche

DOCS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs")
ROLLEN = [("ARBEIT-KREATIV.md", "Homer"), ("ARBEIT-TEAM-TOM.md", "Tom"), ("ARBEIT-TEAM-JERRY.md", "Jerry"),
          ("ARBEIT-PROJEKT.md", "Perikles"), ("ARBEIT-PRUEFUNG.md", "Diogenes"), ("ARBEIT-BERATUNG.md", "Sokrates")]
VORRAT = {r: d for d, r in ROLLEN}
VORRAT["Ford"] = "ARBEIT-BETRIEB.md"
BESITZER = [r for _, r in ROLLEN] + ["Ford", "Ideen"]  # „Ideen“: Ideenspeicher, wird nie gestartet (LISTE-IDEEN.md)
WARTE_ROLLEN = [r for _, r in ROLLEN] + ["Ford"]
ZUSATZ = {"Spike": "Tom", "Tuffy": "Jerry"}  # 394, 433: Zusatzentwickler arbeiten auf Zeilen ihres Teams
FERTIG = re.compile(r"erledigt|auf main|getestet|gebaut|zu testen", re.I)
ROLLEN_NAMEN = r"(?:Homer|Tom|Jerry|Spike|Tuffy|Perikles|Diogenes|Sokrates|Ford(?: 2)?|Chef)"  # 394: Spike, Tuffy
JETZT = datetime.datetime.now()
LISTE = "LISTE-VORGAENGE.md"
SPALTEN = ["Nr.", "Titel", "Besitzer", "Kl.", "Stand", "wartet auf", "Zweig", "Build", "Bereich", "Kosten"]
KOPF = "| " + " | ".join(SPALTEN) + " |"
# Wortliste 275 (Chef 27.10., 15:09: festes Wort); Reihenfolge = vom offensten zum geschlossensten
WORTE = ["in Arbeit", "startbar", "offen", "nach Meilenstein", "wartet", "Chef", "Dauer", "ruht", "gebaut", "zu testen", "aufgeteilt", "Idee", "erledigt"]
SONDER = ("Pflege", "Spiegel")  # 340.3: Zeilen des Werkzeugs, je Besitzer eine
CHEF_ORDNER = ("entscheiden", "ansehen", "billigen", "tun")

def blank(t):
    """Stand ohne Markdown-Zeichen am Anfang."""
    return re.sub(r"^[\s*`_]+", "", re.sub(r"\*\*|`", "", t)).strip()

def lesen(name):
    p = os.path.join(DOCS, name)
    return open(p, encoding="utf-8").read() if os.path.exists(p) else ""

def liste_merken(docs=None):
    """275 Stufe 2: nach jedem Schreiben eines Werkzeugs den Inhalt von LISTE-VORGAENGE.md merken (git hash-object, höchstens 200,
    in <git-common-dir>/bornim-liste-ok); die Commit-Prüfung warnt bei einem Stand, den kein Werkzeug geschrieben hat. Fehler still."""
    try:
        import subprocess
        d = docs or DOCS
        h = subprocess.run(["git", "-C", d, "hash-object", LISTE], capture_output=True, text=True).stdout.strip()
        g = subprocess.run(["git", "-C", d, "rev-parse", "--git-common-dir"], capture_output=True, text=True).stdout.strip()
        if not h or not g: return
        f = os.path.join(d, g, "bornim-liste-ok") if not os.path.isabs(g) else os.path.join(g, "bornim-liste-ok")
        alt = open(f).read().split() if os.path.exists(f) else []
        open(f, "w").write("\n".join((alt + [h])[-200:]) + "\n")
    except Exception:
        pass

# ---------------------------------------------------------------- Tabelle lesen

def zeilen(inhalt, unles=None):
    """Tabellenzeilen (Nr, Kl, Thema, Rest) einer Tabelle im alten Vorratsformat „| Nr. | Kl. | … |“ (für Abschnitte, die noch so aussehen,
    z. B. Prüflisten); die Vorgänge selbst stehen nur in der Liste (zeilen_liste)."""
    aus = []
    for z in inhalt.splitlines():
        if not z.startswith("| "): continue
        t = [x.strip() for x in z.split("|")][1:-1]
        if not t or t[0] in ("Nr.", "Nr") or set(t[0]) <= set("-: "): continue
        if len(t) < 4 or t[1] not in ("M", "K", "M?", "–", "-"):
            if unles is not None: unles.append(t[0])
            continue
        aus.append((t[0], t[1], t[2], " | ".join(t[3:])))
    return aus

def zellen(z):
    return [x.strip() for x in z.split("|")][1:-1]

def tabellen(text):
    """Alle Markdown-Tabellen eines Textes: [(Kopf, [(Zeilennummer, Zellen)])]."""
    aus, kopf, zs = [], None, []
    L = text.split("\n")
    for i, z in enumerate(L):
        if z.startswith("|"):
            t = zellen(z)
            if kopf is None:
                if i + 1 < len(L) and re.match(r"^\|[\s:|-]+\|\s*$", L[i + 1]): kopf = t
                continue
            if set("".join(t)) <= set("-: "): continue
            zs.append((i, t))
        else:
            if kopf is not None: aus.append((kopf, zs))
            kopf, zs = None, []
    if kopf is not None: aus.append((kopf, zs))
    return aus

SCHLUESSEL = {"Nr.": "nr", "Nr": "nr", "Titel": "titel", "Vorgang": "titel", "Besitzer": "besitzer", "Vorrat": "besitzer", "Kl.": "kl",
              "Stand": "stand", "wartet auf": "warte", "Zweig": "zweig", "Build": "build", "Bereich": "bereich", "Kosten": "kosten"}

def tafel_zeilen(text):
    """Zeilen aller Vorgangstabellen eines Textes als dict mit den Schlüsseln aus SCHLUESSEL (nr, titel, besitzer, kl, stand, bereich,
    kosten, …), Spalten über den Kopf: liest die Liste mit Feldern (275.2) und das alte Format (Archiv, Git-Stände vor 275.2) gleich."""
    aus = []
    for kopf, zs in tabellen(text):
        if not ("Nr." in kopf and "Stand" in kopf): continue
        idx = {SCHLUESSEL[k]: n for n, k in enumerate(kopf) if k in SCHLUESSEL}
        for _, t in zs:
            if len(t) < len(kopf): continue
            aus.append({k: t[n] for k, n in idx.items()})
    return aus

def wort_von(stand):
    """Erstes Wort der Wortliste am Anfang des Stands (längstes zuerst), sonst None."""
    b = blank(stand)
    for w in sorted(WORTE, key=len, reverse=True):
        if b == w or b.startswith(w) and not b[len(w):len(w) + 1].isalnum(): return w
    return None

def zusatz_von(stand):
    w = wort_von(stand)
    return blank(stand)[len(w):].lstrip(" ,:;–-").strip() if w else ""

def vorgangsliste(text=None):
    """Zeilen der Vorgangsliste als dict (nr, titel, besitzer, kl, stand, wort, zusatz, warte [Liste], zweig, build, bereich, kosten,
    zeile, i). Liest die erste Tabelle mit Spalte „Besitzer“ und „wartet auf“."""
    text = lesen(LISTE) if text is None else text
    for kopf, zs in tabellen(text):
        if "Besitzer" not in kopf or "wartet auf" not in kopf: continue
        idx = {SCHLUESSEL.get(k, k): n for n, k in enumerate(kopf)}
        aus = []
        L = text.split("\n")
        for i, t in zs:
            d = {k: (t[n] if n < len(t) else "") for k, n in idx.items()}
            d["zeile"] = L[i]; d["i"] = i; d["spalten"] = len(t)
            d["wort"] = wort_von(d.get("stand", "")); d["zusatz"] = zusatz_von(d.get("stand", ""))
            w = d.get("warte", "").strip()
            d["warte"] = [] if w in ("", "–", "-") else [x.strip() for x in w.split(",") if x.strip()]
            aus.append(d)
        return aus
    return []

def zeile_text(d):
    """dict → Tabellenzeile im Format KOPF."""
    w = ", ".join(d.get("warte") or []) or "–"
    werte = [d.get("nr", ""), d.get("titel", ""), d.get("besitzer", ""), d.get("kl", ""), d.get("stand", ""), w,
             d.get("zweig") or "–", d.get("build") or "–", d.get("bereich", ""), d.get("kosten") or "–"]
    return "| " + " | ".join(str(x).replace("|", "/").replace("\n", " ").strip() for x in werte) + " |"

_LISTE = None
# 719 A (Chef 09.11., 11:26): jeder Wochentermin legt sich an seinem Tag selbst als Muss beim Besitzer an; Ford startet ihn wie jeden Vorgang.
# lauf.py --sperre legt an (vorgang.neu), ersetzt WOCHENSTART; erledigt setzt der Besitzer. Neue Termine nur hier eintragen. Ab 10.11. (09.11. lief von Hand).
WOCHENTERMINE = [  # (Wochentag 0 = Mo, ab Stunde, Besitzer, Name, Bereich)
    (0, 8, "Perikles", "Wochenziel", "B Steuerung"),
    (0, 8, "Diogenes", "Wochenzählung (Kennzahlen, Wochentermine gelaufen, Teilhaken 720)", "Q QM"),
    (0, 8, "Perikles", "Haken-Frage Abnahmeliste als ansehen/-Datei (720)", "Q QS"),
] + [  # 759 (Chef 09.11., 14:36): je Rolle eine Zeile, sonst holt nur Perikles nach
    (4, 8, r, "Rollenspiegel %s (rollenspiegel.sh %s)" % (r, r), "B Abläufe")
    for r in ("Sokrates", "Perikles", "Homer", "Ford", "Diogenes", "Tom", "Jerry")
] + [
    (6, 9, "Homer", "Ideenspeicher", "B Abläufe"),
]

def wochentermine_faellig(jetzt):
    """719: [(Titel, Bereich, Besitzer)] heute fällig und noch ohne Zeile in Liste oder Archiv."""
    tag = jetzt.strftime("%d.%m.")
    da = lesen(LISTE) + lesen("LISTE-VORGAENGE-ARCHIV.md")
    return [("Wochentermin %s: %s (719)" % (tag, name), ber, wer) for wt, h, wer, name, ber in WOCHENTERMINE
            if jetzt.date() >= datetime.date(2026, 11, 10) and jetzt.weekday() == wt and jetzt.hour >= h and ("Wochentermin %s: %s" % (tag, name)) not in da]

def sammelbuild_faellig():
    """774 (Chef 09.11., 15:29: „wenn jeder auf den anderen wartet …“): warten mindestens 4 fertige Punkte von Tom und Jerry
    ohne Build und hat keiner eine offene Zeile „Sammelbuild“, legt lauf.py --sperre sie beim Team mit den meisten an
    (Gleichstand: Tom). (Titel, Bereich, Besitzer) oder None."""
    zs = zeilen_liste()
    offen = lambda d: d["wort"] not in (None, "erledigt", "verworfen", "aufgeteilt")
    if any(offen(d) and d["titel"].startswith("Sammelbuild") for d in zs):
        return None
    fertig = [d for d in zs if d["besitzer"] in ("Tom", "Jerry") and d["wort"] in ("gebaut", "zu testen")
              and d.get("build") in ("", "–", "-", None) and not d.get("bereich", "").startswith("B ")]
    if len(fertig) < 4:
        return None
    n = {r: [d["nr"] for d in fertig if d["besitzer"] == r] for r in ("Tom", "Jerry")}
    wer = "Jerry" if len(n["Jerry"]) > len(n["Tom"]) else "Tom"
    return ("Sammelbuild: alle fertigen Zweige beider Teams (Tom %s; Jerry %s), Prüfliste ansehen/t<n>, build <n> --mit für jede Nummer (774)"
            % (", ".join(n["Tom"]) or "–", ", ".join(n["Jerry"]) or "–"), "E Technik", wer)

def zeilen_liste():
    global _LISTE
    if _LISTE is None: _LISTE = vorgangsliste()
    return _LISTE

def neu_laden():
    global _LISTE, VORG, _FREMD
    _LISTE = None; _FREMD = None; VORG = vorgaenge()

def archiv():
    """Nummer → Stand aus LISTE-VORGAENGE-ARCHIV.md (altes Format: … | Kosten | Vorrat | Stand |)."""
    tafel = {}
    for z in lesen("LISTE-VORGAENGE-ARCHIV.md").splitlines():
        t = [x.strip() for x in z.split("|")]
        if z.startswith("| ") and len(t) > 7 and t[1] not in ("Nr.",): tafel[t[1]] = t[-2]
    return tafel

def vorgaenge():
    """Nummer → Stand aus Liste und Archiv (die Liste geht vor)."""
    tafel = archiv()
    for d in zeilen_liste():
        if d["nr"] not in SONDER: tafel[d["nr"]] = d["stand"]
    return tafel

VORG = vorgaenge()

def stand_von(nr):
    """72s.1 → 72s.1, 72s, 72: nächste Nummer mit Zeile in Liste oder Archiv."""
    while nr:
        if nr in VORG: return nr, VORG[nr]
        kurz = re.sub(r"(\.\d+[a-z]*|[a-zA-Z])$", "", nr)  # auch Suffix M, T (177M, 72.10a.11T)
        if kurz == nr: break
        nr = kurz
    return None, None

def bekannt(nr):
    return nr in VORG

def chefdateien():
    d = os.path.join(DOCS, "chefsache", "entscheiden")
    return os.listdir(d) if os.path.isdir(d) else []

def chef_datei(nr):
    """Liegt zur Nummer eine Datei in entscheiden/, ansehen/, billigen/ oder tun/ (Name beginnt mit der Nummer ohne Punkte)?"""
    pre = nr.replace(".", "").lower()
    for ordner in CHEF_ORDNER:
        d = os.path.join(DOCS, "chefsache", ordner)
        if os.path.isdir(d) and any(f.lower().startswith(pre + "-") or f.lower().startswith(pre + ".") for f in os.listdir(d)): return True
    return False

# ---------------------------------------------------------------- Zeit

ZEIT = re.compile(r"(?<![\d.])(\d{1,2})\.(\d{1,2})\.,? (\d{1,2}):(\d\d)")

def _zeit(m):
    d = jahr_von(int(m.group(1)), int(m.group(2)))
    return datetime.datetime(d.year, d.month, d.day, int(m.group(3)), int(m.group(4)))

def jahr_von(tag, monat):
    """Datum zu TT.MM.: dieses Jahr, liegt es mehr als ein halbes Jahr zurück, das nächste (Januartermine im Herbst, D28.4)."""
    h = datetime.date.today()
    d = datetime.date(h.year, monat, tag)
    return d if d >= h - datetime.timedelta(days=183) else datetime.date(h.year + 1, monat, tag)

def antworten(text=None):
    """Vorgangsarchiv → {Dateikürzel (348.13a → 34813a): (Nr., Zeit der jüngsten Antwort des Chefs)}; Vorentscheide (→ **Vorentscheid**)
    und Laufzusagen nach 480.1 („- **<Nr>, Läufe frei**“, 1010) zählen nicht."""
    antwort = {}
    for z in (lesen("VORGANGSARCHIV.md") if text is None else text).splitlines():
        m = re.match(r"- \*\*([0-9A-Za-z][0-9A-Za-z.]*?)(?:,|\*\*| )", z)
        t = ZEIT.search(z)
        if not m or not t or z.rstrip().endswith("**Vorentscheid**") or re.match(r"- \*\*[^*]*, Läufe frei\*\*", z): continue
        k = m.group(1).replace(".", "").lower()
        try: w = _zeit(t)
        except ValueError: continue
        if k not in antwort or w > antwort[k][1]: antwort[k] = (m.group(1), w)
    return antwort

def ueberholt(name, inhalt, antwort):
    """Ist die Vorlage name (z. B. 34813a-tusche.md) mit diesem Inhalt laut antwort beantwortet? Zeit aus Zeile 1 oder 2 der Datei."""
    k = name.split("-")[0].lower()
    t = ZEIT.search("\n".join(inhalt.splitlines()[:2]))
    if k not in antwort or not t: return None
    try: seit = _zeit(t)
    except ValueError: return None
    return antwort[k] if antwort[k][1] > seit else None

def beantwortet():
    """383.3 (Chef 27.10., 19:55: „Sachen, die nicht mehr zur Vorlage sind, dann weg“): Vorlagen in entscheiden/, ansehen/, billigen/,
    zu deren Nummer das Vorgangsarchiv eine Antwort des Chefs hat, die jünger ist als die Zeit in Zeile 1 oder 2 der Datei.
    Liefert [(ordner/datei, Nr. im Archiv, Archivzeit)]."""
    antwort = antworten(); aus = []
    for ordner in ("entscheiden", "ansehen", "billigen"):
        d = os.path.join(DOCS, "chefsache", ordner)
        for f in (sorted(os.listdir(d)) if os.path.isdir(d) else []):
            if not f.endswith(".md"): continue
            a = ueberholt(f, open(os.path.join(d, f), encoding="utf-8").read(), antwort)
            if a: aus.append((ordner + "/" + f, a[0], a[1]))
    return aus

# ---------------------------------------------------------------- Feld „wartet auf“ (Automatik A)

DATUM = re.compile(r"^(\d{1,2})\.(\d{1,2})\.(?: (\d{1,2}):(\d\d))?$")
NUMMER = re.compile(r"^D?\d+[A-Za-z0-9.]*$")

def art(token):
    """rolle, chef, datum, nr oder None (ungültig)."""
    if token in WARTE_ROLLEN: return "rolle"
    if re.fullmatch(r"Chef(?: [0-9][0-9a-z.]*)?", token): return "chef"
    if DATUM.match(token): return "datum"
    if re.fullmatch(r"t\d+", token): return "build"  # Test des Builds n: erfüllt mit dem Archiveintrag „- **t<n>“ (Antwort des Chefs)
    if NUMMER.match(token) and not token.endswith("."): return "nr"
    return None

def datum_von(token):
    m = DATUM.match(token)
    d = jahr_von(int(m.group(1)), int(m.group(2)))
    return datetime.datetime(d.year, d.month, d.day, int(m.group(3) or 0), int(m.group(4) or 0))

def erfuellt(token, nr="", streng=False):
    """Ist der Teil des Felds erfüllt? Rolle: nie von selbst. Nummer: für die Sperre auch „gebaut“, „zu testen“ (190.1: Wartende dürfen
    weiterbauen); streng (Automatik A schreibt, D80.3): nur „erledigt“, sonst ginge die Abhängigkeit verloren, wenn der Test scheitert."""
    a = art(token)
    if a == "datum":
        try: return datum_von(token) <= JETZT
        except ValueError: return False
    if a == "chef":
        teile = token.split(" ", 1)
        return not chef_datei(teile[1] if len(teile) > 1 else nr)
    if a == "build":
        return re.search(r"(?m)^- \*\*" + token + r"\b", lesen("VORGANGSARCHIV.md")) is not None
    if a == "nr":
        for d in zeilen_liste():
            if d["nr"] == token: return d["wort"] == "erledigt" if streng else d["wort"] in ("erledigt", "gebaut", "zu testen")
        n, st = stand_von(token)  # Archiv oder Oberzeile (72s.1 → 72)
        if streng: return bool(st) and bool(re.match(r"(fertig|erledigt|auf main|getestet)\b", blank(st), re.I))
        return bool(st) and bool(FERTIG.search(st) or re.match(r"(fertig|erledigt)\b", blank(st), re.I))
    return False

def offen_warte(d):
    return [t for t in d["warte"] if not erfuellt(t, d["nr"])]

GEPRUEFT = re.compile(r"Geprüft an:?\s*(?:https?://\S+|bilder:\S+|`?[0-9a-f]{7,40}`?|Lauf \d{3,})")  # 340.4

def pruefen_zeile(d, alle_nr=None):
    """Formfehler einer Listenzeile (275.2); leer = gut."""
    f = []
    if d.get("spalten") not in (None, len(SPALTEN)): f.append("%d statt %d Spalten" % (d["spalten"], len(SPALTEN)))
    if not d["nr"]: f.append("Nummer fehlt")
    if d.get("besitzer") not in BESITZER: f.append("Besitzer „%s“ (nur %s)" % (d.get("besitzer"), ", ".join(BESITZER)))
    if d.get("kl") not in ("M", "K", "M?", "–"): f.append("Klasse „%s“ (M, K, M?, –)" % d.get("kl"))
    if not d["wort"]: f.append("Stand „%s“ beginnt mit keinem Wort der Liste (%s)" % (d.get("stand"), ", ".join(WORTE)))
    for t in d["warte"]:
        a = art(t)
        if not a: f.append("„wartet auf %s“: nur Nummer, Rolle, Datum TT.MM.[ HH:MM], Test t<Build> oder „Chef[ <Datei>]“" % t)
        elif a == "nr" and alle_nr is not None and t not in alle_nr and stand_von(t)[0] is None: f.append("„wartet auf %s“: Nummer unbekannt" % t)
        elif a == "datum":
            try: datum_von(t)
            except ValueError: f.append("„wartet auf %s“: Datum unlesbar" % t)
        elif a == "rolle" and t == d.get("besitzer"): f.append("„wartet auf %s“: auf sich selbst" % t)
    if d["wort"] in ("wartet", "Chef") and not d["warte"]:
        f.append("„%s“ ohne Feld „wartet auf“ (Test des Chefs: Stand „gebaut“ oder „zu testen“ mit Build; Ereignis ohne Nummer: „ruht“ mit Zusatz)" % d["wort"])
    if d["wort"] == "Chef" and not any(art(t) == "chef" for t in d["warte"]): f.append("„Chef“ ohne „Chef“ im Feld „wartet auf“")
    if d["wort"] == "gebaut" and not GEPRUEFT.search(d.get("stand", "")): f.append("„gebaut“ ohne „Geprüft an: <Link, Lauf oder Commit>“ (340.4, D80.7)")
    if len(d.get("zeile", "")) > 400: f.append("Zeile über 400 Zeichen (Einzelheiten als „Zu %s“ in den Vorrat)" % d["nr"])
    if d["nr"] not in SONDER and not bereiche.gueltig(d.get("bereich")):  # 651: feste Liste
        f.append("Bereich „%s“ nicht in der festen Liste (`python3 tools/bereiche.py`; Vorschlag „%s“)" % (d.get("bereich"), bereiche.einordnen(d.get("bereich"))))
    return f

def pruefen_liste(zs=None):
    """[(Nr, Fehler)] aller Zeilen; doppelte Nummern (außer Pflege, Spiegel je Besitzer)."""
    zs = zeilen_liste() if zs is None else zs
    alle = set(VORG) | {d["nr"] for d in zs}
    aus, gesehen = [], set()
    for d in zs:
        k = (d["nr"], d["besitzer"]) if d["nr"] in SONDER else d["nr"]
        if k in gesehen: aus.append((d["nr"], "doppelt"))
        gesehen.add(k)
        aus += [(d["nr"], x) for x in pruefen_zeile(d, alle)]
    return aus

def loesbar(d):
    """Automatik A: (neues Feld, neuer Stand oder None, erfüllte Teile) oder None, wenn nichts erfüllt ist."""
    if d["wort"] == "erledigt" or not d["warte"]: return None
    weg = [t for t in d["warte"] if erfuellt(t, d["nr"], streng=True)]
    if not weg: return None
    rest = [t for t in d["warte"] if t not in weg]
    stand = None
    if not rest and d["wort"] in ("wartet", "Chef", "ruht", "Dauer"):
        stand = "startbar, gelöst %s: %s" % (JETZT.strftime("%d.%m."), ", ".join(weg))
    return rest, stand, weg

# ---------------------------------------------------------------- Sperre je Zeile

# 424 (Chef 31.10., 21:3x: „keine Energie mehr in das alte SRD-System stecken“): eine sonst startbare Zeile,
# die Regeln des alten Systems nennt, ruht; frei bleiben Zeilen zur Ablösung (Ersatznamen, Glossar, Lizenz)
# und zum Bornimer Rollenspielsystem (BRS, früher Spielsystem 2.0). Absicht des Chefs für Altes: „Chef erlaubt alt“ in die Zeile schreiben.
ALTES_SYSTEM = re.compile(r"\bSRD\b|\b[WwDd]20\b|Rettungsw[uü]rf|Trefferw[uü]rfel|Zauberpl[aä]tz|\bCharisma\b|vier Klassen"
                          r"|Rüstungsklasse|Übungsbonus|\bTalente\b"  # nicht „Kleriker“, „Klasse“: sperrte Aussehen (Schild 406)
                          r"|talente\.gd|klassisch\.gd|core/Rules\.kt|Monsters\.kt")  # D50: Wortliste erweitert (Diogenes Lauf 50)
ALT_FREI = re.compile(r"Spielsystem 2\.0|Bornimer Rollenspielsystem|\bBRS\b|(?<![\d.])2\.0\b|^424\b|Ersatz|Ablösung|ablösen|ohne SRD|Glossar|Lizenz|Chef erlaubt alt"
                      r"|Umzug|Wächter|(?<![\d.])870(\.\d+)?\b")  # D50; 886: Umzug BRS (870) baut das alte System ab, sperrte sonst sich selbst

def altes_system(thema, rest, nr=""):
    t = nr + " " + thema + " " + rest
    return bool(ALTES_SYSTEM.search(t)) and not ALT_FREI.search(t)

def b_gebaut(d):
    """724 A (Chef 09.11., 11:27): Vorgang im Bereich B ist mit dem „greift“ von Diogenes erledigt; „gebaut“ wartet auf Diogenes, nicht auf Test."""
    return d["wort"] == "gebaut" and d.get("bereich", "").startswith("B ")

def sperre(d):
    """Grund, warum die Zeile für ihren Besitzer nicht startbar ist, sonst None."""
    w = d["wort"]
    if w is None: return "UNLESBAR"
    if w == "erledigt": return "ERLEDIGT"
    if w in ("aufgeteilt", "Idee"): return w
    offen = offen_warte(d)
    for t in offen:
        a = art(t)
        if a == "chef": return "Chef (Datei in der Chefsache)"
    for t in offen:
        a = art(t)
        if a == "rolle": return "wartet auf " + t
        if a == "nr":
            n, st = stand_von(t)
            return "wartet auf %s (%s)" % (t, wort_von(st) or st or "Nummer unbekannt")
        if a == "datum": return ("ruht bis " if w == "ruht" else "Termin ") + t
        if a == "build": return "wartet auf Test %s (Chef)" % t
        if a is None: return "wartet auf „%s“ (ungültig)" % t
    if b_gebaut(d): return "wartet auf Diogenes (greift?)"
    if w == "gebaut": return "wartet auf Test/Build (gebaut)"  # 190.1
    if w == "zu testen": return "wartet auf Test (Build%s)" % ((" " + d["build"]) if d.get("build") not in ("", "–", "-", None) else "")
    if w == "ruht" and not d["warte"]: return "ruht" + ((" (" + d["zusatz"][:60] + ")") if d["zusatz"].startswith("424") else "")
    if w == "Dauer" and not d["warte"]: return "Dauerzeile"
    if w in ("wartet", "Chef") and not d["warte"]: return "wartet (ohne Feld „wartet auf“)"
    if w == "nach Meilenstein": return "nach dem Meilenstein"
    m = re.match(r"bei (Spike|Tuffy)\b", d["zusatz"]) if w == "in Arbeit" else None
    if m: return "in Arbeit bei " + m.group(1)  # 433: das Team nimmt die Zeile nicht, lauf.py startet den Zusatzentwickler darauf wieder
    if w in ("startbar", "offen", "in Arbeit", "wartet", "Chef", "ruht", "Dauer") and altes_system(d["titel"], d["stand"], d["nr"]):
        return "ruht (424: altes SRD-System)"
    return None

def blocker(nr, rest=None, chef=None, thema=""):
    """Kompatibel zu früher: Grund der Listenzeile nr, sonst None."""
    for d in zeilen_liste():
        if d["nr"] == nr: return sperre(d)
    return None

# ---------------------------------------------------------------- je Rolle

WIEDERHOLT = re.compile(r"\bwiederholt\b", re.I)
_FREMD = None

def fremd_wartend():
    """Nummer → Rollen, deren offene Muss-Zeile auf diese Nummer wartet (190.3)."""
    global _FREMD
    if _FREMD is not None: return _FREMD
    _FREMD = {}
    besitz = {d["nr"]: d["besitzer"] for d in zeilen_liste()}
    for d in zeilen_liste():
        if d["kl"] != "M" or d["wort"] == "erledigt": continue
        for t in offen_warte(d):
            if art(t) == "nr" and besitz.get(t) not in (None, d["besitzer"]):
                _FREMD.setdefault(t, []).append(d["besitzer"])
    return _FREMD

def jetzt_zeile(d):
    return "„jetzt“" in d["titel"] + d["stand"]

def plan(rolle):
    """[(nr, kl, titel, d, grund)] der Rolle in Vorrangfolge: eigene Zeilen (ohne erledigt), danach fremde, die auf die Rolle warten
    (grund None = startbar). Fremde Zeilen haben d["fuer"] = Besitzer."""
    rolle = ZUSATZ.get(rolle, rolle)
    f = fremd_wartend()
    eigen, fremd = [], []
    for d in zeilen_liste():
        if d["wort"] == "erledigt" or d["nr"] in SONDER and d["besitzer"] != rolle: continue
        if d["besitzer"] == rolle:
            kl = "M" if d["nr"] in f and d["kl"] != "–" else d["kl"]
            eigen.append((d["nr"], kl, d["titel"], d, sperre(d)))
        elif rolle in offen_warte(d) or rolle == "Diogenes" and b_gebaut(d) and not offen_warte(d):  # 724 A
            # die Rolle ist dran, sobald alle übrigen Teile des Felds erfüllt sind (z. B. „Diogenes, 625“: prüfen nach Build 269);
            # ruht die Zeile (ruht, Dauer, nach Meilenstein, aufgeteilt, Idee), ruht sie auch für die Rolle (D80.5)
            rest = [t for t in offen_warte(d) if art(t) != "rolle"]
            w = d["wort"] if d["wort"] in ("ruht", "Dauer", "nach Meilenstein", "aufgeteilt", "Idee") else "startbar"
            grund = sperre(dict(d, wort=w, zusatz=d["zusatz"] if w != "startbar" else "", warte=rest)) if rest or w != "startbar" else None
            fremd.append((d["nr"], d["kl"], d["titel"] + " (für %s)" % d["besitzer"], dict(d, fuer=d["besitzer"]), grund))
    # D80.5: fremde Arbeit hinter der letzten eigenen startbaren Zeile derselben Stufe (Muss, Kür, nach Meilenstein, Pflege), nicht ganz
    # ans Ende; den eigenen Vorrang behält die Rolle, ihre Stelle in einer fremden Reihe kennt die Liste nicht
    def stufe(z):
        if z[0] in SONDER: return 3
        if "fuer" not in z[3] and z[3]["wort"] == "nach Meilenstein": return 2
        return 0 if z[1] == "M" else 1
    zs = list(eigen)
    for z in sorted(fremd, key=lambda x: x[1] != "M"):
        pos = max([k + 1 for k, e in enumerate(zs) if ("fuer" in e[3] or e[4] is None) and stufe(e) <= stufe(z)]
                  or [k + 1 for k, e in enumerate(zs) if stufe(e) < stufe(z)] or [0])
        zs.insert(pos, z)
    w = [z for z in zs if WIEDERHOLT.search(z[2]) and z[1] == "M"]  # D84.2: nur Muss; 620.1 A (Chef 07.11., 21:00): wiederholte Funde vor allem anderen, nur „jetzt“ davor
    if w:
        rest = [z for z in zs if z not in w]
        k = 0
        while k < len(rest) and jetzt_zeile(rest[k][3]): k += 1
        zs = rest[:k] + w + rest[k:]
    n = ungetestet(rolle)
    if n >= GRENZE_UNGETESTET:  # 620.1 B (Chef 08.11., 10:55/10:57): bis zum Test kein neues Muss, außer wiederholt, „jetzt“, Rückläufer
        g = "Sperre 620.1 B: %d ungetestete Muss, erst gemeinsamer Build und Test" % n
        offen = ungetestet_zeilen(rolle)
        def sperre_779(z):  # 779 (Chef 09.11., 17:30): nur Arbeit, die sich mit Ungetestetem überschneidet (Nummer, Ort/Figur im Titel, Datei)
            if not (z[4] is None and z[1] == "M" and "fuer" not in z[3] and neu_gesperrt(z)): return None
            mit = ueberschneidung(z[3], offen)
            return "%s; überschneidet sich mit %s" % (g, mit) if mit else None
        zs = [z[:4] + (sperre_779(z),) if sperre_779(z) else z for z in zs]
    return [z for z in zs if z[1] not in ("–", "-")]

GRENZE_UNGETESTET = 6

def ungetestet(rolle):
    """620.1 B: eigene Muss-Zeilen eines Teams, gebaut oder zu testen; der Sammelbuild selbst (Zweig claude/build-…) zählt nicht."""
    if rolle not in UEBERNAHME: return 0
    return sum(1 for d in zeilen_liste() if d["besitzer"] == rolle and d["kl"] == "M" and d["wort"] in ("gebaut", "zu testen")
               and not (d.get("zweig") or "").startswith("claude/build-"))

def ungetestet_zeilen(rolle):
    return [d for d in zeilen_liste() if d["besitzer"] == rolle and d["kl"] == "M" and d["wort"] in ("gebaut", "zu testen")
            and not (d.get("zweig") or "").startswith("claude/build-")]

# 779: Wörter, die in fast jedem Titel eines Teams stehen und allein keine Überschneidung machen (Dorf, Höhle: ganzes Gebiet eines Teams)
ALLGEMEIN = {"kampf", "mars", "chef", "build", "held", "helden", "gegner", "alt", "neu", "spiel", "test", "idee", "werte", "regel",
             "regeln", "zeile", "fehler", "prüfen", "brs", "text", "texte", "bild", "stand", "kapitel", "nach", "ohne", "statt", "beim",
             "dorf", "höhle", "testmenü", "gibt", "kein", "keine", "allein", "halt", "zurück", "sieht", "wirkt", "zeigt", "läuft", "geht",
             "ganz", "ganze", "sichtbar", "richtig", "bleibt", "nimmt", "macht", "steht", "gegen", "grund", "eine", "einen", "einer", "nicht", "immer", "wieder", "mehr", "auch", "noch", "dann", "aber", "oder", "unter", "über",
             "jede", "jeden", "jeder", "jedes", "einmal", "design", "hinweis"}  # 792: Allerweltswörter ohne Thema (D114.1)

def _woerter(t):
    t = re.sub(r"\([^)]*\)", " ", t)  # Klammern sind meist Herkunft („Chef 07.11., t268“), nicht Inhalt
    t = t.lower().translate(str.maketrans("äöüß", "aous"))
    return {w for w in re.findall(r"[a-z]{4,}", t) if w not in {x.translate(str.maketrans("äöüß", "aous")) for x in ALLGEMEIN}}

BEUGUNG = {"e", "en", "es", "s", "n", "er", "ern", "ens"}
KEIN_NAME = {"greifen", "greife"}  # 970 (b): Verb, nicht der Greif

def _gleich(a, b):
    """Beugung wie „wolf/wolfe“, „aldric/aldrics“, kein Wortteil wie „schwert/schwertarm“ (792); 970 (b): nur echte Endungen,
    also nicht „greift/greif“, „lage/lager“."""
    if a == b: return True
    k, l = sorted((a, b), key=len)
    return len(k) >= 4 and l.startswith(k) and l[len(k):] in BEUGUNG and l not in KEIN_NAME

# 965 (Chef 11.11., 14:56 „hat jeder einen Job?“): Titelwörter zählen nur als Ort oder Figur; Kurzformen, die in den Quellen nur
# zusammengesetzt stehen („Riesenratte“, „Goblin-Späher“)
NAMEN_EXTRA = {"ratte", "ratten", "fledermaus", "spinne", "egel", "schnecke", "hundertfusser", "spaher", "schurke", "grabhund",
               "untote", "lager", "teich", "schenke", "schlagbaum", "lagerfeuer", "kessel", "hutte"}
# Wörter aus Namen wie „Der alte Kael“, „Haus des Ältesten“, „Bauer Bram“, die allein keine Figur und keinen Ort meinen
NAMEN_AUS = {"alte", "bosse", "eigenes", "graue", "grauen", "haus", "norden", "sohn", "tisch", "tiefer", "kapitelende", "schlafenden",
             "handler", "bauer", "bruder", "schwester", "wache", "jager", "hauptmann", "wald"}  # „wald“ auch in WALD_M, Waldläufer
_NAMEN = None

def namen():
    """965: Orte und Figuren von Kapitel 1 aus LISTE-FIGUREN.md (Spalten Figur und Ort) und PROJEKTPLAN.md 2.13–2.16 (Gegner, Orte,
    Stationen, Leute), dazu NAMEN_EXTRA; Wörter wie _woerter."""
    global _NAMEN
    if _NAMEN is None:
        n = set(NAMEN_EXTRA)
        for z in lesen("LISTE-FIGUREN.md").split("## Abnahmelisten")[0].splitlines():
            s = [x.strip() for x in z.strip().strip("|").split("|")]
            if z.startswith("|") and len(s) > 2 and s[0] not in ("Figur",) and not s[0].startswith("---"):
                n |= _woerter(s[0] + " " + s[-1])
        p = lesen("PROJEKTPLAN.md")
        m = re.search(r"\*\*2\.13\*\*(.*?)\*\*2\.17\*\*", p, re.S)
        for x in re.findall(r"\[[ x]\] ([^·:\n(]+)", m.group(1) if m else ""):
            n |= _woerter(x)
        _NAMEN = n - NAMEN_AUS
    return _NAMEN

def _namen_im(t):
    return {w for w in _woerter(t) if any(_gleich(w, n) for n in namen())}

_GIT = {}

def _git(*a):
    """git im Werkzeugordner; gemerkt je Aufruf (startbar ruft dieselben Paare je Rolle mehrfach)."""
    if a not in _GIT:
        import subprocess
        _GIT[a] = subprocess.run(["git", "-C", os.path.dirname(os.path.abspath(__file__))] + list(a), capture_output=True, text=True)
    return _GIT[a]

_DATEIEN = {}

_ZWEIGE = None

def _dateien(zweig):
    """Spieldateien, die die eigenen Commits des Zweigs ändern: Commits, die weder auf main noch auf einem anderen Zweig liegen,
    außer Zweigen, die auf diesem aufbauen (965, 970 (a): sonst teilt jeder gestapelte Zweig alle Dateien seiner Unterlage,
    auch einer, die keine Zeile der Liste trägt)."""
    global _ZWEIGE
    if not zweig or zweig in ("–", "-"): return set()
    if _ZWEIGE is None:  # einmal: alle Commits über main mit Eltern und Dateien, je Commit die Zweige, die ihn enthalten
        eltern, dateien, spitzen, enthalten = {}, {}, {}, {}
        for z in _git("log", "--format=%H %P", "--remotes=origin", "--not", "origin/main").stdout.splitlines():
            h, *p = z.split(); eltern[h] = p
        c = None
        for z in _git("log", "--name-only", "--format=@%H", "--remotes=origin", "--not", "origin/main").stdout.splitlines():
            if z.startswith("@"): c = z[1:]; dateien[c] = set()
            elif z and c: dateien[c].add(z)
        for z in _git("for-each-ref", "--format=%(objectname) %(refname:short)", "refs/remotes/origin").stdout.splitlines():
            h, r = z.split(" ", 1)
            if r.startswith("origin/claude/build-") or r in ("origin", "origin/HEAD") or h not in eltern: continue  # Sammelbuilds tragen fremde Zweige
            spitzen[r[len("origin/"):]] = h
            offen = [h]
            while offen:
                k = offen.pop()
                if r in enthalten.setdefault(k, set()): continue
                enthalten[k].add(r); offen += [e for e in eltern.get(k, []) if e in eltern]
        _ZWEIGE = (spitzen, enthalten, dateien)
    if zweig not in _DATEIEN:
        spitzen, enthalten, dateien = _ZWEIGE
        s = spitzen.get(zweig)
        auf = enthalten.get(s, set())  # Zweige, die auf diesem aufbauen
        eigen = [k for k, r in enthalten.items() if s and ("origin/" + zweig) in r and r <= auf]
        _DATEIEN[zweig] = {f for k in eigen for f in dateien.get(k, ()) if not re.match(r"(\.[^/]+|tools|docs|test|tests)/|.*(_test|test_)[^/]*$|.*\.md$", f)}
    return _DATEIEN[zweig]

def ueberschneidung(d, offen):
    """779: Text „702 (wolf)“ der ersten ungetesteten Zeile, mit der d sich überschneidet: nennt ihre Nummer, teilt einen Ort oder
    eine Figur im Titel (965: nicht mehr jedes Titelwort; Beugung wie _gleich), liegt auf ihrem Zweig (Stapel) oder teilt eine
    eigene geänderte Datei; sonst None."""
    wd = _namen_im(d["titel"]); fd = None
    for o in offen:
        if o["nr"] == d["nr"]: continue
        if re.search(r"(?<![\d.])%s(?![\d])" % re.escape(o["nr"]), d["titel"] + " " + " ".join(d.get("warte") or [])): return o["nr"]
        gleich = sorted(a for a in wd for b in _namen_im(o["titel"]) if _gleich(a, b))
        if gleich: return "%s (%s)" % (o["nr"], gleich[0])
        if d.get("zweig") not in (None, "", "–", "-"):
            oz = o.get("zweig")
            if oz not in (None, "", "–", "-") and oz != d["zweig"] and _dateien(oz) and \
                    _git("merge-base", "--is-ancestor", "origin/" + oz, "origin/" + d["zweig"]).returncode == 0:
                return "%s (Zweig liegt darauf)" % o["nr"]
            fd = _dateien(d["zweig"]) if fd is None else fd
            g = fd & _dateien(oz)
            if g: return "%s (%s)" % (o["nr"], sorted(g)[0].rsplit("/", 1)[-1])
    return None

def neu_gesperrt(z):
    """620.1 B: True für nicht angefangene Arbeit (auch „wartet“ mit erfülltem Feld), weder wiederholt noch „jetzt“ noch Rückläufer."""
    d = z[3]
    if d["wort"] == "in Arbeit": return False
    if d["titel"].startswith("Sammelbuild"): return False  # 774: die Sperre wartet auf diesen Build, darf ihn nicht selbst sperren
    if WIEDERHOLT.search(z[2]) or jetzt_zeile(d): return False
    return d.get("build") in ("", "–", "-", None)

def pause(inhalt):
    """„Pause bis TT.MM.[, HH[:MM] Uhr]“ in den ersten 14 Zeilen: Text, solange der Zeitpunkt nicht erreicht ist (D27.4).
    Nicht lesbares Datum sperrt vorsichtshalber und sagt es."""
    for z in inhalt.splitlines()[:14]:
        m = re.search(r"Pause bis (?:\w{1,3},? )?(\d\d)\.(\d\d)\.(?:,? (\d\d)(?::(\d\d))?(?: Uhr)?)?", z)
        if m:
            try:
                bis = datetime.datetime(JETZT.year, int(m.group(2)), int(m.group(1)), int(m.group(3) or 0), int(m.group(4) or 0))
            except ValueError: return m.group(0)[10:] + " (nicht lesbar)"
            if bis > JETZT: return m.group(0)[10:]
        elif "Pause bis" in z and not re.search(r"Pause bis (?:\w{1,3},? )?\d\d\.\d\d\.", z) and z.lstrip().startswith(("**Pause", "Pause")):
            return z.strip()[:40] + " (Datum nicht lesbar)"
    return None

def pause_frei(inhalt):
    """870.17 (870b A, Chef 10.11., 16:08): „frei für: 870.x, 709, …“ in der Pause-Zeile; diese Nummern bleiben trotz Pause
    startbar („870.x“ = alle 870.<k>), sonst nichts. Ohne Angabe []."""
    for z in inhalt.splitlines()[:14]:
        if "Pause bis" in z:
            m = re.search(r"frei für:?\s*([0-9][0-9A-Za-z., ]*)", z)
            return [x for x in re.split(r"[,\s]+", m.group(1).strip(" .")) if x] if m else []
    return []

def ist_frei(nr, frei):
    return any(nr == f or (f.endswith(".x") and nr.startswith(f[:-1])) for f in frei)

LIEGT_ROLLEN = ["Tom", "Jerry", "Diogenes", "Homer", "Perikles"]  # wie lauf.START_REIHE; Sokrates und Ford startet nie der Vorrat

def startbares_muss():
    """891 (654, Chef 10.11., 17:15): {(Rolle, Nr)} startbarer Muss-Zeilen nach Pause und „frei für“ (wie lauf.stand). Läuft keine
    Sitzung der Rolle, „liegt“ die Zeile: wer sie startbar gemacht hat, meldet es Ford sofort (vorgang.py, LISTE-BETRIEB.md „Meldungen an Ford“)."""
    aus = set()
    for datei, rolle in ROLLEN:
        if rolle not in LIEGT_ROLLEN: continue
        inhalt = lesen(datei)
        m = [z for z in plan(rolle) if z[1] == "M" and not z[4]]
        if pause(inhalt):
            frei = pause_frei(inhalt)
            m = [z for z in m if frei and ist_frei(z[0], frei)]
        aus |= {(rolle, z[0]) for z in m}
    return aus

UEBERNAHME = {"Tom": "Jerry", "Jerry": "Tom"}
GERAET = re.compile(r"Test|Gerät|Build|APK", re.I)

def uebernahme(rolle, info):
    """118/202, 783 W3 (Chef 09.11., 20:13): hat das Team kein startbares Muss, das oberste freie Muss des anderen Teams
    (ohne Gerätetest bevorzugt), vor der eigenen Kür."""
    a = UEBERNAHME[rolle]
    if a not in info or rolle not in info or info[rolle][2]: return None
    frei = [z for z in info[a][0] if "fuer" not in z[3] and z[1] == "M"]
    if not frei: return None
    ohne = [z for z in frei if not GERAET.search(z[2])]
    z = (ohne or frei)[0]
    return "%s %s (Übernahme 118 von Team %s%s)" % (z[0], re.sub(r"\*\*|`", "", z[2])[:60], a, "" if ohne else ", mit Gerätetest")

def loesen(schreiben=False):
    """Automatik A über die ganze Liste: [(Nr, Besitzer, erfüllte Teile, neuer Stand)]; mit schreiben die Liste ändern."""
    aus = []
    p = os.path.join(DOCS, LISTE)
    text = lesen(LISTE); L = text.split("\n")
    for d in vorgangsliste(text):
        r = loesbar(d)
        if not r: continue
        rest, stand, weg = r
        aus.append((d["nr"], d["besitzer"], weg, stand))
        if schreiben:
            n = dict(d, warte=rest)
            if stand: n["stand"] = stand
            L[d["i"]] = zeile_text(n)
    if schreiben and aus:
        open(p, "w", encoding="utf-8").write("\n".join(L)); liste_merken(DOCS); neu_laden()
    return aus

# 827 A, Bau 828 (Chef 10.11., 07:10): „festgefahren“ = zwei Rückläufer des Chefs oder über 30 $ Kosten; jede weitere Sitzung zu so
# einem Vorgang startet lauf.py ab STARK_AB einmal auf STARK_MODELL (Marke „stärkstes Modell TT.MM.“ am Titel); Auswertung nach drei Vorgängen (Sokrates).
# Rückläufer = Marke „zurück t<n>[, t<m>…]“ im Titel: setzt vorgang.py build <n> bei ✗; Funde außerhalb einer Prüfliste von Hand (Build des Chefs).
STARK_AB = datetime.datetime(2026, 11, 14, 20, 0)  # Berliner Zeit
STARK_MODELL = "fable"
STARK_KOSTEN = 30.0
STARK_RUECK = 2
STARK_ROLLEN = ("Tom", "Jerry")  # Bauarbeit (Spike, Tuffy auf deren Zeilen); Beratung und Abläufe starten nicht über die Zeilenregel
STARK_MARKE = re.compile(r"stärkstes Modell \d")  # 827 A: eine Sitzung je Vorgang, danach Auswertung
RUECK = re.compile(r"zurück ((?:t\d+(?:, )?)+)")

def rueck_builds(titel):
    """Builds aus der Marke „zurück t269, t272“ im Titel, sortiert, ohne Doppelte."""
    m = RUECK.search(titel or "")
    return sorted({int(x) for x in re.findall(r"t(\d+)", m.group(1))}) if m else []

def rueck_marke(titel, n):
    """Titel mit Build n in der Marke „zurück …“ (angehängt oder ergänzt)."""
    b = rueck_builds(titel)
    if int(n) in b: return titel
    neu = "zurück " + ", ".join("t%d" % x for x in sorted(b + [int(n)]))
    return RUECK.sub(neu, titel, count=1) if b else "%s · %s" % (titel.rstrip(), neu)

def kosten_wert(k):
    m = re.search(r"\d+(?:,\d+)?", (k or "").replace(".", ""))
    return float(m.group(0).replace(",", ".")) if m else 0.0

def festgefahren(d):
    """Grund („2 Rückläufer (t269, t272)“, „41,37 $“) oder None; nur offene Arbeit."""
    if not d or d.get("besitzer") not in STARK_ROLLEN or d.get("wort") in ("erledigt", "ruht", "Idee", "nach Meilenstein", "Dauer") or d.get("kl") not in ("M", "K", "M?"): return None
    b = rueck_builds(d.get("titel")); k = kosten_wert(d.get("kosten"))
    g = (["%d Rückläufer (%s)" % (len(b), ", ".join("t%d" % x for x in b))] if len(b) >= STARK_RUECK else []) + ([d["kosten"]] if k > STARK_KOSTEN else [])
    return ", ".join(g) or None

def festgefahrene():
    return [(d, festgefahren(d)) for d in zeilen_liste() if festgefahren(d)]

def main():
    alle = "--alle" in sys.argv
    stand = "--stand" in sys.argv
    md = "--md" in sys.argv
    falsch = 0
    info = {}
    if "--liegt" in sys.argv:  # 891: startbares Muss je Rolle; „liegt“, wenn keine Sitzung der Rolle läuft (das weiß nur list_sessions)
        for r, nr in sorted(startbares_muss()): print("LIEGT %s %s (wenn keine Sitzung %s läuft)" % (r, nr, r))
        return
    if "--loesen" in sys.argv:
        for nr, wer, weg, st in loesen(True): print("GELÖST %s (%s): wartet auf %s erfüllt%s" % (nr, wer, ", ".join(weg), (" → " + st) if st else ""))
    if md: print("## Offen je Rolle\n\nVom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand %s; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.\n" % datetime.date.today().strftime("%d.%m."))
    else: print("Startbar am %s (Systemdatum):" % datetime.date.today().strftime("%d.%m."))
    fehler = pruefen_liste()
    if not zeilen_liste():
        print("  UNLESBAR: %s ohne Tabelle (Kopf %s)" % (LISTE, KOPF)); sys.exit(1)
    for datei, rolle in ROLLEN:
        inhalt = lesen(datei)
        zs = plan(rolle)
        sperr = {z[0]: z[4] for z in zs}
        warn = ""
        unles = sorted({nr for nr, _ in fehler if any(d["nr"] == nr and d["besitzer"] == rolle for d in zeilen_liste())})
        if unles: warn += "  UNLESBAR (Liste): " + ", ".join(unles)
        p = pause(inhalt)
        frei = pause_frei(inhalt) if p else []
        if p:  # 889, 892 (D148.1): Pause sperrt jede Zeile, die nicht unter „frei für“ steht, in jeder Ausgabe (auch --md, --stand)
            zs = [z if z[4] or (frei and ist_frei(z[0], frei)) else z[:4] + ("Pause, nicht frei" if frei else "Pause",) for z in zs]
        if frei: p += ", frei für " + ", ".join(frei)  # 870.17
        if md:
            print("**%s** – offen %d, Muss %d, startbar %d%s\n" % (rolle, len(zs), sum(1 for z in zs if z[1] == "M"), sum(1 for z in zs if not z[4]), (", PAUSE bis " + p) if p else ""))
            print("| Nr. | Kl. | Was | Stand |\n|---|---|---|---|")
            for nr, kl, thema, d, grund in zs:
                print("| %s | %s | %s | %s |" % (nr, kl, re.sub(r"\*\*|`|\|", "", thema)[:90].strip(), grund or "startbar"))
            print()
            continue
        if p: print("  %s: PAUSE bis %s%s" % (rolle, p, warn))  # Zahlen und Testzählung laufen weiter
        erstes = {"M": None, "K": None, "N": None}
        sperren = []
        for nr, kl, thema, d, b in zs:
            if b == "nach dem Meilenstein":  # 190.10: letzte Stufe vor Leerlauf
                sperren.append((nr, b))
                if erstes["N"] is None: erstes["N"] = (nr, kl, thema)
                continue
            if b: sperren.append((nr, b)); continue
            art_ = "M" if kl == "M" else "K"
            if erstes[art_] is None: erstes[art_] = (nr, kl, thema)
        if rolle in UEBERNAHME:
            # wie bisher alle eigenen Zeilen, die auf einen Test warten, auch die schon einem Build zugeordneten (D80.6)
            gebaut = sum(1 for z in zs if "fuer" not in z[3] and (z[4] or "").startswith("wartet auf Test"))
            info[rolle] = ([z for z in zs if not z[4]], gebaut, erstes["M"])  # 783 W3: nur eigenes Muss hält die Übernahme
        def kurz(e):
            if not e: return "–"
            return "%s %s%s" % (e[0], re.sub(r"\*\*|`", "", e[2])[:70], (" ↑ Muss: %s wartet" % ", ".join(fremd_wartend()[e[0]])) if e[0] in fremd_wartend() else "")
        if not p or frei: print("  %s: Muss %s | Kür %s%s%s" % (rolle, kurz(erstes["M"]), kurz(erstes["K"]), (" | nach dem Meilenstein " + kurz(erstes["N"])) if erstes["N"] else "", warn))
        if stand:
            print("      offen %d, Muss %d, startbar %d, gesperrt %d" % (len(zs), sum(1 for z in zs if z[1] == "M"), sum(1 for z in zs if not z[4]), len(sperren)))
        if alle:
            for nr, b in sperren: print("      nicht startbar: %s: %s" % (nr, b))
        elif sperren:
            print("      nicht startbar: " + "; ".join("%s: %s" % s for s in sperren[:6]) + (" …" if len(sperren) > 6 else ""))
    if not md:
        mf = ["%s (%s)" % (z[0], rolle) for _, rolle in ROLLEN for z in plan(rolle) if z[1] == "M?" and not z[4]]
        if mf: print("  M? für Perikles (190.8; lauf.py startet es als Muss „M? entscheiden“, 921): " + ", ".join(mf))
        for r in UEBERNAHME:
            u = uebernahme(r, info)
            if u: print("  Übernahme für %s: %s" % (r, u))
        if all(r in info for r in UEBERNAHME) and sum(info[r][1] for r in UEBERNAHME) >= 4:  # 317: ab 4 fertigen Punkten beider Teams bittet der Erste
            print("  Gemeinsamer Build: %s warten auf Test (ab 4 bittet der Erste, dann alle fertigen Zweige ohne Obergrenze; 317, Chef 07.11., 20:5x)%s" % (", ".join("%s %d" % (r, info[r][1]) for r in UEBERNAHME),
                  "".join("; Sperre 620.1 B für %s (%d ungetestete Muss)" % (r, ungetestet(r)) for r in UEBERNAHME if ungetestet(r) >= GRENZE_UNGETESTET)))
        if "--loesen" not in sys.argv:
            for nr, wer, weg, st in loesen(False): print("  GELÖST %s (%s): wartet auf %s erfüllt (schreibt lauf.py --sperre)" % (nr, wer, ", ".join(weg)))
        ff = festgefahrene()
        if ff: print("  Festgefahren (827 A; ab %s nächste Sitzung auf dem stärksten Modell): %s" % (STARK_AB.strftime("%d.%m., %H:%M"), "; ".join("%s %s: %s%s" % (d["nr"], d["besitzer"], g, " (gehabt)" if STARK_MARKE.search(d["titel"]) else "") for d, g in ff)))
        for nr, f in fehler: print("  UNLESBAR %s: %s" % (nr, f))
    sys.exit(1 if fehler else 0)

if __name__ == "__main__":
    main()
