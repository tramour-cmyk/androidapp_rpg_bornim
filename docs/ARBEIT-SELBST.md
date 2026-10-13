# Selbstarbeit und gemeinsame Zeit

Nur lesen, wenn der Nutzer Selbstarbeit vergibt („Tom, arbeite bis 17 Uhr selbstständig“, früher „Nachtpaket“), eine Weck-Sitzung startet oder gemeinsame Zeit ansagt. Stand: 11.10.2026, 13:40 (Berliner Zeit; Thema 22, vorher `NACHT.md`).

Ziel: Zeit ohne den Nutzer (Nacht oder Tag) wird voll genutzt, auch wenn eine Sitzung fertig ist, an die Nutzungsgrenze stößt oder abbricht. Zeit mit dem Nutzer geht an das, was ihn braucht.

## Stand

Jede Sitzung pflegt nur ihre eigene Zeile, nach jedem Schritt (Herzschlag), committet und pusht sofort auf `main`.

| Wer | Stand | Bis | Gestartet | Herzschlag | Gerade an | Zweig |
|---|---|---|---|---|---|---|
| Tom | läuft | 14.10., 07:00 | 14.10., 00:20 | 14.10., 00:20 | Reserve: 55 Speer im Kampf prüfen | `claude/tom-d1-raeume` |
| Jerry | fertig | – | 12.10., 16:33 | 12.10., 16:59 | Pause bis Freitag (Nutzungsguthaben), Stand in ARBEIT-OFFEN.md | `claude/jerry-13e-hoehle-diagonal` |

Stand ist einer von: `läuft`, `übergeben` (die nächste Sitzung übernimmt immer, ohne 40-Minuten-Sperre; 32.1), `wartet auf Grenze`, `fertig`, `blockiert`. Vertretung (32.8) wird in „Gerade an“ vermerkt: „Vertretung durch Jerry/Tom“. „Bis“: Ende der Selbstarbeit (Berliner Zeit), danach Bericht.

## Zwei Arten von Aufgaben

Jede Sitzung führt unten im eigenen Abschnitt zwei Listen, mit Themennummer, Reihenfolge und „fertig, wenn …“ (messbar). Neue passende Aufgaben trägt sie laufend ein, Erledigtes streicht sie.

- **Vorrat für Selbstarbeit:** geht ohne den Nutzer. Nur schon Freigegebenes, Entwürfe (Standbilder, nichts ins Spiel ohne Freigabe), Werkzeuge, Tests, Aufräumen. Keine neuen Grundsatzentscheidungen; was offen ist, entscheidet die Sitzung nach ihrer Empfehlung und schreibt es in den Bericht. Aus der Merkliste nur, was der Nutzer ausdrücklich dafür freigibt.
- **Für gemeinsame Zeit:** braucht den Nutzer. Entwürfe ansehen und entscheiden, Builds auf dem Gerät testen, Freigaben (PR, Release), Rückfragen, neue Ideen besprechen. Sagt der Nutzer „ich habe zwei Stunden Zeit, lass uns gemeinsam arbeiten“, legt die Sitzung diese Liste vor (mit dem Ergebnis der letzten Selbstarbeit obenauf) und arbeitet sie mit ihm ab; Selbstarbeit läuft dann nicht.

## Ablauf der Selbstarbeit

### Feste Weck-Routinen (seit 11.10.)

**Pausiert, solange keine Selbstarbeit läuft** (Nutzer 13.10.): Wer Selbstarbeit vergibt, schaltet die Routinen des eigenen Accounts wieder an (`update_trigger`, `enabled: true`), am Ende der Selbstarbeit wieder aus; nie löschen (die Repo-Einstellung von Hand ginge verloren). Tom: alle acht pausiert 13.10., 10:26; 00:24, 03:24, 06:24 wieder an 13.10., 23:2x (Selbstarbeit bis 07:00), Prompts auf diesen Text gebracht.

Alle drei Stunden rund um die Uhr je Account eine Routine, die eine frische Sitzung startet: **Tom** 00:24, 03:24, 06:24, 09:24, 12:24, 15:24, 18:24, 21:24 („Tom Selbstarbeit HH:MM“), **Jerry** drei Minuten später (00:27, 03:27, … 21:27, „Jerry Selbstarbeit HH:MM“). Eine Routine arbeitet nur, wenn die eigene Zeile oben `läuft` oder `wartet auf Grenze` steht und „Bis“ noch nicht vorbei ist; sonst beendet sie sich sofort (kostet fast nichts). Der Abstand von drei Stunden sorgt dafür, dass nach jedem Zurücksetzen der Nutzungsgrenze (alle fünf Stunden) bald eine weitermacht.
- Jede Routine braucht einmal vom Nutzer (am PC im Browser, claude.ai, Routinen): Repository `tramour-cmyk/androidapp_rpg_bornim` auswählen, Freigabe auf automatisch. Fehlt das Schreibrecht, hängt die Sitzung das Repo selbst mit `add_repo` an.

### 1. Vergeben (mit dem Nutzer)

1. Offene Rückfragen, die das Paket berühren, klären; den Rest entscheidet die Sitzung nach ihrer Empfehlung (in den Bericht).
2. Paket im eigenen Abschnitt unten: Aufgaben aus dem Vorrat in **Reihenfolge**, je **fertig, wenn …**, dazu **Reserve** (mehr, als die Zeit schafft).
3. Eigene Zeile oben: `läuft`, „Bis“, Gestartet, Herzschlag; pushen; mit der ersten Aufgabe anfangen. Die laufende Sitzung arbeitet selbst weiter, solange sie kann (Erinnerungen mit `send_later`, etwa für Builds); die Routinen übernehmen nur nach Abbruch oder Grenze.

### 2. Während der Selbstarbeit

**Dauerlauf (32.3, Regel 12.10.):** Eine Sitzung in Selbstarbeit beendet ihre Antwort nie, ohne vorher `send_later` (2 Minuten, an sich selbst: „Selbstarbeit weiter, nächster Schritt laut ARBEIT-SELBST.md“) zu stellen, solange „Bis“ nicht erreicht ist. Sonst ist sie bis zur nächsten Routine (bis zu 3 h) still. Das gilt für die vergebende Sitzung wie für jede Weck-Sitzung.

- **Nicht fragen, nicht warten.** Rückfragen sammeln, sie kommen in den Bericht. Ist eine Aufgabe blockiert: aufschreiben, **sofort** den nächsten Punkt aus Paket, Reserve oder Vorrat nehmen; nie wegen einer Blockade beenden (32.4).
- **App-Code:** vor dem Push auch die Vorschau bauen (`tools/t`), damit kein Werkzeug still bricht (32.5). Vorschau bricht wegen Speicher ab: `tools/setup-session.sh` (Gradle 6 GB, 32.6).
- **Kleine, sichere Schritte.** Nach jedem fertigen Schritt: Kerntests (`CLAUDE.md`), Commit und Push auf den eigenen Zweig, Herzschlag. So geht beim Abbruch höchstens ein Schritt verloren.
- **Nichts auf `main` außer Notizen.** Kein PR zusammenführen, keine Freigaben vorwegnehmen; Optisches nur als Entwurf (Standbilder mit Uhrzeit, Schalter im Testreiter).
- **Sparsam:** Filme nur, wo sich eine Bewegung sichtbar ändert; große Ausgaben gefiltert lesen; nach jeder Aufgabe prüfen, ob das Gespräch groß ist. Wenn ja (oder der Neustart-Haken meldet es): Übergabe schreiben, Zeile auf `übergeben`, pushen, **sofort selbst einen Nachfolger starten** (`ARBEIT-ABLAEUFE.md` „Neustart“, Auftrag: Text der Weck-Routine) und erst dann die Antwort beenden; nicht auf die Routine warten (32.2).
- **Zweig-Build:** Sammelbuild nach `ROLLE-ENTWICKLER.md` (78); Weckruf wie dort.
- **Paket fertig:** Reserve, dann weiter aus dem Vorrat. Ist nichts mehr da oder „Bis“ erreicht: Zeile auf `fertig`, Bericht, Antwort beenden.

### 3. Nutzungsgrenze

- Gilt je Account, setzt sich alle fünf Stunden zurück; Chat und Code teilen sie sich.
- Wird es knapp oder bricht ein Schritt ab: Übergabe (fertig, halb, nächster Schritt), Zeile auf `wartet auf Grenze`, pushen. Die nächste Routine macht weiter.
- **Vertretung (32.8, Nutzer 12.10., 32c ja):** Wer an der Grenze ist, kann nichts mehr tun; der andere übernimmt von außen. Bedingung: Zeile des anderen `läuft`/`übergeben`/`wartet auf Grenze`, „Bis“ nicht vorbei, Herzschlag älter als 40 min, und das eigene Paket ist fertig oder blockiert. Dann: in der Zeile des anderen „Vertretung durch …“ und Herzschlag setzen, dessen Paket auf dessen Zweig fortsetzen (nur Paketpunkte, keine neuen Themen, keine Freigaben, Übergabe in dessen Abschnitt). Ausnahme von „keiner arbeitet an Themen des anderen“ nur hierfür. Die Weck-Sitzung des Zurückkehrenden sieht den Vermerk: Herzschlag jünger als 40 min → warten (beenden mit `send_later`), sonst übernimmt sie wieder und löscht den Vermerk.

### 4. Weck-Sitzung (startet frisch, kennt das Gespräch nicht)

1. Sitzungsstart wie in `CLAUDE.md` (`tools/notiz.sh`), dann diese Datei und den eigenen Abschnitt in `docs/ARBEIT-OFFEN.md`.
2. Eigene Zeile nicht `läuft`/`übergeben`/`wartet auf Grenze`, oder „Bis“ vorbei, oder kein Paket: weiter mit 3a (Vertretung), sonst sofort beenden, nichts ändern.
3. **Läuft noch jemand?** Stand `übergeben`: übernehmen. Sonst Herzschlag oder letzter Commit auf dem eigenen Zweig jünger als 40 Minuten: sofort beenden, nichts ändern.
3a. **Eigene Zeile nicht aktiv?** Dann die Zeile des anderen prüfen (Vertretung, Abschnitt 3); trifft sie nicht zu: beenden.
4. Sonst: Zeile auf `läuft`, Gestartet und Herzschlag setzen, pushen, am letzten offenen Punkt weitermachen (Übergabe lesen, Zweig auschecken, `git log`).
5. Keine neuen Routinen anlegen. Dauerlauf (Abschnitt 2) gilt: vor jedem Antwortende `send_later` 2 min.

### 5. Bericht

Entwürfe und Rückfragen über die Seite „Dein Zug“ (`CLAUDE.md`).

Am Ende („Bis“ oder Vorrat leer) in den eigenen Abschnitt von `docs/ARBEIT-OFFEN.md` und als Nachricht im Chat der letzten Sitzung: was fertig ist (mit Nummern), was halb, was blockiert und warum; Zweig und Zweig-Build mit Link und Testliste; Entwürfe als Standbilder mit Uhrzeit; selbst entschiedene und neue Rückfragen, nummeriert; Verbrauch (Grenze erreicht? welche Routinen haben gearbeitet). Die Punkte für den Nutzer wandern in „Für gemeinsame Zeit“.

## Text der Weck-Routine

> Weck-Sitzung Selbstarbeit für Chroniken von Bornim (Repo tramour-cmyk/androidapp_rpg_bornim), du bist **Tom** (bei Jerry: **Jerry**, „der andere“ = Tom). (1) Repo nicht da: nach /home/user/androidapp_rpg_bornim klonen; lehnt der erste Push ab („not in this session's authorized repository set“), mit add_repo anhängen (access push) und noch einmal; geht Schreiben dann nicht: kurze Nachricht mit dem Fehler, beenden. (2) `docs/ARBEIT-SELBST.md` auf `main` lesen. Eigene Zeile `läuft`, `übergeben` oder `wartet auf Grenze`, „Bis“ nicht vorbei, Paket eingetragen: nach Abschnitt „Weck-Sitzung“ weiterarbeiten. Sonst prüfen, ob die Zeile des anderen eine Vertretung verlangt (Abschnitt „Nutzungsgrenze“, 32.8); wenn nicht: sofort beenden, nichts ändern. (3) Arbeiten nach `CLAUDE.md` und `docs/ARBEIT-SELBST.md`. **Dauerlauf:** Bis „Bis“ erreicht ist, vor jedem Antwortende `send_later` (2 Minuten, an diese Sitzung: „Selbstarbeit weiter, nächster Schritt laut ARBEIT-SELBST.md“) stellen; blockiert → nächster Punkt; wird die Sitzung groß: Übergabe, Stand `übergeben`, Nachfolger mit `create_session` und diesem Text starten. Der Nutzer ist nicht da: nichts fragen, nichts auf `main` außer Notizen, Rückfragen in den Bericht.

## Tom

**Achtung Vorschau:** nach Änderungen an `Sculpt.kt` übersetzt alles neu (2–10 min); nie zwei Vorschau-Läufe gleichzeitig (Speicher); Python-Ersetzungen nur mit eindeutigem Suchtext und `assert s.count(old)==1`.

**Paket 13.10., 23:20 bis 14.10., 07:00** (Nutzer 23:1x „Selbstarbeit ab jetzt bis morgen früh“; Zweig `claude/tom-d1-raeume`):
1. ~~D1.5 Räume~~ fertig (05d446fd, Standbild 23:38), Vermerk im Prüfbericht.
2. ~~D1.16 Rest ohne `WorldScreen.kt`~~ fertig (7d9692c1; alte flache Bäume und verworfener Pflasterentwurf mit weg).
3. ~~Sammelbuild~~ PR #57 offen (Build 0.1.721), Prüfliste `e/t721.html` auf „Dein Zug“; Vermerke D1.4/D1.5/D1.16 im Prüfbericht gesetzt.
4. ~~27 Wald~~ Lückenliste in der Übergabe (Standbilder 00:19).
**Reserve:** 55 Speer im Kampf (~2 m) prüfen; 5.5 Dorf Lücken prüfen; 69 Intro: Bildentwürfe (Standbilder) nach `STORY-K1.md` `[69.intro.…]`.

**Vorrat für Selbstarbeit** (Reihenfolge; 23a freigegeben 11.10., 14:18; Erledigtes im Archiv, 77e):
1. **27 Wald:** Standbilder Wald gegen Dorf bei Tag und Nacht, Lückenliste nach „Ort fertig“ (`DESIGN-ABNAHME.md`), danach Entwurf eines diagonalen Baums. Fertig, wenn: Standbilder und Liste in `ARBEIT-OFFEN.md`.

**Für gemeinsame Zeit:**
- 5.1: Standbilder ansehen, dann Zweig-Build auf dem Gerät testen.

## Jerry

**Vorrat für Selbstarbeit** (Reihenfolge; Erledigtes im Archiv, 77e):
1. **24.6 Kampferöffnung wartet** + Herzschlag in der Blende (nach Toms 24.5 auf `main`).
2. **18 Stimmen der übrigen Gegner** (Angriff, Schmerz, Tod, je drei Fassungen), nur als Hörproben.
3. **Schritte je Untergrund** (74), Hörproben (23a, 11.10., 14:18).
4. **Raumklang** (Idee 8), Hörproben.
5. **Rudelwölfe beißen ins Leere** (Fehler 08.10., Offen 52), mit Film.
6. **Musik in Schichten** (Idee 10), Hörproben.
7. **Ausgleich Magier** (26): Siegquoten aller Klassen gegen Krogg und Grak aus der Simulation, Vorschlag zum Angleichen. Fertig, wenn: Zahlen vorher/nachher im Bericht.

**Für gemeinsame Zeit:**
- 24e/24.6: Kampferöffnung wartet, bis Kampfbilder fertig sind (nach Toms 24.1–24.3).
- 9i: Entwürfe ansehen und freigeben.
- 19e: ein konkretes Beispiel für „Bewegungen unrund“, falls dir eines auffällt.
