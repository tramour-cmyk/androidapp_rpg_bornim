# Tom und Jerry · Build 271 · Godot 0.348.313 · Dorf, Menüs, Kampf · [PR #190](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/190)
Ganzes Spiel · Tom (585, 630, 586, 591, 416.8, 356.2, 699, 664), Jerry (565, 563, 703, 296.3) · 09.11., 00:14 · [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42527060528/artifacts/13638067648) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42527060528

Ein Weg: Hauptmenü (A), Erschaffung (B), Dorf (C), Laden und Schenke (D), Tiefer Flüsterwald (E), Probekämpfe im Reiter „Test“ (F); über Build 270 installieren. Was nicht passt, reicht als Nummer (z. B. 271.4) mit einem Wort.

Verglichen: Schirme 585, 586, 630 in den Bildproben des 08.11. (vom Chef abgenommen, 585 und 586 um 21:55, 630 um 18:14); sonst keine Schirme neu. Im Bau geprüft: `titel_585`, `knopf_630`, `laden_503`, `wende_4168` (Fall „zugewandt“ berichtigt, Befund Jerry 08.11., 22:37) je 0 Fehler; `zustaende_563` in Ruhe 0; `ausweichen_546` meldet 1 (unten bei F).

## A · Hauptmenü

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 271.1 | Tom | 585 | Hauptmenü ansehen; dann „Über das Spiel“, „Lizenzen der Engine“ aufklappen und ans Ende rollen | Titel in zwei Zeilen: oben „CHRONIKEN“, darunter „VON BORNIM“; aufgeklappt zeigt der Winkel nach unten, am Ende der Texte klappt die Zeile „Lizenzen der Engine“ mit Winkel nach oben wieder zu | oben „CHRONIKEN VON“, darunter „BORNIM“; unten nichts zum Zuklappen |

## B · Erschaffung

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 271.2 | Tom | 630 | neues Spiel bis zum Punktekauf, dann weiter bis zum Knopf unten rechts | jeder Name im Punktekauf ganz (Geschicklichkeit, Konstitution); „ABENTEUER BEGINNEN ›“ in einer Zeile, Held im Bild | „Geschickli…“; Knopf bricht um |

## C · Dorf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 271.3 | Tom | 591 | auf Hühner und Kaninchen zugehen | Huhn gackert laut und schlägt hörbar dreimal mit den Flügeln; Kaninchen huscht hörbar weg | stumm oder kaum zu hören |
| 271.4 | Tom | 416.8 | auf einen Dorfbewohner zugehen, 2–3 Kacheln vor ihm stehen bleiben, 10 s warten | er wendet sich mit kleinen Schritten zum Helden und schaut ihn an; nach etwa 10 s geht er wieder seiner Wege | dreht auf der Stelle wie eine Plastikfigur; beachtet den Helden nicht |
| 271.5 | Tom | 356.2 | Brett im Dorf: Aufträge von Thessa (Wolfsfelle) und Borin (Keilerhauer) lesen | Thessa will drei Wolfsfelle, Lohn auch „Thessas Pelzumhang“; Borins Lohn auch „Borins Hauerdolch“ | fünf Felle; nur Gold als Lohn |

## D · Laden und Schenke

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 271.6 | Tom | 699 | im Laden mit genau einem gewöhnlichen Gegenstand „Alle gewöhnlichen verkaufen“ | die Frage im Fenster sagt „1 GEGENSTAND:“ | „1 GEGENSTÄNDE:“ |
| 271.7 | Tom | 586 | in der Schenke rasten; dann in der Tasche einen Gegenstand wegwerfen wollen | Titel des Fensters so groß wie die Titel der Schirme; beim Rasten ein Zeichen links neben dem Titel | Titel klein wie der übrige Text |

## E · Tiefer Flüsterwald

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 271.8 | Tom | 664 | zum Haus des alten Kael und zur Hütte der Kräuterhexe gehen | beide Häuser ganz; Tür mittig; die Hütte größer als bisher, mit Fenstern und Kräuterbündeln | halbes Haus; Wand fehlt |

## F · Probekämpfe (Reiter „Test“)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 271.9 | Jerry | 565 | Wölfe mit Gefährten; auf den Gruppenkasten unten achten | der Kasten dessen, der am Zug ist, hat „▶“, den Namen in Gold und einen helleren Goldrahmen als die anderen | alle Kästen gleich |
| 271.10 | Jerry | 563 | Wölfe als Kämpfer angreifen, bis ein kritischer Treffer einen Wolf bluten lässt („Blut 3“) | „Blut“ über dem Wolf im Stil der Ansagen über den Köpfen: schwarzer Grund, Rand und Schrift hellrot; liegt nicht über Name oder Lebensleiste | grobes Schild über Name und Lebensleiste |
| 271.11 | Jerry | 703 | Ratten, mehrmals angreifen, bis eine ausweicht | sie bleibt am neuen Platz stehen, dreht sich nur zum Helden und geht erst mit ihrem eigenen Zug zurück | tappelt gleich zurück |
| 271.12 | Jerry | 296.3 | Wölfe, Held mit Zauber (Feuerpfeil), einen Wolf damit töten | er jault sofort mit dem Treffer auf | 3 s später oder stumm |

Bekannt: in der Messung im Bau wich einer von drei Wölfen aus und ging danach zurück an seinen alten Platz (`ausweichen_546`, Jerry sieht nach); bei 271.11 darauf achten, ob eine Ratte so zurückgeht. Umhang des Kämpfers (656) ist nicht drin, der Film dazu kommt gesondert; Wege der Gegner noch eckig (682, nicht drin).
