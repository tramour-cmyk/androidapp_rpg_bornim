# Tom und Jerry · Build 275 · Version folgt · Sammelbuild vor dem Umzug BRS · [PR #194](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/194)
Ganzes Spiel · Tom (663, 470, 661, 475, 540, 653, 506), Jerry (709, 506.1, 854, 870.2, 870.3) · 10.11., 20:35 · APK folgt · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/claude/build-275
Gegengelesen: Sokrates 10.11., 20:34 (Wege gegen `testmodus.gd`, `probe.gd`, `spiel.gd`, `kampfblende.gd` auf `6814e4331`)

Ein Weg: Hauptmenü und neues Spiel (A), Schenke und Dorf (B), Probekämpfe im Reiter „Test“ (C); über Build 274 installieren. Den Reiter „Test“ gibt es nur im Testmodus: im Hauptmenü siebenmal aufs Firmenzeichen tippen. Was nicht passt, reicht als Nummer (z. B. 275.4) mit einem Wort.

Letzter Build vor dem Umzug auf das BRS (870); danach geht er auf `main`. Abgleich alt gegen neu: Seite „Neues Spiel“ mit der alten Erschaffung (470, abgenommen 10.11., 13:37), Blenden mit der alten Fassung (661, Bild passt); sonst kein Schirm neu. Im Bau und am Rechner geprüft: `brs_470`, `brs_held_834`, `testmenue_470`, `knopf_630`, `tasten_4161`, `spielstand_test`, `starttexte_540`, `suedrand_540`; im Bau `treffen_709`, `skelett_506`, `untote_506`, `anmarsch_506_1`, `brs_blatt_870` (870.2 Kampfwerte des Helden aus dem BRS), Gegnerwerte und Fähigkeiten nur aus `werte.json` (870.3), gebaute Kaufmodelle aus dem Ablage-Zweig (854).

## A · Hauptmenü und neues Spiel

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 275.1 | Tom | 470 | Hauptmenü → „Neues Spiel“ | Seite nach BRS: Volk, Herkunft, Grundwerte, Fertigkeiten; ohne Kasten, Zierlinie unter dem Kopf, unten „‹ ZURÜCK“ und „ABENTEUER BEGINNEN ›“; keine Klassenwahl | alte Klassenwahl (Kämpfer, Magier …) |
| 275.2 | Tom | 470 | Volk Mensch, Herkunft Wanderer; mit „−“ ein paar Punkte offen lassen, dann alle verteilen und die eigene Fertigkeit des Menschen wählen | „ABENTEUER BEGINNEN ›“ bleibt gedämpft, solange Punkte offen sind oder die Fertigkeit fehlt, Fehlendes steht dabei; danach tippbar, das Spiel beginnt in der Schenke | Knopf von Anfang an tippbar oder bleibt grau |

## B · Schenke und Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 275.3 | Tom | 663 | in der Schenke Beutel → „System“ öffnen | keine Wahl „Steuerung“ mehr | Wahl „Steuerung“ oder „Klassisch“ da |
| 275.4 | Tom | 663 | durch die Schenke und das Dorf bis zum Südrand gehen | nur Touch: kein Steuerkreuz, keine Knopfleiste; kein Tipp zur klassischen Steuerung | Steuerkreuz oder Funktionstasten sichtbar |
| 275.5 | Tom | 475 | in der Schenke Rowena und Borin ansehen und ansprechen | beide auf neuem Körper mit eigenem Gesicht; Borin heller, kupferroter Bart | alte Figuren, Gesicht leer oder verzerrt |
| 275.6 | Tom | 661 | Rowena ansprechen → an der Theke „Zimmer · 5 Gold“ nehmen | Rastblende: Name gesperrt, Zierleiste mit Raute, Satz groß wie die Schirme ohne Kasten | kleiner Text, alter Strich, Kasten |
| 275.7 | Tom | 475 | im Dorf Bram, Jorin, Pim, Liska, Gwenna ansehen; Aldric im Haus des Ältesten | jeder auf neuem Körper mit eigenem Gesicht; Bram sonnenverbrannt mit dunkelbraunem Bart, von Borin zu unterscheiden | alte Figur, zwei gleich aussehende Gesichter, Kleidung durchdringt die Haut |
| 275.8 | Tom | 661, 475 | Thessas Kramladen zum ersten Mal betreten, Thessa ansehen | Ortsblende im selben Aufbau und derselben Größe wie die Rastblende; Thessa auf neuem Körper mit Gesicht | Blende kleiner als die Rastblende; alte Thessa |
| 275.9 | Tom | 540 | vor dem Gespräch mit Aldric schräg gegen den Südrand des Dorfs gehen, nach zwei Sekunden noch einmal | erst „Du bist von Süden gekommen, um hier zu rasten. …“, beim zweiten Mal kurz „Erst willst du wissen, was in Bornim geschehen ist.“ | kein Text, wenn man schräg an den Rand geht |
| 275.10 | Tom | 653 | Reiter „Test“, „Waffe“ reihum: Langschwert, Handbeil, Kurzbogen; Teleport „Dorf“, Held von vorn und von der Seite ansehen; dann „Waffe“ Langschwert, „Andere Hand“ reihum bis „Schild“, wieder ansehen | Waffe fest in der Faust, Klinge nach vorn; Bogen senkrecht; Schild außen vor dem Unterarm, Arm nicht im Brett | Waffe schwebt neben der Hand oder zeigt nach hinten; Arm steckt im Schild |

## C · Probekämpfe (Reiter „Test“ → „Kampf beschwören“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 275.11 | Tom | 661 | „Krogg“ beschwören, Beginn ansehen; dann „Eröffnung: Gegner zuerst“, „Ratten“ | Kampfblende im selben Aufbau wie Ort und Rast; Krogg mit Boss-Blende; Hinterhalt mit gebrochener Zierleiste | alte kleine Blende; Boss und Hinterhalt wie ein normaler Kampf |
| 275.12 | Tom | 506 | Eröffnung zurück auf „Normal“, „Skelette“ | Skelette stehen ruhig, jedes für sich; kein Zappeln, kein Wackeln mit dem Schwert im Gleichklang | alle wackeln zugleich auf der Stelle |
| 275.13 | Jerry, Tom | 506.1, 506 | „Wiedergänger“ | die drei gehen langsam, auch der hintere ist nach wenigen Schritten vorn und schlägt zu; Schläge treffen | der hintere braucht eine halbe Ewigkeit |
| 275.14 | Tom | 506 | „Grabhunde“, einen von nah ansehen | Mähne nur als Kamm hinter den Ohren, kein rechteckiger Fleck, Augen hell und trüb | Fleck am Hals, keine Augen |

Bekannt, nicht in diesem Build: Treffer von Ratten, Krogg und Grak (709, im Film 709.1 um 19:29 schon beurteilt, Folge bei Jerry); Grabhund-Biss am Ziel und Wolfsbiss (709.1); eigener Klang für Krogg; Lyra im Tempel (635). Kampfwerte von Held und Gegnern kommen schon aus dem BRS (870.2, 870.3); fühlen sich Treffer und Leben anders an, ist das gewollt, die Zahlen legt Jerry vor B1 vor.
