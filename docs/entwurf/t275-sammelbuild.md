# Tom und Jerry · Build 275 · Version folgt · Sammelbuild vor dem Umzug BRS · [PR #194](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/194)
Ganzes Spiel · Tom (663, 470, 661, 475, 540, 653, 506), Jerry (709, 506.1, 854) · 10.11., 19:15 · APK folgt · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/claude/build-275

Ein Weg: Hauptmenü und neues Spiel (A), Schenke und Dorf (B), Probekämpfe im Reiter „Test“ (C); über Build 274 installieren. Was nicht passt, reicht als Nummer (z. B. 275.4) mit einem Wort.

Letzter Build vor dem Umzug auf das BRS (870); danach geht er auf `main`. Abgleich alt gegen neu: Seite „Neues Spiel“ mit der alten Erschaffung (470, abgenommen 10.11., 13:37), Blenden mit der alten Fassung (661, Bild passt); sonst kein Schirm neu. Im Bau und am Rechner geprüft: `brs_470`, `brs_held_834`, `testmenue_470`, `knopf_630`, `tasten_4161`, `spielstand_test`, `starttexte_540`, `suedrand_540`; im Bau `treffen_709`, `skelett_506`, `untote_506`, `anmarsch_506_1`, gebaute Kaufmodelle aus dem Ablage-Zweig (854).

## A · Hauptmenü und neues Spiel

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 275.1 | Tom | 663 | Hauptmenü → „System“ öffnen | keine Wahl „Steuerung“ mehr | Wahl „Steuerung“ oder „Klassisch“ da |
| 275.2 | Tom | 470 | Hauptmenü → „Neues Spiel“ | Seite nach BRS: Volk, Herkunft, Grundwerte, Fertigkeiten; ohne Kasten, Zierlinie unter dem Kopf, unten „‹ ZURÜCK“ und „ABENTEUER BEGINNEN ›“; keine Klassenwahl | alte Klassenwahl (Kämpfer, Magier …) |
| 275.3 | Tom | 470 | Volk und Herkunft wählen, Punkte noch nicht ganz verteilen, dann alles verteilen und eine Fertigkeit selbst wählen | „ABENTEUER BEGINNEN ›“ bleibt gedämpft, bis alles verteilt ist, Fehlendes steht dabei; danach tippbar, das Spiel beginnt in der Schenke | Knopf von Anfang an tippbar oder bleibt grau |

## B · Schenke und Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 275.4 | Tom | 663 | Erwachen in der Schenke, durchs Dorf bis zum Südrand gehen | nur Touch: kein Steuerkreuz, keine Knopfleiste; kein Tipp zur klassischen Steuerung | Steuerkreuz oder Funktionstasten sichtbar |
| 275.5 | Tom | 475 | in der Schenke Rowena und Borin ansehen und ansprechen | beide auf neuem Körper mit eigenem Gesicht; Borin heller, kupferroter Bart | alte Figuren, Gesicht leer oder verzerrt |
| 275.6 | Tom | 661 | in der Schenke ans Bett gehen und rasten | Rastblende: Name gesperrt, Zierleiste mit Raute, Satz groß wie die Schirme ohne Kasten | kleiner Text, alter Strich, Kasten |
| 275.7 | Tom | 475 | im Dorf Bram, Jorin, Pim, Liska, Gwenna ansehen; Aldric im Haus des Ältesten | jeder auf neuem Körper mit eigenem Gesicht; Bram sonnenverbrannt mit dunkelbraunem Bart, von Borin zu unterscheiden | alte Figur, zwei gleich aussehende Gesichter, Kleidung durchdringt die Haut |
| 275.8 | Tom | 661, 475 | Thessas Kramladen betreten, Thessa ansehen | Ortsblende im selben Aufbau und derselben Größe wie die Rastblende; Thessa auf neuem Körper mit Gesicht | Blende kleiner als die Rastblende; alte Thessa |
| 275.9 | Tom | 540 | vor dem Gespräch mit Aldric schräg gegen den Südrand des Dorfs gehen, dann noch einmal | erst „Du bist von Süden gekommen, um hier zu rasten. …“, beim zweiten Mal kurz „Erst willst du wissen, was in Bornim geschehen ist.“ | kein Text, wenn man schräg an den Rand geht |
| 275.10 | Tom | 653 | Reiter „Test“, „Waffe“: Langschwert, Handaxt, Kurzbogen; „Andere Hand“: Schild; zurück ins Dorf und den Helden von vorn und von der Seite ansehen | Waffe fest in der Faust, Klinge nach vorn; Schild außen vor dem Unterarm, Arm nicht im Brett; Bogen senkrecht | Waffe schwebt neben der Hand oder zeigt nach hinten; Arm steckt im Schild |

## C · Probekämpfe (Reiter „Test“ → „Kampf beschwören“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 275.11 | Jerry | 709 | „Ratten“, dann „Krogg“, dann „Grak“; ein paar Runden zusehen | jeder Hieb und Biss landet am Helden oder an seinem Schild; Krogg trifft mit dem Morgenstern | Schlag in die Luft vor dem Helden |
| 275.12 | Tom | 661 | Beginn des Kampfs gegen Krogg; dann „Eröffnung: Gegner zuerst“, „Ratten“ | Kampfblende im selben Aufbau wie Ort und Rast; Krogg als Boss mit eigenem Tempo und Klang; Hinterhalt mit gebrochener Zierleiste | alte kleine Blende; alle drei gleich |
| 275.13 | Tom | 506 | Eröffnung zurück auf „Normal“, „Skelette“ | Skelette stehen ruhig, jedes für sich; kein Zappeln, kein Wackeln mit dem Schwert im Gleichklang | alle wackeln zugleich auf der Stelle |
| 275.14 | Jerry, Tom | 506.1, 506 | „Wiedergänger“ | die drei gehen langsam, auch der hintere ist nach wenigen Schritten vorn und schlägt zu; Schläge treffen | der hintere braucht eine halbe Ewigkeit |
| 275.15 | Tom | 506 | „Grabhunde“, einen von nah ansehen | Mähne nur als Kamm hinter den Ohren, kein rechteckiger Fleck, Augen hell und trüb | Fleck am Hals, keine Augen |

Bekannt, nicht in diesem Build: Grabhund-Biss am Ziel und Wolfsbiss (709.1, Film beim Chef vorher); Lyra im Tempel (635).
