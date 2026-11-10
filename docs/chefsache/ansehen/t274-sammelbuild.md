# Tom und Jerry · Build 274 · Godot 0.348.322 · BRS-Held mit Fertigkeiten, Skelette, Nachtests · [PR #193](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/193)
Ganzes Spiel · Tom (617, 540, 583, 543, 834, 795, 762, 471, 610, 522, 670, 635, 506), Jerry (593, 597, 547) · 10.11., 11:52 · [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42793721837/artifacts/13756287941) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42793721837

Ein Weg: Hauptmenü und neues Spiel (A), BRS-Held und Fertigkeiten (B), Dorf: Held, Menü, Südrand, Tempel (C), Probekämpfe im Reiter „Test“ (D), Wald (E); über Build 273 installieren. Was nicht passt, reicht als Nummer (z. B. 274.4) mit einem Wort.

Neu sind 834 (BRS-Held übernehmen, damit 762, 471, 795 aus t273 jetzt prüfbar sind) und 506 (Skelette, dein Bild „passt“ 10.11., 09:00); alles andere liegt seit Build 268 bis 272 auf `main` und hatte noch keine Prüfzeile. Verglichen (alt gegen neu): kein Schirm neu (670 mit 630 abgenommen 08.11., 18:14; Platzwahl 795 gegen die abgenommene alte 700). Erreichbar: Weg zum BRS-Helden im Reiter „Test“ (834, `brs_held_834` am Rechner mit allen vier Plätzen belegt); „Skelette“ steht unter „Kampf beschwören“, weil das Modell im Bau liegt. Im Bau und am Rechner mit den Kaufmodellen geprüft: `brs_held_834`, `testmenue_470`, `fertigkeiten_762`, `brs_471`, `kampfuebung_471`, `skelett_506`, `starttexte_540`, `startwerte_543`; im Bau `auftraege_542`, `truhe_632`, `ansage_597`.

## A · Hauptmenü und neues Spiel

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 274.1 | Tom | 617 | Hauptmenü → „Laden“: über die Liste der Spielstände wischen, dann einen Stand mit dem Knopf rechts laden | Wischen lädt nichts; nur der Knopf rechts lädt | ein Wisch startet den Spielstand |
| 274.2 | Tom | 540 | System: klassische Steuerung; „Neues Spiel“ als Kämpfer; Erwachen in der Schenke | der Tipp zur Steuerung kommt auch bei klassischer Steuerung | kein Tipp |
| 274.3 | Tom | 583 | dieselben Texte beim Erwachen lesen | ▼ unter der letzten Zeile im Rand; Erzähltes schräg, mit i-Punkten; Gesprochenes gerade | ▼ mitten im Text; Erzähltes gerade oder ohne i-Punkte |
| 274.4 | Tom | 543 | Menü → „Tasche“ gleich nach dem Erwachen ansehen | Kämpfer: 15 Gold und 2 Heiltränke (Magier 20 und 3, Schurke 25 und 2, Kleriker 15 und 1) | kein Gold oder keine Heiltränke |

## B · BRS-Held und Fertigkeiten

Der Kampf bleibt bis BRS 2.3 nach SRD; neu ist nur, dass der BRS-Held ins Spiel kommt.

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 274.5 | Tom | 834, 795 | alle vier Spielstand-Plätze belegt; Reiter „Test“ → „Erschaffung BRS“, Volk und Herkunft wählen, eine Fertigkeit selbst wählen, „Abenteuer beginnen“ | das laufende Spiel wird gespeichert; Platzwahl wie die alte Erschaffung: jeder Platz eine Zeile über die ganze Breite mit „›“, ohne Rahmen, gewählt erst beim Loslassen; danach beginnt ein neues Spiel mit Rowena | wieder im Laden oder am alten Ort; Rahmen um jeden Platz; Fertigkeit nicht wählbar (0 / 1) |
| 274.6 | Tom | 762 | Menü → Reiter „Fertigkeiten“ (neben Held) | acht Gruppen, jede mit Kopfzeile und „geübt/alle“; Gruppen mit Geübtem offen, Pfeil nach unten; Tipp auf den Kopf klappt zu, Pfeil nach rechts; geübte Fertigkeiten mit Rang, Wert und Balken | Reiter fehlt, Klappen ohne Wirkung, Pfeil falsch herum |
| 274.7 | Tom | 762 | eine Gruppe zuklappen, Spiel ganz beenden und neu laden, Reiter wieder öffnen | die Gruppe ist noch zu | alles wieder offen |
| 274.8 | Tom | 762 | Reiter „Held“ | die drei höchsten Fertigkeiten und ein Sprung zum Reiter „Fertigkeiten“ | nur die alten Klassenfähigkeiten |
| 274.9 | Tom | 471 | beim Händler etwas kaufen oder verkaufen, dann Reiter „Fertigkeiten“ | Handeln hat etwas dazugewonnen (Balken oder Wert höher) | nichts bewegt sich |

## C · Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 274.10 | Tom | 670 | Menü öffnen, nacheinander „Held“, „Tasche“, „Ausrüstung“, „Karte“, „Chronik“, „System“ | jeder Schirm ohne Kasten: Titel, eine Goldlinie mit Raute darunter, Zeilen zwischen feinen Linien, Zurück unten | alter Kasten mit Rahmen, zwei Linien übereinander |
| 274.11 | Tom | 522, 610 | Reiter „Test“, „Waffe“: Dolch, dann Krummsäbel, Handaxt, Kurzbogen; „Andere Hand“: Schild; zurück ins Dorf und den Helden ansehen | jede dieser Waffen und der Schild sind am Helden zu sehen; Finger an der Waffe ruhig | Waffe oder Schild unsichtbar; Finger zucken ohne Unterlass |
| 274.12 | Tom | 540 | vor dem Gespräch mit Aldric zum Südrand des Dorfs gehen, zweimal | erst „Du bist von Süden gekommen, um hier zu rasten. …“, beim zweiten Mal kurz „Erst willst du wissen, was in Bornim geschehen ist.“ | jedes Mal der lange Text oder gar keiner |
| 274.13 | Tom | 635 | in den Tempel gehen | Lyra steht als Figur dort | Platz leer |

## D · Probekämpfe (Reiter „Test“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 274.14 | Tom | 506 | „Kampf beschwören“ → „Skelette“, als Kämpfer | drei Skelettritter: Kurzschwert und Helm, Kurzschwert und Schild, Speer und Helm; Waffen beim Stehen und Gehen gesenkt; Schatten am Boden | Waffe in die Luft gereckt; Skelett ohne Schatten |
| 274.15 | Jerry | 593 | „Ratten“, dann „Spinne allein“, „Grak“: mehrmals angreifen, bis sie ausweichen | etwa jedes dritte Ausweichen geht rasch nach hinten; keiner läuft in einen anderen | nur links und rechts; rückwärts im Schneckentempo |
| 274.16 | Jerry | 597 | „Wolfsrudel“, dann „Ratten“, „Fledermäuse“ | über jedem Wolf vor dem Sprung „! Anspringen“ (oder „Einkreisen“), das Ziel an der Farbe des Rahmens; Wolf, Ratte, Fledermaus nie mit Ring ohne Ansage | Sprung ohne Ansage; Ring ohne Ansage |
| 274.17 | Jerry | 547 | „Wolfsrudel“, bis ein Wolf den Helden anspringt | Text „… springt … an. … wird zurückgestoßen.“, dann „… fängt sich wieder.“ | „geht zu Boden“, „geht in die Knie“, „steht wieder auf“ |

## E · Wald (mit dem BRS-Helden)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 274.18 | Tom | 471 | im Wald über ein Heilkraut laufen, dann einen Kampf gewinnen, Blende abwarten, Reiter „Fertigkeiten“ | Notiz „Kräuterkunde ↑ …“; nach der Blende eine Notiz wie „Schwert ↑ 12“; Waffe, Abwehr oder Rüstung und Kräuterkunde haben dazugewonnen | keine Notiz, Werte unverändert |

Bekannt: Stab und 13 weitere Waffen haben am Helden noch kein Modell (458.3). Nicht am Gerät prüfbar, nur im Bau: 542 (Jorins Fetzen erst nach Krogg, Gwennas Ring in der Truhe der Höhle) und 632 (Truhe der Höhle), sichtbar erst mit der Höhle (492). 532 fährt nach seinem Fund t273.13 wieder mit.
