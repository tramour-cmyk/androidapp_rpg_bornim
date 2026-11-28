# 1727 · Nullbasis Werkzeuge und Haken (Inventur Sokrates, 19.11., 10:37)

Auftrag Chef 10:36: „das mit der Nullbasis können wir doch schon mal anfangen … wer hier noch eine Daseinsberechtigung haben wird?“ Maßstab (Grobablauf 3.14.2): Welchen Fehler verhindert es, belegt? Und passt es zum neuen Ablauf? Nur Vorschlag; gestrichen wird erst nach Entscheid, gebaut von einem Macher mit Profil Werkzeug.

## 1 Grundlage

- 1.1 Gezählt mit einem Skript über `tools/` (88 Dateien, ohne Unterordner), `.claude/settings.json` und `.github/workflows/`: Wer ruft die Datei (Haken, GitHub, andere Werkzeuge), wie oft steht sie in der Doku, erste Zeile als Zweck.
- 1.2 Nicht geprüft: ob ein Werkzeug in den letzten Wochen wirklich lief (das Datum in Git ist durch das Zurücksetzen der Notizkopie heute früh für alle 18.11.). Das belegt der Macher bei der Umsetzung.
- 1.3 Unterordner (`sim444`, `blender348`, `klang`, `godot` …) sind Werkzeuge der Spielherstellung, nicht des Betriebs, und gehören zu 2.1. Auffällig: `tools/entwurf/` hat 37 MB, Ursache offen.

## 2 Vier Gruppen

| Nr. | Gruppe | Dateien | Größe | Votum |
|---|---|---|---|---|
| 2.1 | **Spiel und Bau** (Tests, Prüfungen, Kataloge, Bilder) | 21 | 127 KB | bleibt; Einmalwerkzeuge alter Vorgänge prüfen (3.1) |
| 2.2 | **Sperren gegen echten Schaden** | 4 (mit `probelauf.py`, 6.1) | 144 KB | bleibt, wird schlanker (3.2) |
| 2.3 | **Büro-Mechanik** (Liste, Start, Kosten, Meldung) | 14 | 416 KB | bleibt als Kern des Büros, schrumpft stark mit Rollen und Vorräten (3.3) |
| 2.4 | **Mahner und Zähler über unsere eigenen Abläufe** | 22 | 213 KB | großteils weg (3.4) |
| 2.5 | Tests zu den Werkzeugen | 27 | etwa 50 KB | gehen mit ihrem Werkzeug |

## 3 Je Gruppe

**3.1 Spiel und Bau, bleibt:** `t` (ein Einstieg für alle Prüfungen, 124 Stellen in der Doku), `setup-session.sh`, `check-env.sh`, `story.sh`, `regelwerte.py`, `gegenstaende.py`, `figurenpruefung.py`, `figuren.py`, `pruefliste.py`, `bildrate.py`, `laufnachweis.py`, `rotbuch.py`, `namenpruefung.py`, `bildvergleich.py`.
- 3.1.1 *Prüfen, ob noch gebraucht* (Einmalwerkzeuge zu alten Vorgängen): `vgl348.py`, `alt_bilder.sh`, `menues_512b_blatt.py`, `bildmass.py`, `varianten504.py`.

**3.2 Sperren, bleibt:**
- 3.2.1 `buildzweig-haken.py`: verhindert fremde Pushes auf einen Buildzweig (1716, zwei Neustarts von Lauf 575). Belegt.
- 3.2.2 `startsperre-haken.py`: lässt nur geplante Starts durch (750 A); wichtig bei knappem Guthaben.
- 3.2.3 `commit-pruefung.py` (60 KB): prüft Notizen beim Commit. Teilen: was echten Schaden verhindert (Schlüssel, Größe, Form der Vorgangsliste) bleibt als Sperre, was nur mahnt, fällt.
- 3.2.5 *Auf GitHub (8 Abläufe):* `godot-schluessel.yml` verhindert, dass Android ein Update wegen falschem Signaturschlüssel ablehnt (399.1a); die übrigen bauen und testen. Bleiben, gehören zur Sorte E (Grobablauf 3.13.7).
- 3.2.4 *Fehlt:* Sperren für Grobablauf 5.6 und 5.7 (Schlüssel und App-Kennung, Spielcode auf `main` ohne Test des Chefs); heute steht das nur als Text.

**3.3 Büro-Mechanik, bleibt und schrumpft:**
- 3.3.1 Kern: `vorgang.py`, `startbar.py` (91 KB), `lauf.py` (113 KB), `meldung.sh`, `reaktionen.py`, `notiz.sh`, `tagesbericht.py` (Chef 19.11., 08:06: „der ist für mich wichtig“), `zug-index.py` (Chefsache-Übersicht).
- 3.3.2 `lauf.py` und `startbar.py` tragen heute Rollen, Vorräte, Pausen, Rollenspiegel, Nachtregeln. Mit Pool, Akte und festen Standwörtern (Grobablauf 3.10) fällt davon viel weg; Ziel zusammen unter 80 KB statt 204 KB (Annahme, belegt der Macher).
- 3.3.5 `regelcheck.py` (18 KB, fehlte in der ersten Fassung): `lauf.py` ruft es stündlich, `commit-pruefung.py` liest seine Namen; Regelabgleich, den sonst eine Sitzung zählen müsste. Bleibt im Büro, Inhalt nach Nullbasis prüfen.
- 3.3.3 Zusammenlegen: `kosten.py`, `vorgangskosten.py`, `kostenbericht.py` → ein Kostenwerkzeug, das auch je Rückmeldung bucht (Grobablauf 13.4.5).
- 3.3.4 Streichen-Kandidaten: `dashboard.py` (kein Aufruf, nicht in der Doku), `projektplan.py`, `ueberblick.py` (Chef 1313, darum nur mit deinem Wort).

**3.4 Mahner und Zähler, großteils weg:**

| Nr. | Werkzeug | Was es tut | Votum | Grund |
|---|---|---|---|---|
| 3.4.1 | `kernregeln.txt` | schreibt bei jeder Nachricht des Chefs die Kernregeln in die Sitzung | weg | ersetzt durch den Sockel |
| 3.4.2 | `startwarnung.py` (+ `.json`) | Warnzeilen beim Start; legt nach 6 h selbst Vorgänge an | umbauen | das Anlegen ist stilles Handeln und kommt ins Büro; die Warnzeilen fallen |
| 3.4.3 | `abgleich.py` | Warnzeilen für Ford; Vorentscheid-Bremse (mehr als zwei „zurück“ in 7 Tagen) | umbauen | Bremse ist Regel, kommt in `lauf.py`; Warnzeilen fallen |
| 3.4.4 | `vorratspruefung.py` | prüft Vorräte; hält den Tagesbericht an | weg | Vorräte entfallen; `tagesbericht.py` im selben Schritt ändern |
| 3.4.5 | `pflegehinweis.py` | Rollenspiegel-Zeilen | weg | mit dem Rollenspiegel |
| 3.4.6 | `rollenspiegel.sh` | zehn Fragen an alle Rollen (340) | **streichen bei Umsetzung** (Chef 10:53) | im Pool ohne feste Rollen kaum noch sinnvoll |
| 3.4.7 | `weiter-haken.py` | Stop-Haken: weiterarbeiten | weg | ein Macher endet mit dem Auftrag |
| 3.4.8 | `zug-haken.py` | zählt nur noch (822) | weg | zählt, handelt nicht |
| 3.4.9 | `hakenzahl.py` | zählt, wann Haken anhalten | weg | nach dem Zusammenlegen überflüssig |
| 3.4.10 | `inhalt.py`, `glossar.py` | Inhaltsverzeichnis, Glossar-Fundstellen | weg | Doku-Pflege; Begriffe ins Profil Spieltext |
| 3.4.11 | `bereiche.py`, `bereichslisten.py` | feste Bereiche | bleibt | Bereiche bleiben (Chef 11:54) |
| 3.4.12 | `nachtstarts.py` | hält nach zwei Neustarts in einer Nacht an (340.12) | ins Büro | Regel des Chefs, gehört in `lauf.py` |
| 3.4.13 | `neustart-haken.py` (21 KB) | Erinnerung und Sperre bei großer Sitzung (1520) | schrumpfen | nur noch Sperre an der Grenze, ohne Erinnerungstext; misst auch für 3.9 |
| 3.4.14 | `nummer_wort.py`, `chef_fund.py` | Nummer ohne Wort an den Chef; Funde des Chefs erkennen | in `meldung.sh` | Nutzen belegt (1414), aber still beim Senden |
| 3.4.15 | `vorlage_pruefen.py` | Form einer Vorlage (799) | in die Commit-Sperre | betrifft nur Chefsache |
| 3.4.16 | `freigabe-haken.py` | sagt dir, wenn eine Sitzung auf Freigabe wartet (1610) | bleibt | redet mit dir, nicht mit der Sitzung |
| 3.4.17 | `laufzeiten.py` | Zeiten der Läufe (1548) | prüfen | Messung; nur behalten, wenn jemand sie liest |
| 3.4.18 | `probelauf.py` (71 KB) | **sperrt** (Exit 2) den zweiten Bildlauf, Ablaufstart oder bauenden Push je Vorgang bis zum Urteil des Chefs (621 A) | Regel streichen (Chef 10:53); **Laufbremse neu, siehe 6.1** | falsch einsortiert: ist Sperre und Kostenbremse, nicht Mahner |

## 4 Ergebnis, wenn alles so kommt

- 4.1 Haken: von 14 Einträgen auf etwa 6 (Start-Einrichtung, Buildzweig, Startsperre, Sitzungsgröße, Freigabe, Commit-Sperre); keiner davon schreibt im Normalfall etwas in die Sitzung. Die „Uhr“-Zeile nach jedem Schritt prüfe ich gesondert: sie kostet bei jedem Werkzeugaufruf, ein Stempel einmal je Antwort reicht.
- 4.2 Werkzeuge: Gruppe 2.4 von 213 KB auf etwa 30 KB, Gruppe 2.3 von 416 KB auf etwa 200 KB (Annahmen bis zur Umsetzung).
- 4.3 Entschieden (Chef 10:53: „Dann bei Umsetzung 1 streichen, 2 streichen“): Rollenspiegel (3.4.6) und Probelauf-Regel 621 A (3.4.18) fallen mit der Umsetzung.

## 5 Stärkstes Gegenargument (nach dem Gegenlesen)

- 5.1 **Streichen bricht Aufrufer oder verliert still eine Sperre.** Belegt: `probelauf.py` sperrt (6.1); `vorratspruefung.py` hängt im Tagesbericht, `abgleich.py` in `lauf.py`, `hakenzahl.py` in `startsperre-haken.py`, `kernregeln.txt` in `notiz.sh` und `neustart-haken.py`.
- 5.2 *Entkräftet durch:* Pflichtspalte „Aufrufer“ je Werkzeug; Streichen nur zusammen mit dem Umbau der Aufrufer, in einem Commit, Kerntests grün.
- 5.3 Zweites: **Ohne Messung lässt sich nicht zeigen, dass das Streichen nichts verschlechtert.** Die Zähler (`hakenzahl.py`, Zählung in `probelauf.py`, `zug-haken.py`) sind heute die einzige Datenquelle. *Entkräftet:* vor dem Streichen eine Woche Messbasis festhalten (Fehler, die der Chef zuerst findet; Läufe je Abnahme), dann vergleichen.
- 5.4 Mein erstes Gegenargument („die Fehler kommen wieder“) war eine Haltung, kein Beleg.

## 6 Gegenlesen (19.11., 11:18, frischer Helfer mit Blick in den Code)

Urteil: „Die Fakten stimmen im Kern. Die Gruppierung hat aber drei Fehler: probelauf.py ist eine Sperre, vier ‚weg‘-Kandidaten haben bleibende Aufrufer, und regelcheck.py fehlt.“ Je Befund mein Wort:
- 6.1 `probelauf.py` ist Sperre, nicht Mahner. **Stimmt**, mein Fehler; geändert. Folge: Dein „streichen“ (10:53) fiel auf meine unvollständige Beschreibung. Die Regel „nächster Lauf erst nach Urteil des Chefs“ kann fallen, weil der Prüfer vor dir sitzt. Aber die **Bremse gegen viele Läufe** ersetzt der Prüfer nicht. Vorschlag: neue Laufbremse **ein Bild- oder Filmlauf je Runde, den nächsten gibt der Prüfer frei** (statt du); nach dem zweiten Nein ohnehin Sokrates (Grobablauf 3.3.5). Dazu braucht es dein Wort.
- 6.2 Vier Kandidaten mit bleibenden Aufrufern. **Stimmt**; Votum und Spalte angepasst (3.4.2–3.4.4, 5.1).
- 6.3 `zug-haken.py` und `weiter-haken.py`: Aussagen stimmen, Beleg „verhindert nie“ fehlt. **Stimmt**, belegt der Macher (1.2).
- 6.4 `regelcheck.py` und die GitHub-Abläufe fehlten. **Stimmt**, ergänzt (3.3.5, 3.2.5). Zu `godot-schluessel.yml`: sperrt falsche Signaturschlüssel, nicht das Committen von Schlüsseln; 3.2.4 bleibt darum richtig.
- 6.5 Zahl der Haken 15 statt 14. **Einwand:** ausgezählt in `.claude/settings.json` sind es 14 (Start 2, Nachricht 1, Ende 2, vor Werkzeug 6, nach Werkzeug 2, Freigabe 1).
- 6.6 Gegenargument nicht das stärkste. **Stimmt**, Abschnitt 5 neu.
- 6.7 `tools/entwurf/` 37 MB: bestätigt; aufräumen gehört in die Umsetzung.
