# 1799 (1727 Falltest, Nachprüfung 1 Befunde 3–5; Nachprüfung 2 Nr. 8, Sokrates 22.11., 07:22): Wächter der Fristen nach
# Grobablauf 14.2 („Jeder Stand hat einen, der ihn weiterbewegt, eine Frist und einen Wächter, der die Frist prüft. Der Wächter
# ist Code“, 14.1). Je Vorgang über der Frist seines Stands eine Zeile
#     LIEGT <Nr> | <Stand> | <Alter> | an <Rolle>: <was tun>
# Empfänger nach Spalte „Bewegt weiter“; der Disponent tut, was die Zeile nennt (Profil Disponent F13). Dazu Werkzeug „gebaut“,
# dessen Commit nicht auf main steht: Zeile an die Fachkraft (Besitzer). lauf.py gibt die Zeilen nur mit tools/1727-SCHARF aus;
# vorher zeigt `python3 tools/liegt.py` sie zum Nachsehen (ohne Schreiben). Fristen sind Annahmen bis zur Probewoche (14.2).
# Offen laut Vorgang: Frist „abgenommen“ und Stand „freigegeben, nicht auf main“ (hier Annahme 1 Tag, markiert „Frist offen“).
import datetime, os, re, subprocess, sys
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import startbar

STUNDE = 3600
TAG = 24 * STUNDE
# Stand (Wort der Liste, alt und neu) → (Nr. in 14.2, Frist in Sekunden, Empfänger, was tun). Frist None: keine Zeile.
REGELN = {
    "neu":          ("14.2.3", TAG, "Arbeitsplaner", "Abgleich und Vorrang, sonst Tagesmeldung „ohne Auftrag“"),
    "Auftrag":      ("14.2.4", 6 * STUNDE, "Disponent", "Leichenprüfung: starten oder Grund nennen"),
    "startbar":     ("14.2.4", 6 * STUNDE, "Disponent", "Leichenprüfung: starten oder Grund nennen"),
    "in Arbeit":    ("14.2.5", 6 * STUNDE, "Disponent", "Sperre lösen, zurück auf „Auftrag“, ein Neustart; beim zweiten Mal „steckt fest“"),
    "beim Prüfer":  ("14.2.6", TAG, "Disponent", "neuer Prüfer; bei leerem Guthaben Kerntest, wo die Prüfart es erlaubt"),
    "gebaut":       ("14.2.6", TAG, "Disponent", "neuer Prüfer; bei leerem Guthaben Kerntest, wo die Prüfart es erlaubt"),
    "abgenommen":   ("14.2.7", TAG, "Disponent", "nächster Build, Tagesmeldung (Frist offen)"),
    "im Build":     ("14.2.8", 3 * STUNDE, "Disponent", "Build rot oder hängt: zurück ans Büro; beim zweiten Mal Sokrates"),
    "Chef testet":  ("14.2.9", 5 * TAG, "Tagesbericht", "Erinnerung an den Chef; nach 14 Tagen „ruht“ mit Datum"),
    "zu testen":    ("14.2.9", 5 * TAG, "Tagesbericht", "Erinnerung an den Chef; nach 14 Tagen „ruht“ mit Datum"),
    "steckt fest":  ("14.2.12", 2 * TAG, "Sokrates", "Chefsache von selbst"),
    "Konflikt":     ("14.2.14", TAG, "Disponent", "Auftrag zurück an denselben Profil-Macher (zählt nicht als Runde)"),
    "freigegeben":  ("14.2.7", TAG, "Fachkraft", "auf `main`, Vollzug mit Commit (Frist offen)"),
}
CHEF_RUHT = 14 * TAG
ALT = {"Arbeitsplaner": "Ford", "Disponent": "Ford", "Prüfer": "Diogenes", "Tagesbericht": "Perikles"}  # bis tools/1727-SCHARF
COMMIT = re.compile(r"Geprüft an:\s*`?([0-9a-f]{7,40})\b")


def alter_text(s):
    s = int(s)
    if s >= TAG: return "%d d %d h" % (s // TAG, s % TAG // STUNDE)
    return "%d h %02d min" % (s // STUNDE, s % STUNDE // 60)


def auf_main(commit, wurzel=None):
    """True/False, ob der Commit auf origin/main steht; None, wenn Git ihn nicht kennt."""
    g = lambda *a: subprocess.run(["git", "-C", wurzel or HIER] + list(a), capture_output=True, text=True)
    if g("cat-file", "-e", commit + "^{commit}").returncode: return None
    return g("merge-base", "--is-ancestor", commit, "origin/main").returncode == 0


def ist_werkzeug(d):
    return (d.get("bereich") or "").startswith("B ")


def stand_von(d):
    """Stand nach 14.2: das Wort der Liste, „wartet“ mit Feld → „wartet auf“, „ruht“; Zusatz „steckt fest“ zählt als Stand."""
    w = d.get("wort") or (d.get("stand") or "").split(",")[0].strip()  # neue Wörter (neu, Auftrag, beim Prüfer …) kennt WORTE nicht
    if "steckt fest" in (d.get("stand") or "") and w not in ("erledigt",): return "steckt fest"
    if any(startbar.art(x) == "build" for x in d.get("warte") or []): return "Chef testet"  # wartet auf Test t<n>
    if w == "zu testen" and not str(d.get("build") or "").strip().isdigit(): return "startbar"  # 1332: ohne Build zurück beim Besitzer
    return w


def zeilen(zs, zeiten, jetzt, empfaenger=None, auf_main_fn=auf_main):
    """LIEGT-Zeilen für die Liste zs (dicts aus startbar.vorgangsliste) mit zeiten[i] (Unix-Sekunden je Zeilenindex).
    empfaenger: Abbildung neuer Rollen auf heutige (ALT bis zur Umschaltung), None = neue Namen."""
    aus = []
    an = (lambda r: empfaenger.get(r, r)) if empfaenger else (lambda r: r)
    for d in zs:
        if d.get("besitzer") == "Ideen" or d["nr"] in startbar.SONDER: continue
        st = stand_von(d)
        if st in ("erledigt", "aufgeteilt", "Idee", "Dauer", "nach Meilenstein", ""): continue
        if d["i"] >= len(zeiten) or zeiten[d["i"]] is None: continue
        alter = jetzt.timestamp() - zeiten[d["i"]]
        warte = d.get("warte") or []
        # 14.2.11 ruht: Pflichtdatum; am Datum zurück auf „Auftrag“, ohne Datum an den Arbeitsplaner
        if st == "ruht":
            if any(startbar.art(w) == "nr" for w in warte): continue  # ruht, bis ein anderer Vorgang fertig ist: 14.2.13
            daten = [startbar.datum_von(w) for w in warte if startbar.art(w) == "datum"]
            # 1874 (D335.1): nur ein Datum hinter „bis“ im Zusatz ist Termin, nie das Datum eines Chefworts („Chef 04.11.“,
            # „bis Kapitel 1 fertig (Chef 18.11.)“); Klammern und Komma beenden die Suche nach dem Datum
            daten += [startbar.datum_von(m.group(1)) for m in re.finditer(r"\bbis\b[^,;()]*?\b(\d\d?\.\d\d?\.)", d.get("zusatz") or "") if startbar.DATUM.match(m.group(1))]
            if not daten: aus.append("LIEGT %s | ruht | %s | an %s: ruht ohne Datum, Datum und Grund setzen (14.2.11)" % (d["nr"], alter_text(alter), an("Arbeitsplaner")))
            elif max(daten) <= jetzt: aus.append("LIEGT %s | ruht | %s | an %s: Datum %s erreicht, zurück auf „Auftrag“ (14.2.11)" % (d["nr"], alter_text(alter), an("Disponent"), max(daten).strftime("%d.%m.")))
            continue
        # 14.2.13 wartet auf: Frist wie der Stand des Erwarteten, der hat seine eigene Zeile
        if st == "wartet" or (warte and st not in ("gebaut", "zu testen", "Chef testet", "steckt fest")): continue
        # Werkzeug „gebaut“, Commit nicht auf main: an die Fachkraft, gleich, wie alt
        if st == "gebaut" and ist_werkzeug(d):
            m = COMMIT.search(d.get("stand") or "")
            if m and auf_main_fn(m.group(1)) is False:
                aus.append("LIEGT %s | gebaut, nicht auf main | %s | an %s: Commit %s auf `main`, Vollzug mit Commit (1799)" % (d["nr"], alter_text(alter), d.get("besitzer") or an("Fachkraft"), m.group(1)))
                continue
        if st == "gebaut" and warte: continue  # wartet auf Prüfer oder Termin: Prüfer-Frist zählt erst ohne Feld
        r = REGELN.get(st)
        if not r: continue
        nr142, frist, wer, tat = r
        if st in ("zu testen", "Chef testet") and alter >= CHEF_RUHT:
            wer, tat = "Disponent", "„ruht“ mit Datum, nie still (14.2.9)"
        if alter < frist: continue
        if st == "startbar" and d.get("kl") != "M": continue  # Kür liegt nach Vorrang (14.2.4), nur Muss hat die Frist
        wer = d.get("besitzer") if wer == "Fachkraft" else wer
        aus.append("LIEGT %s | %s | %s | an %s: %s (%s)" % (d["nr"], st, alter_text(alter), an(wer), tat, nr142))
    return aus


def liegt(jetzt=None, scharf=None):
    """Zeilen für lauf.py aus der echten Liste."""
    jetzt = jetzt or startbar.JETZT
    scharf = os.path.isfile(os.path.join(HIER, "1727-SCHARF")) if scharf is None else scharf
    zs = startbar.zeilen_liste()
    zeiten = startbar.zeilen_zeiten(jetzt)
    if not zeiten: return []
    return zeilen(zs, zeiten, jetzt, None if scharf else ALT)


if __name__ == "__main__":
    z = liegt()
    print("\n".join(z) if z else "NICHTS liegt über der Frist (1799)")
