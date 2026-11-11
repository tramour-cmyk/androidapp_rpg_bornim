# Tom und Jerry · Build 276 · B1 · Umzug BRS: Held und Kampf · PR folgt
Ganzes Spiel · Tom (870.4, 870.8), Jerry (870.5, 705) · Entwurf 11.11., 03:33, ergänzt 11:33 · [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42992315811/artifacts/13846274684) · Geprüft an: `claude/tom-870-4-held` `ed7795954` (Lauf 346)
Rot, bekannt, nicht melden: `wildschwein_494`, `skelett_506` – erwarten noch die Lebenspunkte der alten Regelfassung (922, Jerry); Start- und Absturztests grün.
Gegengelesen: Sokrates 11.11., 11:37

Ein Weg: Hauptmenü mit deinem Spielstand aus Build 275, dann neues Spiel mit Wanderer (A), Schenke und Dorf mit Heldenreiter und Rast (B), Wald mit Wolfskampf (C), Probekämpfe der anderen Herkünfte im Reiter „Test“ (D); über Build 275 installieren. Den Reiter „Test“ gibt es nur im Testmodus: im Hauptmenü siebenmal aufs Firmenzeichen tippen. Was nicht passt, reicht als Nummer (z. B. 276.5) mit einem Wort.

Zu den roten Prüfungen: Zwei Prüfungen im Bau sind rot, weil sie bei Wildschwein, Riesen-Hundertfüßer, Riesenegel, Riesenratte, Riesenfledermaus (alle in `wildschwein_494`) und Skeletten (`skelett_506`) noch die Lebenspunkte der alten Regelfassung erwarten; die Kämpfe selbst laufen und gewinnt der Held (922, Jerry).

Erster Build ganz nach dem BRS: Held und Kampf rechnen nur noch nach unserem System, ohne SRD-Werte. Spielstände aus Build 275 und früher laden nicht mehr (Entscheid 870a 1); sie stehen mit Hinweis in der Liste und lassen sich löschen.

Verglichen (alt gegen neu): Heldenreiter mit dem Reiter von Build 275 (Grundwerte, Balken, Kampfwerte); Rastwahl am Lagerfeuer mit Build 275.

Im Bau geprüft: `brs_held_870`, `brs_held_834`, `brs_470`, `spielstand_test` (mit echtem Spielstand aus Build 275), `spielstaende_529`, `testmenue_470`, `testmenue_555`, `handlungen_870`, `faehigkeiten_534`, `brs_kampf_478`, Zahlen der Welt nur aus `werte.json` (870e).

Am Rechner geprüft (11.11., 07:43, Stand `97a32cfe2`; laufen nicht im Bau): `mars_regeln` 0 abweichend; `sim444_870` je Herkunft gegen Rudel, Krogg, Grimmzahn, Grak, 200 Kämpfe je Zelle, ohne Ring: Zahlen wie in 870c (Wachsoldat gegen Grak auf Stufe 6: 83 %); der seltene Skriptfehler im Autopiloten des Zauberlehrlings gegen Grimmzahn und Grak ist behoben (904, geprüft von Jerry am Rechner auf `f8f3b2bf8` mit `sim444_870`, 200 Kämpfe je Gegner; im Stand von Lauf 346 enthalten).

Bekannt: Klosterschüler und Schmiedelehrling tragen bis zum Streitkolbenmodell (458.3) einen Kampfstab (Vorentscheid 870e); Siegquoten unverändert, weil Stab und Streitkolben beide zur Gruppe „Stumpfe Waffen“ zählen und der Kampf nur nach der Gruppe rechnet (nachgesehen in `BrsHeld.kampfblatt`). Jeder Held hat Mana und einen Mana-Balken, auch ohne Zauber (870e). Lücke: Verstand zeigt beim Antippen nur die Zahl; „ab Verstand 6 Schwächen und Stärken der Gegner vorher sehen“ (870d) ist gerechnet, aber noch nirgends im Spiel zu sehen (Ziel-Tipp, Bestiarium); Handwerk und Alchemie fehlen ebenso.

## A · Hauptmenü und neues Spiel

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.1 | Tom | 870.8 | nach dem Installieren das Spiel öffnen, Hauptmenü; dann „Spielstände“ | kein „Weiter“ mit dem alten Helden; in der Liste dein Platz mit Name und „Aus der alten Regelfassung, nicht mehr spielbar“, nur „Löschen“, kein Bild, Antippen lädt nicht | „Weiter“ lädt den alten Helden, Absturz, Held mit falschem Volk |
| 276.2 | Tom | 870.4 | Hauptmenü → „Neues Spiel“; Mensch, Herkunft Wanderer, Punkte verteilen, „ABENTEUER BEGINNEN ›“ | das Spiel beginnt in der Schenke; der Held trägt ein Kurzschwert und Lederrüstung | Absturz, Held ohne Waffe |

## B · Schenke und Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.3 | Tom | 870.4 | Tasche → Reiter „Held“ | oben Name, „Mensch · Wanderer“, „Heldenstufe 1“ und Gold 20; Balken TP, Mana, EP; Zeile Schutzwert, Schaden, Kritisch in Prozent; sechs Grundwerte mit den Zahlen aus der Erschaffung; Fertigkeiten | Klasse, Rüstungsklasse, Übungsbonus, Würfel wie „1W8+1“, „ZP“ |
| 276.4 | Tom | 870.4 | im Reiter „Held“ auf einen Grundwert tippen, dann auf einen zweiten | oben „Wert“ mit der Zahl, darunter je Zeile, was der Grundwert bringt (Verstand nur die Zahl, siehe Bekannt) | kein Satz bei Kraft, Gewandtheit, Zähigkeit, Wille, Wahrnehmung; Satz mit SRD-Wörtern (Stärke, Konstitution) |
| 276.5 | Tom | 870.4 | Tasche → Heiltrank benutzen (am besten nach dem Kampf in C, wenn Leben fehlt) | Leben steigt um 14, höchstens bis voll; in der Tasche anfangs 2 Heiltränke | Wurf oder Würfelzahl im Text |
| 276.6 | Tom | 870.4 | Thessas Kramladen: Preise einer Waffe ansehen, dann Vergleich mit der getragenen | Preise wie in Build 275 ungefähr; Vergleich ohne Rüstungsklasse | Absturz, „Deine Klasse kann das nicht tragen“ |

## C · Wald

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.7 | Jerry | 870.5 | Reiter „Test“ → Teleport „Wald“, zum Wolf gehen, Kampf; dabei die Würfelergebnisse über den Figuren lesen | über dem Getroffenen nur Ergebnis und Trefferchance; Knopf „Können“; keine Würfel, keine Rüstungsklasse | „gegen RK“, „RW … gegen SG“, „(Vorteil)“, „ZP“ |
| 276.8 | Jerry | 870.5 | im Wolfskampf „Können“ öffnen | nur, was die Fertigkeiten freigeben (Wanderer: mindestens „Kraft schöpfen“) | Klassenfähigkeiten wie „Zweiter Atem“ |
| 276.9 | Jerry | 870.5 | Wolfskampf gewinnen | Erfahrung nach dem BRS in der Lohnzeile; im Reiter „Held“ wächst der Erfahrungsbalken | „Attributspunkte“, alte EP-Zahlen |
| 276.10 | Jerry | 864 | im Wolfskampf auf den Beginn deines Zuges achten | der Wolf setzt nach seinem Biss ein, zwei Schritte ab und bleibt dort; zurück in die Reihe nur im eigenen Zug, das darf in deinen Zug hinein auslaufen | Wölfe springen auf einen Schlag auf ihre Ausgangsplätze |
| 276.11 | Tom | 870.4 | am Lagerfeuer im Wald rasten | Wahl „Kurze Erholung · 2 Stunden“ und „Langes Ausruhen · 9 Stunden“ mit Satz darunter; nach Langem Ausruhen Leben und Mana voll | „Kurze Rast“, „Lange Rast“, 1 oder 8 Stunden |

## D · Probekämpfe der Herkünfte

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.12 | Jerry | 870.5, 705 | Reiter „Test“ → MARS-Probekampf: „Gegner“ antippen bis „Wolfsrudel“, dann unter „Starten als:“ nacheinander Wachsoldat, Zauberlehrling, Herumtreiber, Klosterschüler; im Kampf „Held selbst“ antippen bis „Held Auto“ | jeder Kampf läuft bis zum Ende; Zauberlehrling: Kopf „Mana a/b“, wirkt Zauber; Wachsoldat mit Schild; Klosterschüler mit Kampfstab | Kampf hängt, Zauberlehrling ohne Mana |
| 276.13 | Jerry | 870.5 | Reiter „Test“ → MARS-Probekampf: „Gegner“ antippen bis „Grak“, unter „Starten als:“ Wachsoldat | Grak ruft höchstens einen Goblin | Grak ruft Goblin und Späher |

## Ergebnis

Chef 11.11., 13:44 an Sokrates: „getestet und freigegeben“; 276.9 auf Nachfrage 13:50: „hat auch gepasst. Ich habe Erfahrungspunkte gekriegt.“

- 276.1 ✓
- 276.2 ✓ (Frage: Langdruck in der Erschaffung gibt keinen Erklärtext, etwa zu Fertigkeiten)
- 276.3 ✓
- 276.4 ✓
- 276.5 ✗ Heiltrank gab 11 TP zurück statt 14 („passt noch nicht ganz“); Würfeltext 944
- 276.6 ✓
- 276.7 ✓
- 276.8 ✓
- 276.9 ✓
- 276.10 ✓
- 276.11 ✓
- 276.12 ✓ (Funde nebenbei: 945 Auto nicht abschaltbar, 946 Ansage unter Zugleiste, 947 Söldner-Klon, 948 Dolch)
- 276.13 ✓ (Fund nebenbei: Text „greift an, schlägt daneben“ beim perfekten Ring gegen Grak passt nicht zur Bewegung)
