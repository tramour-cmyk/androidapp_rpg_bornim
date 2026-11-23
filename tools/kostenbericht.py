#!/usr/bin/env python3
"""Kostenauswertung je Bereich, Teilbereich, Tag und Woche (651, Chef 08.11., 13:29: „einige Einträge, wo kein Bereich
hinterlegt ist … Kosten trotzdem noch grob … ermitteln … auswerten, so auf Bereiche, Teilbereiche, Kosten, pro Tag, Kosten je Woche“).

Weg (Schätzung, nicht Rechnung): jede gebuchte Sitzung (`docs/KOSTEN-GEBUCHT.tsv`, Kennung → usage.cost_usd) verteilt ihre
Kosten zu gleichen Teilen auf ihre Commits (Zeile „Claude-Session: …“, alle Zweige auf origin, ohne Mischcommits). Ein Commit
gehört zum Vorgang, dessen Nummer vorn in der Betreffzeile steht („Tom: 623.6 …“; Unternummer ohne eigene Zeile → Elternnummer),
sein Datum ist der Tag des Commits (Berliner Zeit). Bereich = Feld der Zeile in der Vorgangsliste oder im Archiv, eingeordnet
in die feste Liste (`tools/bereiche.py`); Commit ohne Nummer oder mit unbekannter: Bereich nach Rolle (Ford → B Steuerung …).
Sitzungen, deren Commits meist von Ford sind, gehen ganz auf Vorgang „Betrieb“ (wie in der Liste). Sitzungen ohne Commit stehen gesondert. Die Spalte „Kosten“ der Liste (von Ford beim Neustart gebucht) läuft zum Vergleich mit.

1739 (1727, Archiv „Qualität eigener Kostenteil“ 20.11., 09:45; Gesamtbild 6d Nr. 6): Wochen und Tage zusätzlich in drei Teilen
nach Bereich: Spiel (E, G), Qualität (Q), Verwaltung (B, M); dazu Qualitätskosten Prüfen gegen Nacharbeit. Nacharbeit = Commits
nach einem „nein“ in docs/vorgang/<Nr>.md (Rückmeldung, 1763), Commits zu einem Erstfund des Chefs (Titel „Von Chef …“ bzw. „Chef
TT.MM.“ mit „Fund“) oder zu einem Rückläufer (Titel oder Stand), Commits „Rückläufer“, „Revert“ und Testpunkte „t82.3 …“; Prüfen =
übrige Kosten im Bereich Q. Nacharbeit zählt in ihrem Bereich weiter (Spiel, Qualität oder Verwaltung), die Qualitätskosten sind
ein Querschnitt, keine vierte Summe.

Aufruf: python3 tools/kostenbericht.py [--ohne-holen] [--schreiben]   (holt vorher alle Zweige claude/*; Ausgabe Markdown,
        mit --schreiben nach docs/LISTE-KOSTEN.md wie gegenstaende.py; danach committen und pushen)
"""
import collections
import datetime
import os
import re
import subprocess
import sys
import zoneinfo

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bereiche  # noqa: E402
import chef_fund  # noqa: E402
import startbar  # noqa: E402

REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DOCS = os.path.join(REPO, "docs")
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
NR = r"[A-Za-z]?\d+[a-z]?(?:\.\d+[a-z]?)*"
ROLLE_BEREICH = {"Ford": "B Steuerung", "Perikles": "B Abläufe", "Sokrates": "M Markt", "Diogenes": "Q QM", "Homer": "G Story",
                 "Tom": "E Technik", "Jerry": "E Technik", "Spike": "E Technik", "Tuffy": "E Technik", "Text": "G Story",
                 "Chefsache": "B Abläufe", "Lauf": "B Steuerung", "Betrieb": "B Steuerung", "Kosten": "B Steuerung",
                 "Werkzeug": "B Werkzeuge", "Build": "Q QS", "Rückläufer": "Q QS", "Revert": "Q QS", "Prüfung": "Q QM",
                 "Messung": "E Technik", "Godot": "E Technik", "Bestand": "E Technik", "Behebung": "E Technik", "Restrunde": "E Figuren"}
TEILE = (("Spiel", "EG"), ("Qualität", "Q"), ("Verwaltung", "BM"))  # 1739, Archiv 20.11., 09:45
NACHARBEIT_BETREFF = re.compile(r"\b(?:Rückläufer|Revert)\b|^\s*(?:\w+:\s*)?t\d+(?:\.\d+)*\b")
TESTPUNKT = re.compile(r"\bt\d+(?:\.\d+)*\b")  # „t82.3 Rückläufer“: Test des Chefs → Q QS


def git(*a):
    return subprocess.run(["git", "-C", REPO, *a], capture_output=True, text=True).stdout


def gebucht():
    aus = {}
    for z in open(os.path.join(DOCS, "KOSTEN-GEBUCHT.tsv"), encoding="utf-8"):
        t = z.strip().split("\t")
        if len(t) >= 2 and t[0].startswith("session_"):
            try:
                aus[t[0]] = float(t[1].replace(",", "."))
            except ValueError:
                pass
    return aus


def vorgaenge():
    """Nr → (Bereich fest, Kosten laut Liste oder None, Titel, Nacharbeit: Erstfund des Chefs oder Rückläufer)."""
    aus = {}
    for dat in ("LISTE-VORGAENGE-ARCHIV.md", "LISTE-VORGAENGE.md"):  # offene Liste gilt vor dem Archiv
        for t in startbar.tafel_zeilen(open(os.path.join(DOCS, dat), encoding="utf-8").read()):
            if t.get("nr") in startbar.SONDER:
                continue
            zahlen = [float(z.replace(",", ".")) for z in re.findall(r"(\d+(?:,\d+)?)\s*\$?", t.get("kosten", "") or "")]
            titel = t.get("titel", "")
            nach = (chef_fund.vom_chef(titel) and bool(re.search(r"\bFund", titel))) or "Rückläufer" in titel + " " + (t.get("stand") or "")
            aus[t["nr"]] = (bereiche.einordnen(t.get("bereich")), sum(zahlen) if zahlen else None, titel, nach)
    return aus


def nummer(betreff, bekannt):
    """Erste bekannte Vorgangsnummer der Betreffzeile (vorn zuerst, sonst in den ersten 80 Zeichen); Zahlen nach Build, Lauf,
    Runde, Test, Chef-Uhrzeiten und Testpunkte „t82.3“ zählen nicht."""
    kopf = re.sub(r"\b(?:Build|Lauf|Läufe|Runde|Test|PR\s*#|Version|Release)\s+\d+[a-z]?\b|\b\d\d:\d\d\b|\b\d\d\.\d\d\.|\bt\d+(?:\.\d+)*", " ",
                  betreff[:80])
    for m in re.finditer(r"(?<![\w.#])(" + NR + r")(?![\w])", kopf):
        nr = m.group(1)
        while nr not in bekannt and "." in nr:
            nr = nr.rsplit(".", 1)[0]
        if nr not in bekannt:
            nr = re.sub(r"[a-z]$", "", nr)
        if nr in bekannt:
            return nr
    return None


def commits():
    """[(Sitzung, Tag, Rolle, Betreff, Zeitpunkt)] aller Commits mit Sitzungszeile."""
    roh = git("log", "--all", "--no-merges", "--format=%H%x1f%aI%x1f%s%x1f%(trailers:key=Claude-Session,valueonly,separator=;)%x1e")
    aus = []
    for satz in roh.split("\x1e"):
        t = satz.strip().split("\x1f")
        if len(t) < 4 or not t[3]:
            continue
        zp = datetime.datetime.fromisoformat(t[1]).astimezone(BERLIN)
        tag = zp.date()
        rolle = (re.match(r"\s*([\wÄÖÜäöü]+)", t[2]) or [None, ""])[1]
        for s in set(re.findall(r"session_\w+", t[3])):
            aus.append((s, tag, rolle, t[2], zp))
    return aus


def erstes_nein(heute):
    """Nr → Zeitpunkt des ersten „nein“ (auch „nein, Auftrag“, „wirkt nein“) in docs/vorgang/<Nr>.md (Rückmeldungen, 1763).
    Zeit dort ohne Jahr („21.11., 20:41“): Jahr des Berichts, liegt sie dann in der Zukunft, das Vorjahr."""
    import rueckmeldung as rm
    import uebergabe as ue
    aus, ordner = {}, os.path.join(REPO, "docs", "vorgang")
    for f in sorted(os.listdir(ordner)) if os.path.isdir(ordner) else []:
        if not f.endswith(".md"):
            continue
        text = open(os.path.join(ordner, f), encoding="utf-8").read()
        for m in rm.BLOCK.finditer(ue.abschnitt(text, "Rückmeldungen")):
            if not {"nein", "nein, Auftrag", "wirkt nein"} & rm.worte(m.group("text")):
                continue
            z = re.match(r"\s*(\d\d?)\.(\d\d?)\.(?:(\d{4}))?,?\s*(\d\d?):(\d\d)", m.group("zeit"))
            if not z:
                continue
            j = int(z[3] or heute.year)
            zp = datetime.datetime(j, int(z[2]), int(z[1]), int(z[4]), int(z[5]), tzinfo=BERLIN)
            if not z[3] and zp > heute:
                zp = zp.replace(year=j - 1)
            aus[f[:-3]] = min(zp, aus.get(f[:-3], zp))
    return aus


def ist_nacharbeit(nr, betreff, zp, vg, nein):
    """1739: Nacharbeit (Qualitätskosten) statt erster Arbeit oder Prüfen."""
    if NACHARBEIT_BETREFF.search(betreff):
        return True
    if nr and nr in vg and vg[nr][3]:
        return True
    return bool(nr and nr in nein and zp > nein[nr])


def teil_von(d):
    """Bereichsbuchstabe → Kosten je Teil (Spiel, Qualität, Verwaltung); unbekannte Buchstaben in keinem Teil."""
    return {name: sum(d.get(b, 0) for b in bs) for name, bs in TEILE}


def ford_sitzungen():
    """Kennung → Starttag aller Ford-Sitzungen aus dem Verlauf von ARBEIT-BETRIEB.md („Ford lebt in einer Sitzung …“; 685):
    eine gebuchte Ford-Sitzung ohne Commit mit Sitzungszeile geht so trotzdem auf „Betrieb“ (D88.1)."""
    aus = {}
    roh = git("log", "--reverse", "-p", "--format=\x1e%aI", "--", "docs/ARBEIT-BETRIEB.md")
    for satz in roh.split("\x1e")[1:]:
        kopf, _, rest = satz.partition("\n")
        tag = datetime.datetime.fromisoformat(kopf.strip()).astimezone(BERLIN).date()
        for z in rest.splitlines():
            if z.startswith("+") and "Ford lebt in einer Sitzung" in z:
                for s in re.findall(r"session_\w+", z):
                    aus.setdefault(s, tag)
    return aus


def geld(x):
    return f"{x:,.0f} $".replace(",", ".") if x >= 100 else f"{x:.2f} $".replace(".", ",")


def tabelle(kopf, zeilen):
    return "\n".join(["| " + " | ".join(kopf) + " |", "|" + "---|" * len(kopf)] + ["| " + " | ".join(z) + " |" for z in zeilen])


def main():
    if "--ohne-holen" not in sys.argv:
        subprocess.run(["git", "-C", REPO, "fetch", "-q", "origin", "+refs/heads/claude/*:refs/remotes/origin/claude/*",
                        "+refs/heads/main:refs/remotes/origin/main"], capture_output=True, timeout=300)
    kosten, vg = gebucht(), vorgaenge()
    je_sitzung = collections.defaultdict(list)
    for c in commits():
        if c[0] in kosten:
            je_sitzung[c[0]].append(c)
    bereich_k = collections.defaultdict(float)
    vorgang_k = collections.defaultdict(float)
    tag_k = collections.defaultdict(lambda: collections.defaultdict(float))
    ohne_nr = 0.0
    heute = datetime.datetime.now(BERLIN)
    nein = erstes_nein(heute)
    qk = collections.defaultdict(lambda: collections.defaultdict(float))  # Montag → {"Prüfen", "Nacharbeit"}
    for s, cs in je_sitzung.items():
        teil = kosten[s] / len(cs)
        rollen = collections.Counter(c[2] for c in cs)
        ford = rollen.most_common(1)[0][0] in ("Ford", "Betrieb", "Lauf")  # Fords Läufe auf Vorgang „Betrieb“ (FIRMA.md, Preis je Vorgang)
        for _, tag, rolle, betreff, zp in cs:
            nr = ("Betrieb" if "Betrieb" in vg else None) if ford else nummer(betreff, vg)
            b = vg[nr][0] if nr else ("Q QS" if TESTPUNKT.match(betreff.strip()) else ROLLE_BEREICH.get(rolle, "? unbekannt"))
            if b.startswith("?"):
                b = ROLLE_BEREICH.get(rolle, "? unbekannt")
            if nr:
                vorgang_k[nr] += teil
            else:
                ohne_nr += teil
            bereich_k[b] += teil
            tag_k[tag][b[:1]] += teil
            mo = tag - datetime.timedelta(days=tag.weekday())
            if ist_nacharbeit(nr, betreff, zp, vg, nein):
                qk[mo]["Nacharbeit"] += teil
            elif b[:1] == "Q":
                qk[mo]["Prüfen"] += teil
    ford_ohne = {s: t for s, t in ford_sitzungen().items() if s in kosten and s not in je_sitzung}
    for s, tag in ford_ohne.items():  # 685: Ford-Sitzung ohne Commit mit Sitzungszeile → Betrieb, Tag = Start der Sitzung
        if "Betrieb" in vg:
            vorgang_k["Betrieb"] += kosten[s]
        bereich_k["B Steuerung"] += kosten[s]
        tag_k[tag]["B"] += kosten[s]
        je_sitzung[s] = []
    summe = sum(kosten.values())
    zugeordnet = sum(bereich_k.values())
    ohne_commit = [s for s in kosten if s not in je_sitzung]
    liste_k = collections.defaultdict(float)
    for nr, (b, k, _, _) in vg.items():
        if k:
            liste_k[b] += k
    liste_summe = sum(liste_k.values())
    themen = list(bereiche.BEREICHE)
    out = [f"# Kosten je Bereich, Tag und Woche (651)", "",
           f"Erzeugt {heute:%d.%m., %H:%M} mit `python3 tools/kostenbericht.py` (nicht von Hand ändern; neu erzeugen). "
           "**Schätzung**, keine Rechnung: API-Preis je Sitzung (`KOSTEN-GEBUCHT.tsv`) zu gleichen Teilen auf ihre Commits verteilt; "
           "Bereich aus dem Vorgang (feste Liste `tools/bereiche.py`), Tag aus dem Commit. Weg und Grenzen im Kopf des Werkzeugs.", "",
           f"**Gebucht:** {geld(summe)} in {len(kosten)} Sitzungen · **über Commits zugeordnet:** {geld(zugeordnet)} "
           f"({round(100 * zugeordnet / summe) if summe else 0} %), davon {geld(ohne_nr)} an Commits ohne Vorgangsnummer (Bereich nach Rolle) · "
           f"davon {len(ford_ohne)} Ford-Sitzungen ohne Commit mit Sitzungszeile, {geld(sum(kosten[s] for s in ford_ohne))}, nach Startdatum auf „Betrieb“ (685) · "
           f"**ohne Commit:** {len(ohne_commit)} Sitzungen, {geld(sum(kosten[s] for s in ohne_commit))} (keinem Bereich zuzuordnen) · "
           f"**Spalte „Kosten“ der Liste:** {geld(liste_summe)} in {sum(1 for v in vg.values() if v[1])} von {len(vg)} Zeilen. "
           "Laufende Sitzungen zählen erst, wenn Ford sie beim Neustart bucht: der laufende Tag und die laufende Woche sind zu niedrig.", "",
           "## Je Bereich und Teilbereich", ""]
    zeilen = []
    for b in themen:
        name, teile = bereiche.BEREICHE[b]
        hs = sum(v for k, v in bereich_k.items() if k[:1] == b)
        ls = sum(v for k, v in liste_k.items() if k[:1] == b)
        zeilen.append([f"**{b} {name}**", f"**{geld(hs)}**", f"**{round(100 * hs / zugeordnet) if zugeordnet else 0} %**", geld(ls)])
        for t in teile:
            k = f"{b} {t}"
            zeilen.append([f"{k} ({bereiche.ERKLAERUNG.get(k, '')})", geld(bereich_k.get(k, 0)),
                           f"{round(100 * bereich_k.get(k, 0) / zugeordnet) if zugeordnet else 0} %", geld(liste_k.get(k, 0))])
    rest = {k: v for k, v in bereich_k.items() if k not in bereiche.alle()}
    for k, v in rest.items():
        zeilen.append([k, geld(v), f"{round(100 * v / zugeordnet)} %", geld(liste_k.get(k, 0))])
    out += [tabelle(["Bereich", "geschätzt", "Anteil", "laut Liste"], zeilen), ""]
    # Wochen (Mo–So)
    wochen = collections.defaultdict(lambda: collections.defaultdict(float))
    for tag, d in tag_k.items():
        mo = tag - datetime.timedelta(days=tag.weekday())
        for b, v in d.items():
            wochen[mo][b] += v
    kopf = ["Woche"] + [f"{b} {bereiche.BEREICHE[b][0]}" for b in themen] + ["zusammen"] + [f"{n} ({', '.join(bs)})" for n, bs in TEILE]

    def zeile(titel, d):
        ges = sum(d.values())
        return [titel] + [geld(d.get(b, 0)) for b in themen] + [f"**{geld(ges)}**"] + [
            f"{geld(v)} ({round(100 * v / ges) if ges else 0} %)" for v in teil_von(d).values()]
    out += ["## Je Woche (Montag bis Sonntag)", "",
            tabelle(kopf, [zeile(f"{mo:%d.%m.}–{mo + datetime.timedelta(days=6):%d.%m.}", wochen[mo]) for mo in sorted(wochen, reverse=True)]), ""]
    qzeilen = []
    for mo in sorted(set(wochen) | set(qk), reverse=True):
        q, ges = qk[mo], sum(wochen[mo].values())
        qs = q["Prüfen"] + q["Nacharbeit"]
        qzeilen.append([f"{mo:%d.%m.}–{mo + datetime.timedelta(days=6):%d.%m.}", geld(q["Prüfen"]), geld(q["Nacharbeit"]), f"**{geld(qs)}**",
                        f"{round(100 * q['Nacharbeit'] / qs) if qs else 0} %", f"{round(100 * qs / ges) if ges else 0} %"])
    out += ["## Qualitätskosten je Woche: Prüfen gegen Nacharbeit (1739)", "",
            "Prüfen = Kosten im Bereich Q ohne Nacharbeit; Nacharbeit = Commits nach einem „nein“ der Rückmeldungen (`docs/vorgang/`), "
            "zu Erstfunden des Chefs und Rückläufern, „Revert“ und Testpunkte, in jedem Bereich. Querschnitt, keine vierte Summe.", "",
            tabelle(["Woche", "Prüfen", "Nacharbeit", "zusammen", "Anteil Nacharbeit", "Anteil an der Woche"], qzeilen), ""]
    kopf[0] = "Tag"
    out += ["## Je Tag", "", tabelle(kopf, [zeile(f"{['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][t.weekday()]} {t:%d.%m.}", tag_k[t])
                                            for t in sorted(tag_k, reverse=True)]), ""]
    # Vorgänge ohne Betrag in der Liste
    fehlt = sorted(((nr, v) for nr, v in vorgang_k.items() if not vg[nr][1]), key=lambda x: -x[1])
    out += [f"## Vorgänge ohne Betrag in der Liste, geschätzt ({len(fehlt)} Vorgänge, {geld(sum(v for _, v in fehlt))})", "",
            tabelle(["Vorgang", "Bereich", "geschätzt", "Titel"], [[nr, vg[nr][0], geld(v), vg[nr][2][:70]] for nr, v in fehlt[:25]]),
            "", f"Weitere {max(0, len(fehlt) - 25)} unter 25 Plätzen; ganz ohne Commit und ohne Betrag: "
            f"{sum(1 for nr, v in vg.items() if not v[1] and nr not in vorgang_k)} Zeilen.", ""]
    # Abgleich
    diff = sorted(((nr, (vg[nr][1] or 0) - vorgang_k.get(nr, 0)) for nr in vg if vg[nr][1]), key=lambda x: -abs(x[1]))
    out += ["## Abgleich Liste gegen Schätzung (größte Abweichungen)", "",
            f"Liste {geld(liste_summe)}, gebucht {geld(summe)}: die Liste bucht eine Sitzung auf die Vorgänge ihres Titels (mehrere zu gleichen "
            "Teilen), die Schätzung nach Commits; Beträge aus der Zeit vor `KOSTEN-GEBUCHT.tsv` oder doppelt gebuchte erscheinen nur in der Liste.", "",
            tabelle(["Vorgang", "Liste", "geschätzt", "Liste minus Schätzung"],
                    [[nr, geld(vg[nr][1]), geld(vorgang_k.get(nr, 0)), ("+" if d > 0 else "−") + geld(abs(d))] for nr, d in diff[:15]]), ""]
    text = "\n".join(out) + "\n"
    if "--schreiben" in sys.argv:
        open(os.path.join(DOCS, "LISTE-KOSTEN.md"), "w", encoding="utf-8").write(text)
        print("kostenbericht.py: docs/LISTE-KOSTEN.md geschrieben")
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
