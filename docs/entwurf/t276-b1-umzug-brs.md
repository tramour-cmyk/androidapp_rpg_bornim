# Tom und Jerry · Build 276 · B1 · Umzug BRS: Held und Kampf · PR folgt
Ganzes Spiel · Tom (870.4), Jerry (870.5, 705) · Entwurf 11.11., 03:33 · APK folgt · Geprüft an: `claude/tom-870-4-held` (Stand folgt)

Ein Weg: neues Spiel mit Wanderer (A), Schenke und Dorf mit Heldenreiter und Rast (B), Wald mit Wolfskampf (C), Probekämpfe der anderen Herkünfte im Reiter „Test“ (D); über Build 275 installieren. Den Reiter „Test“ gibt es nur im Testmodus: im Hauptmenü siebenmal aufs Firmenzeichen tippen. Was nicht passt, reicht als Nummer (z. B. 276.4) mit einem Wort.

Erster Build ganz nach dem BRS: Held und Kampf rechnen nur noch nach unserem System, ohne SRD-Werte. Alte Spielstände laden noch nicht (kommt mit B2, 870.8): bitte ein neues Spiel.

Verglichen (alt gegen neu): Heldenreiter mit dem Reiter von Build 275 (Grundwerte, Balken, Kampfwerte); Rastwahl am Lagerfeuer mit Build 275.

Im Bau geprüft: `brs_held_870`, `brs_held_834`, `brs_470`, `spielstand_test`, `testmenue_470`, `testmenue_555`, `handlungen_870`, `mars_regeln`, `faehigkeiten_534`, `brs_kampf_478`, `sim444_870` (Messung je Herkunft gegen Rudel, Krogg, Grimmzahn, Grak), Zahlen der Welt nur aus `werte.json` (870e).

Bekannt: Klosterschüler zeigt seinen Streitkolben nicht (kein Modell, 458.3); Lösung beim Vorentscheid 870e.

## A · Neues Spiel

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.1 | Tom | 870.4 | Hauptmenü → „Neues Spiel“; Mensch, Herkunft Wanderer, Punkte verteilen, „ABENTEUER BEGINNEN ›“ | das Spiel beginnt in der Schenke; der Held trägt ein Kurzschwert und Lederrüstung | Absturz, Held ohne Waffe |

## B · Schenke und Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.2 | Tom | 870.4 | Tasche → Reiter „Held“ | oben Name, „Mensch · Wanderer“, „Heldenstufe 1“ und Gold 20; Balken Leben, Mana, Erfahrung; Zeile Schutzwert, Schaden, Kritisch in Prozent; sechs Grundwerte mit den Zahlen aus der Erschaffung; Fertigkeiten | Klasse, Rüstungsklasse, Übungsbonus, Würfel wie „1W8+1“, „ZP“ |
| 276.3 | Tom | 870.4 | im Reiter „Held“ auf einen Grundwert tippen, dann auf einen zweiten | je Grundwert ein kurzer Satz, was er bringt | kein Satz, Satz mit SRD-Wörtern (Stärke, Konstitution) |
| 276.4 | Tom | 870.4 | Tasche → Heiltrank benutzen (am besten nach dem Kampf in C, wenn Leben fehlt) | Leben steigt um 14; in der Tasche anfangs 2 Heiltränke | Wurf oder Würfelzahl im Text |
| 276.5 | Tom | 870.4 | Thessas Kramladen: Preise einer Waffe ansehen, dann Vergleich mit der getragenen | Preise wie in Build 275 ungefähr; Vergleich ohne Rüstungsklasse | Absturz, „Deine Klasse kann das nicht tragen“ |

## C · Wald

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.6 | Jerry | 870.5 | Reiter „Test“ → Teleport „Wald“, zum Wolf gehen, Kampf | über dem Getroffenen nur Ergebnis und Trefferchance; Kopf „Mana a/b“; Knopf „Können“; keine Würfel, keine Rüstungsklasse | „gegen RK“, „RW … gegen SG“, „(Vorteil)“, „ZP“ |
| 276.7 | Jerry | 870.5 | im Wolfskampf „Können“ öffnen | nur, was die Fertigkeiten freigeben (Wanderer: mindestens „Kraft schöpfen“) | Klassenfähigkeiten wie „Zweiter Atem“ |
| 276.8 | Jerry | 870.5 | Wolfskampf gewinnen | Erfahrung nach dem BRS in der Lohnzeile; im Reiter „Held“ wächst der Erfahrungsbalken | „Attributspunkte“, alte EP-Zahlen |
| 276.9 | Tom | 870.4 | am Lagerfeuer im Wald rasten | Wahl „Kurze Erholung · 2 Stunden“ und „Langes Ausruhen · 9 Stunden“ mit Satz darunter; nach Langem Ausruhen Leben und Mana voll | „Kurze Rast“, „Lange Rast“, 1 oder 8 Stunden |

## D · Probekämpfe der Herkünfte

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 276.10 | Jerry | 870.5, 705 | Reiter „Test“ → MARS-Probekampf, Gegner Wolfsrudel, „Starten als“ nacheinander Wachsoldat, Zauberlehrling, Herumtreiber, Klosterschüler; jeweils „Automatik“ | jeder Kampf läuft bis zum Ende; Zauberlehrling wirkt Zauber und hat Mana; Wachsoldat mit Schild | Kampf hängt, Zauberlehrling ohne Mana |
| 276.11 | Jerry | 870.5 | MARS-Probekampf gegen Grak als Wachsoldat | Grak ruft höchstens einen Goblin | Grak ruft Goblin und Späher |
