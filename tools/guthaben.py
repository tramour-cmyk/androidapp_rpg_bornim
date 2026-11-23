#!/usr/bin/env python3
"""1804 (1727 Nachprüfung 2 Nr. 6, 12; Profil Disponent „Guthaben“): Guthabenstufe und Laufsperre aus Chefwort für lauf.py.

Guthabenstufe (287): ab 80 % nur Muss, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand. Den Prozentwert kennt nur der Chef;
er nennt ihn Sokrates, Sokrates trägt ihn ein (Archiv 1727e). Ort: die Zeile „**Guthaben:**“ in docs/ARBEIT-BETRIEB.md, neuester
Wert vorn: „**Guthaben:** **Chef TT.MM., HH:MM (…):** „NN Prozent“ …“. Ein Wert vor dem letzten Zurücksetzen (Sa 19:59, RESET)
gilt nicht mehr: Stufe „unbekannt“, gestartet wird wie unter 80 %.

Laufsperre (Chefwort „weniger laufen“): Zeile im Vorgangsarchiv im Format der Ausnahme mit Deckel (nachtstarts.py, 1792):
„- **<Nr>, …** (TT.MM., HH:MM, Chef …) → **Laufsperre: höchstens <Zahl> Starts[, spätestens HH:MM]**“ (Zahl als Ziffer oder Wort,
„keine“ = 0). Umfang und Ende setzt Sokrates (Profil Disponent F15). Ab der Entscheidzeit zählen die Startsperren des Protokolls;
frei sind Wache, Sokrates (auch Rundblick) und Rückläufer des Chefs. Ohne „spätestens“ gilt sie STANDARD_STUNDEN und lauf.py warnt.
Ohne „Chef“ in der Klammer keine Laufsperre. 1930 (1727j Frage 8, Chef 22.11., 11:48): sagt der Chef „alles“, sperrt sie auch die
Rückläufer des Chefs; frei bleiben dann nur Wache und Sokrates (FREI_ROLLEN). 1934 (D371.1): das Werkzeug liest das nicht aus dem
Zitat („alles klar“ stand in 51 von 1184 Archivzitaten), sondern aus der Marke „, auch Rückläufer“ in der fetten Laufsperre nach dem
Pfeil, die Sokrates nur bei diesem Chefwort setzt: „→ **Laufsperre: höchstens zwei Starts, spätestens 18:00, auch Rückläufer**“.

Laufsperre als Obergrenze (2001, Chef 23.11., 14:37; Archiv 287): höchstens N Fachkräfte laufen zugleich, neben der Startzahl:
„→ **Laufsperre: höchstens <Zahl> Fachkräfte zugleich[, nur <Bereiche>][, nachts HH–HH keine][, spätestens TT.MM., HH:MM]**“
(Zahl als Ziffer oder Wort; Bereiche durch Komma oder „und“ wie bereiche.py, „Spiel“ = G Regeln, E Kampf, E Figuren, E Welt;
Eilt darf auch außerhalb der Bereiche und, 2002 (B, Chef 23.11., 15:48), bei N Laufenden noch starten, höchstens N+1; nachts startet
keine Fachkraft, auch nicht Eilt). 2002 (A): eine Fachkraft, deren jüngste Rückmeldung „fertig“ ist und an die kein Rückläufer (Prüfwort außer
„ja“ danach in derselben Vorgangsdatei, 2002-Ü4) ging, zählt nicht (fertige_sitzungen), außer sie arbeitet danach wieder (working,
updated_at nach dem „fertig“, wieder_taetig). Takt, offene Übergaben und Handstart (lauf.py --start) prüfen
dieselbe Bremse.
Läuft = lauf.py „Laufend“ (working/blocked, updated_at unter 60 Minuten, Kopf von lauf.py), nie ARBEIT-BESETZUNG.md; jeder START
dieses Laufs zählt dazu. Frei, zählt nicht (eigene Menge FREI_OBER): Arbeitsplaner, Prüfer, Tester, Wache, Sokrates, Tagesbericht (und
Routinen Sokrates', Disponent, Ford). Ohne „spätestens“ STANDARD_STUNDEN mit Warnung; ohne „Chef“ in der Klammer keine. Beispiel 287:
„→ **Laufsperre: höchstens drei Fachkräfte zugleich, nur Spiel, nachts 23–07 keine, spätestens 28.11., 20:00**“.

Vorbild (erst nachsehen, wie andere es lösen): Budget-Aktionen in Cloud-Konten (Schwellen 80/100 % lösen gestufte Aktionen aus, bis
zum Sperren neuer Starts) und Ausgabegrenzen von CI-Diensten (bei 100 % keine neuen Läufe); beide werten einen Messwert nur in
seinem Abrechnungszeitraum. Obergrenze: Jenkins-Executors (feste Zahl gleichzeitiger Läufe je Knoten, Rest wartet in der Schlange).

  guthaben.py            Stufe und Laufsperre jetzt (Prüfen von Hand)
"""
import datetime, os, re, sys, zoneinfo
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nachtstarts

BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
RESET = (5, 19, 59)  # Sa 19:59 Berliner Zeit (ARBEIT-BETRIEB.md „Guthaben“: „Reset Sa 19:59“)
STUFEN = ((100, "Stillstand"), (95, "nur Rückläufer"), (80, "nur Muss"))
FREI_ROLLEN = {"Sokrates", "Rundblick", "Ideenlauf", "Wache", "Ford"}  # 1907: Ideenlauf ist Sokrates
STANDARD_STUNDEN = 24
FREI_OBER = {"Arbeitsplaner", "Planer", "Perikles", "Prüfer", "Diogenes", "Wache", "Sokrates", "Rundblick", "Ideenlauf", "Tagesbericht",
             "Disponent", "Ford", "Tester"}  # 2001; Tester: 2001-Ü10: frei unter der Obergrenze; FREI_ROLLEN der alten Form bleibt
SPIEL = ("G Regeln", "E Kampf", "E Figuren", "E Welt")  # 2001 (Archiv 287, 22.11., 19:57: „nur Spiel (Regeln, Kampf, Figur, Welt)“)
ZAHLWORT = dict(nachtstarts.ZAHLWORT, keine=0, null=0, keinen=0)


def letzter_reset(jetzt):
    t = jetzt.replace(hour=RESET[1], minute=RESET[2], second=0, microsecond=0) - datetime.timedelta(days=(jetzt.weekday() - RESET[0]) % 7)
    return t if t <= jetzt else t - datetime.timedelta(days=7)


def wert(betrieb, jetzt):
    """(Prozent, Zeit) des neuesten Werts in der Zeile „**Guthaben:**“, oder None (keine Zeile, kein Wert, vor dem Zurücksetzen)."""
    z = next((l for l in betrieb.splitlines() if l.startswith("**Guthaben:**")), "")
    m = re.search(r"Chef (\d\d)\.(\d\d)\., (\d\d):(\d\d)\b[^„]*?„(\d{1,3})(?:,\d+)? ?(?:Prozent|%)", z)
    if not m: return None
    try:
        t = datetime.datetime(jetzt.year, int(m.group(2)), int(m.group(1)), int(m.group(3)), int(m.group(4)), tzinfo=jetzt.tzinfo)
    except ValueError:
        return None
    if t > jetzt + datetime.timedelta(days=1): t = t.replace(year=t.year - 1)  # Jahreswechsel
    if t < letzter_reset(jetzt): return None
    return int(m.group(5)), t


def stufe(betrieb, jetzt):
    """(Stufe, Prozent, Zeit): Stufe „frei“, „nur Muss“, „nur Rückläufer“, „Stillstand“ oder „unbekannt“."""
    w = wert(betrieb, jetzt)
    if not w: return "unbekannt", None, None
    for g, name in STUFEN:
        if w[0] >= g: return name, w[0], w[1]
    return "frei", w[0], w[1]


def laufsperren(archiv, jahr):
    aus = []
    for l in archiv.splitlines():
        if "Laufsperre" not in l: continue
        k = re.search(r"\((\d\d)\.(\d\d)\., (\d\d):(\d\d), Chef\b", l)
        m = re.search(r"Laufsperre:? höchstens (\w+) (?:weitere )?Starts?(?:, spätestens (\d\d):(\d\d))?", l)
        if not k or not m: continue
        z = m.group(1).lower()
        deckel = int(z) if z.isdigit() else ZAHLWORT.get(z)
        if deckel is None: continue
        try:
            ab = datetime.datetime(jahr, int(k.group(2)), int(k.group(1)), int(k.group(3)), int(k.group(4)), tzinfo=BERLIN)
        except ValueError:
            continue
        if m.group(2):
            bis = ab.replace(hour=int(m.group(2)), minute=int(m.group(3)))
            if bis <= ab: bis += datetime.timedelta(days=1)
        else:
            bis = ab + datetime.timedelta(hours=STANDARD_STUNDEN)
        q = re.match(r"- \*\*([^,*]+)", l)
        aus.append(dict(deckel=deckel, ab=ab, bis=bis, ende=bool(m.group(2)), quelle=q.group(1) if q else "?", alles=alles(l)))
    return aus


def alles(zeile):
    """1930/1934: Marke „auch Rückläufer“ in der fetten Laufsperre nach dem Pfeil (setzt Sokrates nur beim Chefwort „alles“);
    ein „alles“ im Zitat allein („alles klar“) sperrt nichts."""
    nach = zeile.split("→", 1)[1] if "→" in zeile else ""
    m = re.search(r"\*\*Laufsperre:?[^*]*\*\*", nach)
    return bool(m and re.search(r",\s*auch Rückläufer\b", m.group(0)))


def laufsperre(jetzt, archiv=None):
    """Geltende Laufsperre (die jüngste) oder None."""
    g = [a for a in laufsperren(nachtstarts.archiv() if archiv is None else archiv, jetzt.year) if a["ab"] <= jetzt <= a["bis"]]
    return max(g, key=lambda a: a["ab"]) if g else None


def obergrenzen(archiv, jahr):
    """2001: Zeilen „→ **Laufsperre: höchstens <Zahl> Fachkräfte zugleich[, nur …][, nachts HH–HH keine][, spätestens …]**“."""
    import bereiche
    aus = []
    for l in archiv.splitlines():
        k = re.search(r"\((\d\d)\.(\d\d)\., (\d\d):(\d\d), Chef\b", l)
        m = re.search(r"→.*?\*\*Laufsperre:? höchstens (\w+) Fachkräfte? zugleich([^*]*)\*\*", l)
        if not k or not m: continue
        z = m.group(1).lower()
        n = int(z) if z.isdigit() else ZAHLWORT.get(z)
        if n is None: continue
        try:
            ab = datetime.datetime(jahr, int(k.group(2)), int(k.group(1)), int(k.group(3)), int(k.group(4)), tzinfo=BERLIN)
        except ValueError:
            continue
        rest = m.group(2)
        nur = re.search(r", nur (.+?)(?=, nachts|, spätestens|$)", rest)
        ber = None
        if nur:
            ber = []
            for w in re.split(r",\s*|\s+und\s+", nur.group(1).strip()):
                if w == "Spiel": ber += SPIEL
                elif bereiche.gueltig(w): ber.append(w)
                else: ber = "unbekannt: " + w; break
            if isinstance(ber, list): ber = tuple(ber)
        na = re.search(r", nachts (\d\d?)[–-](\d\d?) keine", rest)
        sp = re.search(r", spätestens (?:(\d\d)\.(\d\d)\., )?(\d\d):(\d\d)", rest)
        try:
            if sp and sp.group(1):
                bis = datetime.datetime(jahr, int(sp.group(2)), int(sp.group(1)), int(sp.group(3)), int(sp.group(4)), tzinfo=BERLIN)
                if bis < ab - datetime.timedelta(days=180): bis = bis.replace(year=jahr + 1)
            elif sp:
                bis = ab.replace(hour=int(sp.group(3)), minute=int(sp.group(4)))
                if bis <= ab: bis += datetime.timedelta(days=1)
            else:
                bis = ab + datetime.timedelta(hours=STANDARD_STUNDEN)
        except ValueError:
            continue
        q = re.match(r"- \*\*([^,*]+)", l)
        aus.append(dict(n=n, ab=ab, bis=bis, ende=bool(sp), bereiche=ber, nacht=(int(na.group(1)), int(na.group(2))) if na else None,
                        quelle=q.group(1).strip() if q else "?"))
    return aus


def obergrenze(jetzt, archiv=None):
    """2001: geltende Obergrenze (die jüngste) oder None."""
    g = [a for a in obergrenzen(nachtstarts.archiv() if archiv is None else archiv, jetzt.year) if a["ab"] <= jetzt <= a["bis"]]
    return max(g, key=lambda a: a["ab"]) if g else None


def fachkraft(rolle):
    return re.sub(r" \d+$", "", rolle or "") not in FREI_OBER and rolle != "Sonstige"


TITEL_ROLLE = re.compile(r" – \d[0-9a-zA-Z.]*: (Prüfung|Test(?:er)?)\b")


def ober_rolle(rolle, titel):
    """2001-Ü10 (Prüfer 23.11., 15:54): Titel „<Rufname> – <Nr>: Prüfung …“ → Prüfer, „…: Test …“ → Tester, vor der Rolle aus dem
    Vorgang oder einer doppelten Rufnamen-Sperre (kosten.rolle gab für „Hanna – 1675: Prüfung“ Figur); sonst die Rolle."""
    m = TITEL_ROLLE.search(titel or "")
    return rolle if not m else "Prüfer" if m.group(1) == "Prüfung" else "Tester"


def ist_laufend(s, jetzt):
    """lauf.py „Laufend“ (Kopf): working/blocked (oder RUNNING) und updated_at unter 60 Minuten. 2002: eine fertige Sitzung mit Frage
    steht auf blocked und zählte so bis 60 Minuten weiter (Zora 23.11., fertig 14:57)."""
    b = s.get("status_bucket", "")
    u = datetime.datetime.fromisoformat(s["updated_at"].replace("Z", "+00:00"))
    return ("WORKING" in b or "BLOCKED" in b or s.get("session_status") == "SESSION_STATUS_RUNNING") and (jetzt - u).total_seconds() < 3600


RUECK = re.compile(r"(?m)^- \*\*(\d\d)\.(\d\d)\., (\d\d):(\d\d)\*\*, [^\n]*?(?: \(`(session_[^`]*)`\))?:\n> (.*)")
RUECKLAEUFER = {"nein", "nein, Auftrag", "Beleg fehlt", "steckt fest"}  # 2002-Ü4 (Sokrates 23.11., 16:21): jedes Prüfwort außer „ja“


def fertige_sitzungen(texte):
    """2002 (A): Sitzungen, deren jüngste Rückmeldung (über alle Vorgangsdateien) „fertig“ ist, ohne Rückläufer an sie: kein Prüfwort
    außer „ja“ (nein, nein Auftrag, Beleg fehlt, steckt fest; Signalworte wie rueckmeldung.worte) in derselben Datei danach (1739,
    2002-Ü4). Ergebnis {Sitzung: (Monat, Tag, Std, Min) des „fertig“} für wieder_taetig. Nie aus ARBEIT-BESETZUNG.md."""
    import rueckmeldung
    letzte = {}
    for i, t in enumerate(texte):
        for m in RUECK.finditer(t or ""):
            k = (int(m.group(2)), int(m.group(1)), int(m.group(3)), int(m.group(4)))
            if m.group(5) and (m.group(5) not in letzte or k >= letzte[m.group(5)][0]): letzte[m.group(5)] = (k, i, rueckmeldung.worte(m.group(6)))
    aus = {}
    for sid, (k, i, w) in letzte.items():
        if "fertig" not in w: continue
        if any((int(m.group(2)), int(m.group(1)), int(m.group(3)), int(m.group(4))) > k and rueckmeldung.worte(m.group(6)) & RUECKLAEUFER
               for m in RUECK.finditer(texte[i])): continue
        aus[sid] = k
    return aus


def wieder_taetig(s, k):
    """2002-Ü4 (Sokrates 16:21 (2)): fertige Sitzung arbeitet wieder: status_bucket WORKING und updated_at nach dem „fertig“ k
    (Monat, Tag, Std, Min, Berliner Zeit; Jahr aus updated_at, über Silvester ein Jahr zurück). Ohne beides: nicht tätig."""
    if not k or "WORKING" not in s.get("status_bucket", "") or not s.get("updated_at"): return False
    u = datetime.datetime.fromisoformat(s["updated_at"].replace("Z", "+00:00")).astimezone(BERLIN)
    try: f = datetime.datetime(u.year, k[0], k[1], k[2], k[3], tzinfo=BERLIN)
    except ValueError: return False
    if (f - u).days > 180: f = f.replace(year=u.year - 1)
    return u > f + datetime.timedelta(minutes=1)  # Rückmeldung minutengenau: erst nach ihrer Minute


def _laufend(je_rolle, archiviert, fertig=()):
    return [(ober_rolle(r, s.get("title", "")), s) for r, ss in je_rolle.items() for s in ss if s["id"] not in archiviert
            and (s["id"] not in fertig or wieder_taetig(s, fertig.get(s["id"]) if isinstance(fertig, dict) else None)) and s["_info"][1]]


def laufende_fachkraefte(je_rolle, archiviert=(), fertig=()):
    """2001: Zahl laufender Fachkraft-Sitzungen aus der Sitzungsliste von lauf.py (s["_info"] = (Rolle, Laufend, …), Kopf von lauf.py);
    2002 (A): ohne fertige (fertige_sitzungen)."""
    return sum(1 for r, s in _laufend(je_rolle, archiviert, fertig) if fachkraft(r))


def laufende_namen(je_rolle, archiviert=(), fertig=()):
    """2001-Ü10: „<Rufname> (<Rolle>)“ je gezählter Fachkraft, sortiert, für die Zeile LAUFSPERRE."""
    return sorted("%s (%s)" % (re.split(r" – |, | \(", s.get("title", "") or s["id"])[0], r) for r, s in _laufend(je_rolle, archiviert, fertig) if fachkraft(r))


def eilt(zeile):
    return isinstance(zeile, dict) and (bool(zeile.get("eilt")) or "„jetzt“" in zeile.get("titel", "") + zeile.get("stand", ""))


def gezaehlt(sperre, jetzt, protokoll=None, rueck=lambda nr: False):
    """Starts seit Beginn der Laufsperre, ohne freie Rollen und ohne Rückläufer des Chefs (Zuordnung „<Rolle> <Nr>“ in der Klammer)."""
    p = protokoll if protokoll is not None else nachtstarts.zeilen(sperre["ab"])
    n = 0; gesehen = set()
    for l in p:
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (\w+(?:, \w+)*)(.*)", l)
        if not m: continue
        k = re.match(r"- \d\d:\d\d (\d\d)\.(\d\d)\.:", l)
        try:
            t = jetzt.replace(day=int(k.group(1)), month=int(k.group(2))) if k else jetzt
            t = t.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        except ValueError:
            continue
        if t < sperre["ab"] or t > jetzt + datetime.timedelta(minutes=5) or (t, m.group(3)) in gesehen: continue
        gesehen.add((t, m.group(3)))
        nr_je = dict(re.findall(r"\b(\w+) (\d[0-9a-zA-Z.]*[0-9a-zA-Z]|\d)\b", m.group(4)))
        for r in m.group(3).split(", "):
            if r in FREI_ROLLEN or (not sperre.get("alles") and r in nr_je and rueck(nr_je[r])): continue
            n += 1
    return n


def ruecklaeufer(d):
    """Rückläufer des Chefs: Marke „zurück t<n>“ im Titel (827 A), „Rückläufer“ im Stand, „wiederholt“ (620.1 A) oder Fund des Chefs."""
    if not isinstance(d, dict): return False
    t = d.get("titel", ""); s = d.get("stand", "")
    return bool(re.search(r"zurück t\d", t) or "Rückläufer" in s or re.search(r"\bwiederholt\b", t, re.I)
                or re.search(r"Von Chef \([^)]*\bFund\b", t))


class Bremse:
    """Ein Lauf von lauf.py: erlaubt(rolle, nr, kl, zeile) → None oder Grund; zaehle() nach jedem START/WEITER."""

    def __init__(self, jetzt, betrieb, archiv=None, protokoll=None, rueck=lambda nr: False, laufend=None):
        self.stufe, self.prozent, self.zeit = stufe(betrieb, jetzt)
        if archiv is None: archiv = nachtstarts.archiv()
        self.jetzt = jetzt
        self.sperre = laufsperre(jetzt, archiv)
        self.ober = obergrenze(jetzt, archiv)  # 2001
        self.laufend = laufend  # 2001: laufende Fachkräfte (lauf.py setzt es nach der Sitzungsliste); None = unbekannt
        self.namen = None  # 2001-Ü10: wer gezählt ist (lauf.py), für die Zeile LAUFSPERRE
        self.rest = None
        if self.sperre:
            self.rest = self.sperre["deckel"] - gezaehlt(self.sperre, jetzt, protokoll, rueck)

    def zeilen(self):
        aus = []
        if self.stufe == "unbekannt":
            aus.append("GUTHABEN unbekannt seit dem Zurücksetzen (Sa 19:59): Stufe wie unter 80 %; den Wert nennt der Chef Sokrates (1727e, 287)")
        else:
            aus.append("GUTHABEN %d %% (Chef %s): Stufe %s (287)" % (self.prozent, self.zeit.strftime("%d.%m., %H:%M"), self.stufe))
        if self.sperre:
            s = self.sperre
            aus.append("LAUFSPERRE %s (Chef %s): noch %d von %d Starts bis %s; frei: %s; lauf.py jeden Takt, nur START-Zeilen ruhen (1978)%s" % (
                s["quelle"], s["ab"].strftime("%d.%m., %H:%M"), max(self.rest, 0), s["deckel"], s["bis"].strftime("%d.%m., %H:%M"), self.frei_text(),
                "" if s["ende"] else "; WARNUNG Ende fehlt, gilt %d h, Sokrates setzt „spätestens HH:MM“" % STANDARD_STUNDEN))
        if self.ober:
            o = self.ober
            aus.append("LAUFSPERRE %s (Chef %s): höchstens %d Fachkräfte zugleich, %s%s%s, bis %s; frei: Arbeitsplaner, Prüfer, Tester, Wache, Sokrates, Tagesbericht (2001)%s" % (
                o["quelle"], o["ab"].strftime("%d.%m., %H:%M"), o["n"], "? laufen" if self.laufend is None else "%d laufen%s" % (self.laufend, " (%s)" % ", ".join(self.namen) if self.namen else ""),
                ", nur %s und Eilt" % self.ber_text() if o["bereiche"] else "", ", nachts %02d–%02d keine" % o["nacht"] if o["nacht"] else "",
                o["bis"].strftime("%d.%m., %H:%M"), "" if o["ende"] else "; WARNUNG Ende fehlt, gilt %d h, Sokrates setzt „spätestens TT.MM., HH:MM“" % STANDARD_STUNDEN))
        return aus

    def ber_text(self):
        b = self.ober["bereiche"]
        return "Spiel" if b == SPIEL else b if isinstance(b, str) else ", ".join(b)

    def nachts(self):
        n = self.ober and self.ober["nacht"]
        if not n: return False
        h = self.jetzt.hour
        return (n[0] <= h or h < n[1]) if n[0] > n[1] else n[0] <= h < n[1]

    def ober_grund(self, rolle, zeile):
        """2001: None oder Grund, warum die Obergrenze diesen Start einer Fachkraft anhält."""
        o = self.ober
        if not o or not fachkraft(rolle): return None
        q = "Laufsperre %s (bis %s)" % (o["quelle"], o["bis"].strftime("%d.%m., %H:%M"))
        if self.nachts(): return "%s: nachts %02d–%02d keine Fachkräfte" % ((q,) + o["nacht"])
        if isinstance(o["bereiche"], str): return "%s: Bereich %s, Zeile unklar, kein Start" % (q, o["bereiche"])
        if o["bereiche"] and not eilt(zeile) and (not isinstance(zeile, dict) or zeile.get("bereich") not in o["bereiche"]):
            return "%s: nur %s und Eilt, Zeile %s" % (q, self.ber_text(), zeile.get("bereich") or "ohne Bereich" if isinstance(zeile, dict) else "fehlt")
        if self.laufend is None: return "%s: Zahl laufender Fachkräfte unbekannt, kein Start" % q
        if self.laufend >= o["n"] + (1 if eilt(zeile) else 0):  # 2002 (B): Eilt bis N+1
            return "%s: höchstens %d Fachkräfte zugleich%s, %d laufen" % (q, o["n"], ", Eilt eine mehr" if eilt(zeile) else "", self.laufend)
        return None

    def frei_text(self):
        return "Wache, Sokrates (Chef „alles“: auch Rückläufer gesperrt, 1930)" if self.sperre and self.sperre.get("alles") else "Wache, Sokrates, Rückläufer des Chefs"

    def rueck_frei(self, zeile):
        """Rückläufer des Chefs zählt nicht und läuft weiter, außer die Laufsperre trägt das Chefwort „alles“ (1930)."""
        return ruecklaeufer(zeile) and not (self.sperre and self.sperre.get("alles"))

    def nur_muss(self):
        return self.stufe in ("nur Muss", "nur Rückläufer", "Stillstand")

    def erlaubt(self, rolle, kl, zeile):
        """None = Start erlaubt, sonst Grund für „NICHTS <Rolle>: …“."""
        frei = rolle in FREI_ROLLEN
        rueck = ruecklaeufer(zeile)
        if self.stufe == "Stillstand":
            return "Guthaben %d %%, Stillstand (287)" % self.prozent
        if self.stufe == "nur Rückläufer" and not rueck:
            return "Guthaben %d %%, nur Rückläufer des Chefs (287)" % self.prozent
        if self.stufe == "nur Muss" and kl != "M" and not rueck:
            return "Guthaben %d %%, nur Muss (287)" % self.prozent
        if self.sperre and not frei and not self.rueck_frei(zeile) and self.rest <= 0:
            return "Laufsperre %s, alle %d Starts verbraucht, bis %s nur %s" % (
                self.sperre["quelle"], self.sperre["deckel"], self.sperre["bis"].strftime("%d.%m., %H:%M"), self.frei_text())
        return self.ober_grund(rolle, zeile)

    def zaehle(self, rolle, zeile):
        if self.sperre and rolle not in FREI_ROLLEN and not self.rueck_frei(zeile): self.rest -= 1
        if self.ober and self.laufend is not None and fachkraft(rolle): self.laufend += 1  # 2001


if __name__ == "__main__":
    j = datetime.datetime.now(BERLIN)
    d = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "ARBEIT-BETRIEB.md")
    print("\n".join(Bremse(j, open(d, encoding="utf-8").read()).zeilen()))
