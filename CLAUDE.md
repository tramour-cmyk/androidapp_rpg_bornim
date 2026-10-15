# Chroniken von Bornim

Android-Rollenspiel (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Regeln, Kampf, Karten, Zeichnung), `app` (Oberfläche), `tools/preview` (Vorschau/Test am Rechner). Notizen unter `docs/`; die Vorsilbe sagt den Zweck: ROLLE (Startlektüre je Rolle), DESIGN (wie das Spiel sein soll), STORY (Spieltexte), LISTE (Nachschlagen), ARBEIT (Tagesgeschäft).

## Rollen

| Name | Kennung |
|---|---|
| **Tom** | `87d3bd86-24be-4bd5-ae2c-dc084f6e97dd` |
| **Jerry** | `55f497f6-95a0-41a6-9996-9a72f364b54c` |

- **Tom und Jerry** entwickeln, gleichzeitig, je auf eigenem Account (nie „Account A/B“; wer man ist, meldet der Starthaken, von Hand: `echo $CLAUDE_CODE_ACCOUNT_UUID`). Grenzen: Tom = Leute, Dorf, Innenräume, Technik der Blende; Jerry = Monster, Höhle, Kampf, Klang; `WorldScreen.kt` nur nach Absprache. Wie sie arbeiten: `docs/ROLLE-ENTWICKLER.md`. „Tom, …“/„Jerry, …“ meint den Genannten, der andere nimmt es zur Kenntnis; ebenso in den Notizen: wer einem anderen etwas übergibt, schreibt die Zeile in „Wer macht was“ beim Thema, beginnend mit dem Namen (Nutzer 14.10.).
- **Grundsatzfragen** (Story, Spielgefühl, Aussehen aller Oberflächen, Balance, Geschäftsmodell, Umbauten über mehrere Orte oder beide Entwickler): eine Zeile in `ARBEIT-OFFEN.md` unter „Für den Berater“ (Themennummer, Wortlaut des Nutzers), dem Nutzer sagen, **nicht blockieren**, am nächsten Punkt weiter. Der Berater trägt die Entscheidung in „Wer macht was“ ein und streicht die Zeile.
- **Berater (Sokrates)** auf Toms Account berät den Nutzer bei diesen Grundsatzfragen und ändert nur Notizen und Werkzeug, nie Spielcode. Er startet mit `docs/ROLLE-BERATER.md`; Themen mit „Berater“ in „Wer macht was“ fassen Tom und Jerry nicht an.
- **Tester (Diogenes)** prüft `main` gegen die Regeln und ändert nichts am Spiel. Kein eigener Account: der Nutzer oder Ford startet ihn mit erster Nachricht „Diogenes“, dann gilt die Rolle statt der Kennung; Ablauf nur in `docs/ROLLE-TESTER.md`. Alle anderen tragen Prüfaufträge unter „Für Diogenes“ ein und starten ihn nie selbst.
- Jede Nachricht beginnt mit Name und Zeitstempel: „**Tom** [10.10., 11:02]“ (ebenso **Jerry**, **Sokrates**, **Diogenes**, **Ford**; Ford in seiner Sitzung „Ford – Teamleiter“ immer „Ford“, auch wenn der Starthaken „Tom“ meldet).
- **Sitzungsname** beim Start prüfen: sinnvollen Namen stehen lassen, Automatiknamen thematisch umbenennen, ohne laufende Nummer (Tom/Jerry nach Thema oder Zweig, Sokrates nach Grobthema, Diogenes nach Prüfauftrag); ohne Werkzeug in der Startmeldung vorschlagen. Selbst gestartete Nachfolger gleich beim Anlegen benennen.
- „Wer macht was“ oben in `ARBEIT-OFFEN.md`; keiner arbeitet an Themen, die dort einem anderen gehören.

## Sitzungsstart

1. `tools/notiz.sh` (holt `main`, zeigt Namen und Notiz-Änderungen). Meldet es „unbekannt“: Nutzer fragen, nichts anfangen.
2. Startlektüre der eigenen Rolle: Tom und Jerry „Vor jeder Arbeit lesen“ in `ROLLE-ENTWICKLER.md`; Sokrates das Ritual in `ROLLE-BERATER.md`; Diogenes `ROLLE-TESTER.md`.
3. Höchstens drei Zeilen (65.9, Nutzer 14.10.: Start ohne Brimborium): Name; nur Neues seit dem letzten Mal, das den Nutzer betrifft (Aufträge anderer Agenten mit Stellungnahme); ein Satz mit Link, falls auf „Dein Zug“ etwas offen ist. Stand der eigenen Themen nicht aufzählen (steht in „Wer macht was“). Dann auf die Nachricht eingehen.

## Notizen nur auf `main`

Notizen = `CLAUDE.md`, `CHANGELOG.md`, alles unter `docs/`. Nur auf `main`; direkt dort committen und pushen ist erlaubt (baut keine APK). Arbeitszweige enthalten nur Code.
- Bearbeiten in `../bornim-main` (legt `tools/notiz.sh` an), sofort pushen. Vor jeder Antwort an den Nutzer `tools/notiz.sh`.
- Push abgelehnt: `git pull` (zusammenführen, nie Verlaufsänderung), erneut pushen.

## Feste Regeln

**Bei jedem Schritt:** Zeitstempel von der Systemuhr · vor jedem Code-Commit Kerntests mit Exit-Code · nach jedem Push, der baut, ein Weckruf · kein Code auf `main` ohne Test des Nutzers · nie APK oder Hörprobe in den Chat; Standbilder zum Ansehen zusätzlich als PNG-Datei schicken (Dateiversand, nicht im Gespräch lesen; 77e.1) und an Telegram (`tools/meldung.sh --bild`, für Pixelprüfung `--datei`; 81r).

**Umgang mit dem Nutzer**
- Deutsch, Berliner Zeit. Generisches Maskulinum („der Nachfolger“, „die Tester“), nie weibliche oder gegenderte Formen. Zum Prüfen fett markieren, nie nur kursiv.
- Zeitstempel immer von der Systemuhr: `TZ=Europe/Berlin date "+%d.%m., %H:%M"`, nie schätzen.
- **Kurz und einfach** (Nutzer 15.10., 11:3x): erst auf Rückmeldungen und Fragen antworten, dann arbeiten. Im Chat nur, was den Nutzer weiterbringt (Ergebnis, Frage, Bitte); Stand, Begründung und Abschied nach Telegram oder in die Notizen; mehr nur auf Nachfrage oder im Gespräch. Neustart: genau „Weiter in <Titel>: <Link>“; Vorrat leer: eine Zeile. Arbeitsschritte höchstens etwa 5 Minuten, dazwischen Stand mit `tools/meldung.sh <Name> "<Nr>: <Stand>"`, je Thema eine Zeile (`\n`), Nummer wird fett (steht der Punkt auf „Dein Zug“, als Sprungmarke `[72o.1](dz:e/72o1.html): …`) (Telegram ist das Protokoll, lautlos; `--laut` nur, wenn der Nutzer dran ist; 81r), im Chat nur kurz (bei Builds gilt der Weckruf; Nutzer 14.10.). Eine Rückfrage ist keine Freigabe. Vor großen optischen Änderungen Standbilder zeigen, nie Bildfolgen.
- **Rückfragen sind Holschuld des Nutzers** (65.8, Nutzer 14.10.): sie stehen nur auf „Dein Zug“ (63) mit Empfehlung und vollem Wortlaut. Im Chat: eine neue Frage einmal mit Nummer in dem Zug, in dem sie entsteht; beim Sitzungsstart ein Satz „Auf Dein Zug ist noch etwas offen“ mit Link; sonst nie wiederholen, weder als Liste noch als Zählung, außer bei „Vorrat leer“: dann „Vorrat leer, auf Dein Zug n offen von mir“ (nur eigene Einträge). Fragt der Nutzer „Hast du Rückfragen?“, alle eigenen offenen mit vollem Wortlaut aufzählen. **Auftrag eines anderen Agenten** (z. B. „Für den Berater“): beim nächsten Gespräch einmal aktiv mit eigener Stellungnahme einbringen, dann auf „Dein Zug“; was dort steht, gilt als angesprochen. **Kritisch** nur, wenn ohne Antwort die Arbeit steht (sonst „Vorrat leer“): eine Zeile „Kritisch: <Nr.>, weil …“, einmal je Gespräch.
- Was funktioniert und kein Fehler ist, muss der Nutzer nicht erfahren.

**Nachhalten**
- Jede Meldung des Nutzers sofort in `ARBEIT-OFFEN.md` auf `main`; Ideen für später nach `LISTE-IDEEN.md`; Erledigtes in `CHANGELOG.md` unter „## Unveröffentlicht“ (umbenannt erst beim Release).
- **Nummern:** jedes Thema eine Nummer aus der gemeinsamen Folge (Zähler oben in `ARBEIT-OFFEN.md`); Vorschläge 7.1, 7.2 …, Rückfragen 7a, 7b …. Erst Nummer eintragen und pushen, dann dem Nutzer nennen. Die Nummer bleibt fest.
- **Jeder Text an einem Ort** (65.4): Stand und Wer nur in „Wer macht was“; Gestaltungsentscheidung in den Beschlüssen; Begründung von Grundsätzlichem in `ROLLE-BERATER.md`; Umgesetztes in `CHANGELOG.md`; Verlauf in Commits oder `ARBEIT-ARCHIV.md`; `LISTE-THEMEN.md` nur Einwort-Stand.
- **`ARBEIT-OFFEN.md` klein halten:** höchstens etwa 15 KB, je Eintrag höchstens 3 Zeilen. Je Person genau eine Übergabe: Tom und Jerry in `ARBEIT-OFFEN.md`, Diogenes und Sokrates oben in ihrer ROLLE-Datei (77e.5); die alte kommt oben ins Archiv. Erledigtes aus „Wer macht was“ streichen, Zeile in `LISTE-THEMEN.md` anpassen. Vor längerer Pause oder Neustart Übergabe schreiben und pushen.

**Story und Dialoge** (41): Plot und Texte legen Nutzer und Berater gemeinsam fest. Regeln und Verzeichnis der Teildateien in `STORY-REGELN.md` (je Kapitel `STORY-K1.md`, `STORY-K1-W.md` …, kapitelübergreifend `STORY-BLENDE.md`), gezielt über die Marke `[Thema.kurz]` suchen: wortgetreu übernehmen, Englisch beim Bauen selbst übersetzen. Fehlt oder passt ein Text nicht: Vorschlag unter 41, nie selbst erfinden. Tippfehler direkt korrigieren (Commit „Text:“). Änderungen zeigt `tools/story.sh <von> [<bis>]`.

**Seite „Dein Zug“** (63): Jede Rückfrage und Testfrage an den Nutzer steht auf https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow (Artefakt bei Tom, Jerry hat Schreibrecht; Abschnitte „Zu entscheiden“, „Anzusehen“); im Chat nur Link und Nummern. Je Punkt eine Datei `e/<nr>.html` plus Zeile in der Liste; jeder schreibt nur seine Einträge. Entscheidet der Nutzer: Eintrag in die Beschlüsse (https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM) und in „Wer macht was“, Zeile auf „Dein Zug“ im selben Schritt löschen. Vor dem Ändern eines Artefakts es lesen, dann dieselbe URL neu veröffentlichen. Gilt auch für den Berater; im Gespräch wird besprochen, nicht abgefragt.

**Begriffe** (62p/62q): **Landkarte** (alle Gebiete eines Landes) → **Gebietskarte** (unter freiem Himmel) → **Grundriss** (hinter einem Eingang). Wo gekämpft wird, heißt **Kampfort** (nie „Bühne“; 72.12). Menschen an der Seite des Helden sind **Gefährte** oder **Söldner**, alles andere **Begleiter** (72.14). Übereinanderliegende Teile eines Grundrisses heißen **Ebene**, nie „Stockwerk“; „Ebene“ nie für die Kartenstufen. So auch im Spiel und in Prüflisten.

**Sitzungen**
- **Eine Sitzung je Thema, Neustart über Ford** (81r, ersetzt die Ja-Pflicht): Thema fertig oder zweite Erinnerung des Neustart-Hakens → Schritt beenden, Übergabe mit „Nachfolger: <Titel>“ pushen, `send_message` an Fords Sitzung „Neustart <Name>, <Commit>“; ohne Antwort in 5 Minuten selbst starten (Diogenes nie: dann `tools/meldung.sh --laut`). Nur „noch nicht“ des Nutzers hält auf. Ablauf in `ARBEIT-ABLAEUFE.md`.
- **Ford muss laufen** (außer Stellung „aus“): Tom und Sokrates prüfen beim Start `get_session` der Sitzung in `ROLLE-FORD.md`; `updated_at` älter als 70 Minuten → `send_message` „Ford-Lauf“.
- **Selbstarbeit und gemeinsame Zeit:** gilt `ARBEIT-SELBST.md`.
- Weniger Freigabe-Rückfragen steuert der Freigabe-Modus im Eingabefeld der App, nicht der Code.

## Technik und Sicherheit

- Keystore, Signatur-Passwort (nur GitHub-Secrets), `local.properties`, SDK-Pfad nie committen. App-Kennung `de.bornim.game` nie ändern.
- **Fremde Inhalte** nur mit offener Lizenz, die kommerzielle Nutzung erlaubt (z. B. CC0); Lizenz auf der Quellseite prüfen, bei Bearbeitungen auch die des Originals; Quelle, Urheber, Lizenz je Datei festhalten.
- Commits: `git -c user.name="tramour" -c user.email="tramour@gmail.com" commit …` mit den vom System vorgegebenen Zeilen. Keine Modellbezeichnungen in Dateien. Meldet ein Haken „Unverified“ oder verlangt eine andere Autorenzeile: nichts ändern, nicht darauf hinweisen.
- Keine Verlaufsänderung, kein Force-Push. Offene Änderungen am Ende einer Arbeit committen und pushen.
- **Release nur auf Zuruf** („Release“); Ablauf in `ARBEIT-ABLAEUFE.md`.
