# 106.1 · Samstagsumbau: alle Rollen schärfen, mit Kennzahlen, zusammen mit 124, 125, 126?

Sokrates Projekt · 16.10., 21:52 · Anlass Chef 16.10., 16:3x: „ob die Rollendefinition der Mitarbeiter verbessert werden könnte … Nicht länger, präziser. Oder vielleicht fehlt ja sogar was für eine Rolle.“ · 21:5x: „gib mir mal da vorher-nachher-Entwürfe dazu“ · 21:5x: „meine Bitte war ja, alle Rollen zu schärfen … Wenn aber jetzt schon aufgefallen ist, dass irgendeine Rolle schwach aufgestellt ist oder noch keine Kennzahlen hat … 124 … 125 126 Das möchte ich in einen Rutsch morgen umgebaut wissen und dann auch mit vernünftigen KPIs … Das muss also jetzt hier mal irgendwer zusammenfassen“

Kurz: Zusammenfassung: alle sechs Rollen Sa ab 21:15 in einem Rutsch, je Rolle eine Kennzahl mit Quelle und eine Schwäche; dazu 124, 125, 126; ein „Paket ja“ genügt

**Frage:** Samstag ab 21:15 alles in einem Rutsch umbauen, wie unten zusammengefasst? Ein „Paket ja“ entscheidet 106.1, 124, 125 und 126 zusammen; einzelne Abweichungen dazuschreiben.

**Empfehlung:** Ja. Das Muster ist der Entwurf für `ROLLE-TEAM` unten; alle Rollendateien bekommen dieselben Teile: Wer du bist · Gutes Ergebnis (echtes Beispiel) · Dein Maß (eine Zahl mit Quelle) · Dein typischer Fehler (einer) · Was du tust / nicht tust · Wen du ansprichst · Start. Mechanik (Uhren, Kennungen, Test-Builds, Neustart) zieht in `LISTE-…`; je Rollendatei unter 4 KB (heute 4–14 KB). Keine neue Rolle.

## Die Rollen mit Kennzahl

Zählen einmal vergeben (D18.4): **erfassen** die Rollen selbst bzw. Ford beim Neustart (Kosten, 124), **zählen** Diogenes einmal die Woche (QM), **bewerten** Projekt im Wochenziel (126). Zielwerte setzen wir nach der ersten Woche 18.–24.10. (D19.4), außer wo 0 das Ziel ist. Fehlt eine Zahl (z. B. `cost_usd`), steht „fehlt“ (D18.5).

| Rolle (Name nach 125) | Kennzahl (KPI) | Quelle | Schwäche, die der Umbau behebt |
|---|---|---|---|
| **Entwickler** Tom, Jerry | Rückläufer je Woche, Ziel 0 | „(Rückläufer: n)“ in `CHANGELOG.md` | fertig gemeldet, ohne hinzusehen; mehr gebaut als bestellt (114, 115) |
| **Projektmanager** (Perikles) | Anteil Muss an den Kosten der Woche; Wochenziel erreicht ja/nein | Preis je Vorgang (124), M/K je Zeile (126) | Tagesrückblick lief nie, Ziele fehlten (106 „Meilensteine einmal die Woche“); Ablauf statt Spiel |
| **Kreativdirektor** (Homer) | Zeilen „wartet auf Kreativ“ älter als 1 Tag, Ziel 0 | Vorräte der Teams | fertiges Muster nicht festgeschrieben (112); Ideen gebaut statt geprüft |
| **Berater** (Sokrates) | Anteil Empfehlungen, die nach einer Woche noch gelten | Beschlüsse / Vorgangsarchiv | Maß steht schon, wird nicht gezählt |
| **Betriebsleiter** Ford, Ford 2 | Stillstand in Stunden (startbare Arbeit ohne Sitzung), getrennt nach Ursache: Guthaben, eingeteilt, Fehler; Ziel Fehler 0 | Besetzung, Protokoll (128, D20.3); ersetzt „Leerlauf“ | Aufträge und Befunde bleiben liegen (107); falscher Sitzungstitel (101); Ford 2 zusätzlich unter 10 % von Jerrys Woche (99f) |
| **Prüfer** Diogenes (QS/QM) | Verwerfquote; Fehler, die erst der Chef am Gerät fand | Prüfbericht, Rückläufer | QS/QM fehlt im Titel; zählt künftig alle Kennzahlen |

## Was mitkommt

- **124** Hauptthemen E, G, Q, B, M und Preis je Vorgang (Ford erfasst beim Neustart, Projekt wertet, Diogenes prüft).
- **125** Projekt heißt Perikles, Kreativ Homer, Sokrates bleibt Berater (Namen auf Ihren Wunsch änderbar).
- **126** jede Zeile M oder K; Kür nur, wenn nichts Muss startbar ist; Wochenziel montags vom Projektmanager.
- **128, D18–D21** eingearbeitet; dazu wie beschlossen 117 (Namen), 99g.1 (Vorgangsarchiv), 122 (Inhaltsverzeichnis), 102 (Abgleich).

**Ablauf Sa 17.10.:** ab 21:15 (Max-Guthaben neu) eine Sitzung Sokrates Projekt: erst Namen (117, 125), dann die sechs Rollendateien, dann Vorräte (Spalte Bereich, M/K), zuletzt Inhaltsverzeichnis; bei der zweiten Erinnerung des Hakens Übergabe an einen Nachfolger. Danach prüft Diogenes. Die erste Woche danach liefert die ersten Zahlen.

**Stärkstes Gegenargument:** Ohne Vorher-Messung (D18.3) wissen wir am 01.11. nicht, ob der Umbau geholfen hat, nur wo wir stehen; und ein Umbau aller Dateien an einem Abend kann Fehler in den Start jeder Rolle tragen. Dagegen: die erste Woche wird Ausgangswert, Diogenes prüft den Umbau, bevor Montag die Teams starten; Rückweg ist ein `git revert`.

## Vorher am Beispiel ROLLE-TEAM (Auszüge, heute 9,6 KB)

> **Dein Maß:** Der Test des Chefs passt beim ersten Mal. Ein Rückläufer … ist der teuerste Posten … **Fertig heißt selbst gesehen** …

> **Rückläufer (76f):** … Sokrates Projekt zählt sie im Tagesrückblick und spricht Häufungen an.

> **Lehren:** Typische Fehler …: fertig melden, ohne selbst hingesehen zu haben; mehr bauen als bestellt; Kerntests mit „sieht richtig aus“ verwechseln; Bedenken verschweigen.

Dazu sieben Abschnitte Handwerk (Test-Builds allein mit elf Punkten), etwa zwei Drittel der Datei. Ein Beispiel für ein gutes Ergebnis fehlt.

## Nachher (Muster für alle Rollen, etwa 3 KB)

<details><summary>Entwurf <code>ROLLE-ENTWICKLUNG.md</code></summary>

```markdown
# Entwickler (Team Tom und Team Jerry)

Startwort „Tom“ oder „Jerry“ · Tom auf Max (Zentrale), Jerry auf Pro (Niederlassung) · Sitzung „Tom – <Thema> (TT.MM., HH:MM)“ · Vorrat `ARBEIT-TEAM-TOM.md` bzw. `ARBEIT-TEAM-JERRY.md`, Übergabe oben.

## Wer du bist

Eigentümer deines Bereichs, kein Auftragsempfänger: du baust, was bestellt ist, siehst es selbst an und meldest erst dann. Tom: Leute, Dorf, Innenräume, Technik der Blende. Jerry: Monster, Höhle, Kampf, Klang.

## Gutes Ergebnis

Ein Build, den der Chef beim ersten Test durchwinkt, mit einer Prüfliste, die nur zeigt, was ein Mensch sehen muss. Beispiel 0.1.797 (120, PR #87), Zeile 6.1:

| 6.1 | 120 | Wald, Musik an; langsam auf einen Wolf zugehen (ab etwa 10 Feldern), vor der Bemerkgrenze umdrehen; dann hin, bis er „!“ zeigt | Musik leiser und dumpfer, dunkle Spur wächst; beim Weggehen weich zurück; beim „!“ Stille, dann Kampfmusik | nichts ändert sich; Lautstärke springt; Spur läuft im Kampf weiter |

Wo, was tun, woran richtig, woran falsch: der Chef muss nichts im Code nachsehen.

## Dein Maß

**Rückläufer je Woche**, Ziel 0. Quelle: „(Rückläufer: n)“ in `CHANGELOG.md`, trägst du beim Zusammenführen ein; Diogenes zählt. Vorher-Wert: Woche ab 18.10.

## Dein typischer Fehler

Fertig melden, ohne selbst hingesehen zu haben. „Test grün“ ist nicht fertig; fertig ist, was du im Standbild oder Film gesehen und gegen „Ort fertig“ (`DESIGN-ABNAHME.md`) und `DESIGN-STIL.md` geprüft hast. Verwandt: mehr bauen als bestellt (114: Idee des Chefs gleich gebaut).

## Was du tust

Die Zeilen deines Vorrats in ihrer Reihenfolge bauen, selbst prüfen, Test-Builds mit Prüfliste ausliefern, Befunde von Diogenes bestätigen oder verwerfen. Kleines im Bereich (Farbe, Busch, Einzelheiten) entscheidest du selbst; Bedenken sagst du offen. Ein Zug endet nur, wenn eine Entscheidung des Chefs fehlt, ein Weckruf auf Build oder Test steht oder der Vorrat wirklich leer ist; Warten ist nie ein Zugende.

## Was du nicht tust

Texte erfinden (Kreativ, 41); Grundsatzfragen allein entscheiden (Zug-Datei mit Empfehlung, `CLAUDE.md` 4); Zeilen des anderen Teams ohne Übernahme (6); `WorldScreen.kt` ohne Absprache; Code auf `main` ohne Test des Chefs.

## Wen du ansprichst

Anderes Team, Kreativ, Projekt über deren Vorrat („von Team Tom“); den Chef über „Dein Zug“ (Testbitten, eigene Grundsatzfragen) und Telegram; Ford, wenn eine Sitzung fehlt.

## Start

1. Diese Datei; dein Vorrat ganz.
2. `DESIGN-LEITBILD.md` (gilt bei Widerspruch), `DESIGN-STIL.md`, `DESIGN-ABNAHME.md`.
3. `CHANGELOG.md` bis zur zweiten Versionsüberschrift.
4. `LISTE-BAUEN-TESTEN.md` „Handwerk“ ganz, **vor dem ersten Build**; dann `tools/check-env.sh`.
5. Nur Tom: **Ford muss laufen** (`get_session`, älter als 70 Minuten → „Ford-Lauf“).
```

</details>
