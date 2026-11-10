# Wochenplan

Feste Zeitpunkte und Routinen: wer, wohin gemeldet, wo es liegt (143, 246). Stand 20.10., 13:2x. Spalte „Ablage“: Datei im Ordner `docs/` und die Stelle darin; „nur Telegram“ heißt, es wird nirgends gespeichert. Die Regeln stehen in den genannten Dateien; bei Widerspruch gelten sie, und wer einen Termin dort ändert, ändert hier die Zeile mit.

## Jeden Tag

| Wann | Was | Wer | Gemeldet | Ablage |
|---|---|---|---|---|
| 7:08 (Sa, So 9:08) | Ford-Wache: lebt Ford? Meldet sich nur bei Stillstand, dann ein Wort an Team Tom oder Perikles | Wache-Sitzung | Telegram mit Ton, nur bei Stillstand | nur Telegram |
| 7:30 (Sa, So, Urlaub 9:30) | **Tagesbericht** (448; einzige Morgenmeldung seit 783 W7): was du heute tun musst, Zahl offener Chefsache, Wochenziel als Ampel, geschafft, was hakt, Kosten, Bitte um das Bild der Nutzung, heute geplant; fehlt er um 10 Uhr (Sa, So 12 Uhr), meldet Ford | Perikles, Ford startet | Telegram mit Ton: Link und erste Zeile | oben in [ARBEIT-TAGESBERICHT.md](ARBEIT-TAGESBERICHT.md) |
| ab 8:00 | Erster Lauf: liegen gebliebene Anstöße und Befunde (älter als zwei Tage) leise an den Bereich; freigegebene, nicht zusammengeführte Builds als Muss ans Team | Ford | Telegram leise | [ARBEIT-BETRIEB.md](ARBEIT-BETRIEB.md#protokoll), Abschnitt „Protokoll“ |
| stündlich, :03 | Fords Lauf: startet Sitzungen, wo Arbeit startbar ist, archiviert Fertige, bucht Kosten, schreibt die Besetzung | Ford | Telegram leise | [ARBEIT-BESETZUNG.md](ARBEIT-BESETZUNG.md); Kosten als Spalte in [LISTE-VORGAENGE.md](LISTE-VORGAENGE.md) |
| laufend | Standzeile etwa alle 5 Minuten; jedes Bild der Chefsache auch als Bild | alle | Telegram leise | nur Telegram; Bilder zusätzlich in [chefsache/bilder](chefsache/bilder/) |
| sofort | „Du bist dran“: neuer Build zum Testen, Übergabe wartet auf den Chef, Sitzung hängt | Ford oder das Team | Telegram mit Ton | je Punkt eine Datei, Übersicht in [chefsache/README.md](chefsache/README.md) |
| bis 21:00 | Sind alle Vorräte leer, einmal am Tag „Vorrat leer“ | Ford | Telegram leise | – |
| 22–7 Uhr | nachts nichts mit Ton | alle | – | – |

## Woche

Jeder Wochentermin legt sich an seinem Tag selbst als Muss-Vorgang an (719, `startbar.WOCHENTERMINE`); Ford startet ihn wie jeden Vorgang.

| Tag | Was | Wer | Ablage |
|---|---|---|---|
| Mo ab 8:00 | Wochenzählung (Kennzahlen zählen, nicht bewerten), danach Wochenziel (Muss und Kür, Reifes aus dem Ideenspeicher) und Haken-Frage Abnahmeliste (720) | Diogenes, dann Perikles; Ford startet | Zählung: [PRUEFBERICHT.md](PRUEFBERICHT.md), oberster Abschnitt „Lauf n“; Wochenziel: oben in [PROJEKTPLAN.md](PROJEKTPLAN.md); Haken-Frage: Datei in [chefsache/ansehen](chefsache/ansehen/) |
| Di–Do | nur die täglichen Routinen | – | – |
| Fr ab 8:00 | Rollenspiegel je Rolle (`rollenspiegel.sh <Rolle>`, 759) | jede Rolle | `LISTE-ROLLENSPIEGEL.md` (nur über das Werkzeug) |
| Sa | Wache 9:08, Tagesbericht 9:30 | Ford, Perikles | – |
| So | Wache 9:08, Tagesbericht 9:30; Urteil über den Ideenspeicher: „reif“, „später“, „verwerfen?“ (verworfen nur mit Ja des Chefs) | Homer | Urteil je Idee in [LISTE-IDEEN.md](LISTE-IDEEN.md) |

## Einmalige Termine

| Wann | Was | Wer | Ablage |
|---|---|---|---|
| Mi 21.10. | Entscheid Stundenuhr nach Messung 20.–21.10. (177); Tagesrückblick Tag 3 mit Stichprobe (165) | Perikles | neue Datei in [chefsache/entscheiden](chefsache/entscheiden/) |
| Do 22.10. | Auswertung Messung Leitung (99h.6); letzter Tagesrückblick der Probe; Auswertung Ford-Grenze 400.000 Token (185) an Sokrates | Perikles | [ARBEIT-PROJEKT.md](ARBEIT-PROJEKT.md) |
| Fr 23.10. | Bilanz Tagesrückblick und Stichprobe mit dem Chef, danach weiter nur auf sein Wort; Bilanz Kosten je Vorgang (124) | Perikles | neue Datei in [chefsache/entscheiden](chefsache/entscheiden/) |
| Sa 24.10. | Termin Wochenziel: Kapitel 1 einmal ganz durchspielbar, der Chef spielt einmal durch | alle | [PROJEKTPLAN.md](PROJEKTPLAN.md) |
| Mo 26.10., 10:00 | Neues Wochenziel; Wiedervorlage Skript für Fords Lauf (167.2) und Morgenbericht (167.6) | Perikles; Sokrates (geplante Aufgabe) | neue Datei in [chefsache/entscheiden](chefsache/entscheiden/) |
| Sa 31.10. | Wieder vorlegen: Pflichttest Play Store (142) und Preis (45) | Sokrates | neue Datei in [chefsache/entscheiden](chefsache/entscheiden/) |
| um 10.11. | Prüfung der Abos vor der Verlängerung (Pro gekündigt, nur Max) | Perikles | [ARBEIT-PROJEKT.md](ARBEIT-PROJEKT.md) |

## Nur auf Zuruf

- **Release:** nur wenn der Chef „Release“ sagt ([Ablauf](LISTE-RELEASE-NEUSTART.md)).
- **Chefrunde:** der Chef geht die [Chefsache](chefsache/) mit Sokrates durch; Entschiedenes ins [Vorgangsarchiv](VORGANGSARCHIV.md), Datei gelöscht.
- **Sokrates** startet außerdem von selbst (höchstens zweimal am Tag), wenn eine Chefsache-Datei seine Stellungnahme braucht.
- **Diogenes** prüft vor jedem Release, wenn ein Ort „fertig“ ist, nach großen Umbauten und jeden Ablaufentwurf; nie nach jedem Build ([Prüfbericht](PRUEFBERICHT.md)).
- **Team Jerry** läuft in der Zentrale wie Team Tom, solange Pro ruht.

## Wo was landet (246)

- **Telegram:** Protokoll, jede Meldung, jedes Bild der Chefsache; Nummern mit Datei sind Sprungmarken auf die Chefsache.
- **Repo (MD):** alles, was gilt oder nachgeschlagen wird, auch Berichte und Übersichten wie diese; Einstieg [Inhaltsverzeichnis](README.md).
- **Artefakt:** nur Geschäftsmodell, Markt und Preise (Geheimhaltung, Chef 20.10.) sowie Entwürfe zum Kommentieren, die eine Quelle im Repo haben.
