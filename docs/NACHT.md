# Nachtarbeit

Nur lesen, wenn der Nutzer ein Nachtpaket vergibt oder eine Weck-Sitzung startet. Stand: 10.10.2026, 21:05 (Berliner Zeit).

Ziel: Die Nacht wird voll genutzt, auch wenn eine Sitzung fertig ist, an die Nutzungsgrenze stößt oder abbricht. Morgens liegt ein Ergebnis vor, das der Nutzer prüfen kann.

## Stand heute Nacht

Jede Sitzung pflegt nur ihre eigene Zeile, nach jedem Schritt (Herzschlag), committet und pusht sofort auf `main`.

| Wer | Stand | Gestartet | Herzschlag | Gerade an | Zweig |
|---|---|---|---|---|---|
| Tom | läuft | 10.10., 22:25 | 10.10., 22:25 | Paket 1 (13q.4 Laden) | `tom-diagonal` |
| Jerry | fertig | 10.10., 22:21 | 10.10., 22:29 | Paket und Reserve fertig, Morgenbericht in `docs/OFFEN.md` | `claude/wizardly-ramanujan-7rocwj` (PR #16) |

Stand ist einer von: `läuft`, `wartet auf Grenze`, `fertig`, `blockiert`.

## Ablauf

### 1. Vor dem Schlafengehen (mit dem Nutzer, etwa 22:00)

1. Alle offenen Rückfragen, die das Paket berühren, mit dem Nutzer klären. Was dann noch offen ist, entscheidet die Sitzung nachts selbst nach ihrer eigenen Empfehlung und schreibt das in den Morgenbericht.
2. Nachtpaket in den eigenen Abschnitt unten eintragen: **Reihenfolge**, je Aufgabe **fertig wenn …** (messbar, z. B. „Sprungtest 0 Meldungen“) und **Reserve** (mehr, als eine Nacht schafft).
3. **Weck-Sitzungen einrichten**, selbst, mit dem Werkzeug für geplante Aufgaben (`create_trigger`, einmalig mit `run_once_at`, je Zeitpunkt eine Aufgabe, `initiation: human_request`). Vorschlag: **00:30, 03:15, 06:00** (Berliner Zeit; in UTC umrechnen: −2 Stunden). Text der Aufgabe: siehe „Text für die Weck-Sitzung“ unten. Dem Nutzer melden, welche Aufgaben angelegt sind und welche Freigabe-Einstellung sie bekommen haben; lautet sie nicht „automatisch“, den Nutzer bitten, „Automatically approve“ in den Einstellungen der Aufgabe einzuschalten, sonst bleibt eine Weck-Sitzung nachts an der ersten Freigabe stehen.
4. Zeile in „Stand heute Nacht“ auf `läuft` setzen, pushen, mit der ersten Aufgabe anfangen.

### 2. Während der Nacht

- **Nicht fragen, nicht warten.** Rückfragen sammeln, sie kommen in den Morgenbericht. Ist eine Aufgabe blockiert: aufschreiben, nächste nehmen.
- **Kleine, sichere Schritte.** Nach jedem fertigen Schritt: Kerntests (`./gradlew -p core test`, Exit-Code prüfen), Commit und Push auf den eigenen Zweig, Herzschlag in der Tabelle. So geht beim Abbruch (Grenze, Fehler) höchstens ein Schritt verloren.
- **Nichts auf `main` außer Notizen.** Kein PR zusammenführen, keine Freigaben vorwegnehmen; Optisches nur als Entwurf (Standbilder mit Uhrzeit, Schalter im Testreiter).
- **Sparsam:** Filme nur, wo sich eine Bewegung sichtbar ändert; große Testausgaben gefiltert lesen; nach jeder fertigen Aufgabe prüfen, ob das Gespräch groß ist. Wenn ja: Übergabe schreiben, Zeile auf `läuft` lassen, Herzschlag setzen und die Antwort beenden; die nächste Weck-Sitzung macht frisch weiter.
- **Zweig-Build:** höchstens einen pro Aufgabe, nicht für jeden Zwischenschritt. Build-Meldung wie in `CLAUDE.md` (Erinnerung stellen).
- **Paket fertig:** Reserve abarbeiten. Ist auch die Reserve fertig: Zeile auf `fertig`, Morgenbericht schreiben, Antwort beenden.

### 3. Nutzungsgrenze

- Die Grenze gilt je Account (Tom und Jerry getrennt) und setzt sich alle fünf Stunden zurück; Chat und Code teilen sie sich.
- Merkt die Sitzung, dass es knapp wird, oder bricht ein Schritt ab: Übergabe in den eigenen Abschnitt (was fertig, was halb, nächster Schritt), Zeile auf `wartet auf Grenze`, pushen. Die nächste Weck-Sitzung macht weiter.
- Die Weckzeiten liegen etwa drei Stunden auseinander, damit mindestens eine davon nach einem Zurücksetzen der Grenze liegt.

### 4. Weck-Sitzung (startet frisch, kennt das Gespräch nicht)

1. Sitzungsstart wie in `CLAUDE.md` (`tools/notiz.sh`), dann diese Datei und den eigenen Abschnitt in `docs/OFFEN.md` lesen.
2. **Läuft noch jemand?** Eigene Zeile prüfen: Stand `läuft` und Herzschlag jünger als 40 Minuten, oder der letzte Commit auf dem eigenen Zweig jünger als 40 Minuten → eine andere eigene Sitzung arbeitet noch. Sofort beenden, nichts ändern.
3. Stand `fertig` → beenden, nichts ändern.
4. Sonst: Zeile auf `läuft`, Gestartet und Herzschlag setzen, pushen, am letzten offenen Punkt des Pakets weitermachen (Übergabe lesen, Zweig auschecken, mit `git log` prüfen, was schon da ist).
5. Keine neuen Weck-Sitzungen anlegen; die vom Abend reichen.

### 5. Morgenbericht

Bis spätestens zum letzten Wecken (06:00) in den eigenen Abschnitt von `docs/OFFEN.md` und als Nachricht im Chat der letzten Sitzung:
- Was ist fertig (mit Nummern), was halb, was blockiert und warum.
- Zweig und Zweig-Build mit Link, Testliste für den Nutzer.
- Entwürfe als Standbilder mit Uhrzeit.
- Nachts selbst entschiedene Rückfragen (mit der gewählten Empfehlung) und neue Rückfragen, nummeriert.
- Verbrauch: wie oft die Grenze erreicht wurde, welche Weck-Sitzungen gearbeitet haben.

## Text für die Weck-Sitzung

Wörtlich als Text der geplanten Aufgabe verwenden, `Tom` bzw. `Jerry` einsetzen:

> Weck-Sitzung Nachtarbeit für Chroniken von Bornim (Repo tramour-cmyk/androidapp_rpg_bornim), du bist **Tom**. Klone das Repo, falls nötig, und arbeite nach `CLAUDE.md` und `docs/NACHT.md`, Abschnitt „Weck-Sitzung“: erst prüfen, ob eine andere eigene Sitzung noch arbeitet (dann sofort beenden), sonst das eigene Nachtpaket in `docs/OFFEN.md` fortsetzen. Der Nutzer schläft: nichts fragen, nichts auf `main` außer Notizen, Rückfragen in den Morgenbericht.

## Nachtpakete

Werden vor dem Schlafengehen hier eingetragen und am Morgen nach dem Bericht geleert (Ergebnis steht dann in `docs/OFFEN.md`).

### Tom

Bestätigt 10.10., 22:25 (Nutzer: „Gute Nacht, starte Nachtmodus“; der alte Vorschlag von 20:50 ist überholt: 13p und 12b sind erledigt). Alles auf `tom-diagonal`, nur Entwürfe, nichts ins Spiel:
1. **13q.4 Laden:** Möbel (Ladentisch, Waren-Regale, Fässer und Säcke, Waage, Truhe), je drei Varianten, Möbelblatt (`ISODINGE=laden`), dann drei Grundrisse `shop_a/b/c` als Standbild Tag/Abend (wie `elder_a/b/c`). Fertig wenn: Blatt und 6 Standbilder mit Uhrzeit liegen in `docs`-Bericht, Kerntests grün.
2. **13q.4 Tempel:** Altar, Kerzenständer, Gebetsbänke, Lesepult, Weihwasserbecken, je drei Varianten, Blatt und drei Grundrisse `temple_a/b/c`. Fertig wenn: wie 1.
3. **17 Nachschwingen** als Entwurf: Umhang, Haare, Köcher, Riemen schwingen beim Stoppen und Drehen nach; Standbilder und Sprungtest. Fertig wenn: Sprungtest 0 Meldungen, Standbilder Stehen↔Gehen↔Drehen.
4. **14 Neustart-Haken** (Werkzeug, eigener Zweig von `main`, PR, nicht zusammenführen). Fertig wenn: Haken meldet über Schwelle, Test von Hand dokumentiert.
- Reserve: Haus des Ältesten nach Empfehlung (Grundriss A) ins Spiel unter dem Schalter „Dorf und Räume“ vorbereiten, nur auf dem Zweig, mit Kerntest (Held erreicht Aldric und Tür).
- Selbst entschieden nachts: 13q.5 (Möbel des Ältesten bleiben so), Grundriss-Empfehlung A. Nicht nachts: 15.

### Jerry

Bestätigt vom Nutzer 10.10., 22:19 („starte Nachtmodus“); 16 ist schon erledigt (v0.1.460).
1. **18 Pechsträhnen:** gebaut, PR #16 (Zweig `claude/wizardly-ramanujan-7rocwj`, Commit 7343f0c). Bosswerte gemessen 22:21 (unverändert im Rauschen, siehe Morgenbericht); Zweig-Build abwarten. Fertig wenn: Kerntests grün (155/0 um 22:18), Bosswerte im Morgenbericht, Zweig-Build mit Link.
2. **Hörproben Klänge im alten Stil** (Liste unter „Geplant“ in `docs/OFFEN.md`: Klick, Belohnungen, Welt, Zauber und Tränke, Kampfende, Umgebung): je Klang drei neue Varianten als WAV zum Vergleich mit dem alten, im Vorschau-Werkzeug erzeugt, im Spiel nichts umgestellt. Auf demselben Zweig, getrennter Commit (Entwürfe in `Sfx.proposed`, im Spiel ungenutzt). Fertig wenn: je Gruppe drei Varianten und der alte Klang als Datei, Liste im Bericht, Abgleich mit `docs/STIL.md` („Klang“) als Absatz.
- **Reserve:** Monster-Laute je Gegnerart als Hörproben (Merkliste „Monster-Geräusche“), zuerst Wolf, Goblin, Skelett.
- Nicht nachts: 15 Entschlacken.
- Weck-Sitzungen: 00:30, 03:15, 06:00 (siehe Chat 22:2x).
