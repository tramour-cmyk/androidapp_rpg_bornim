# Morgenbericht 19.10.

Oct 19, 2026 (Sokrates, 167.6)

## Auf einen Blick

Gestern kostete 152 $, davon 53 % fürs Spiel (Tom, Jerry, Homer), der beste Tag seit Zählbeginn; Ford allein 34 $ (23 %).

| Rolle | Gestern 18.10. | Seit 17.10. (Max-Wechsel) |
| --- | --- | --- |
| Tom | 43,69 $ (10 Sitzungen) | 94,86 $ |
| Ford | 34,48 $ (12) | 67,60 $ |
| Jerry | 23,69 $ (17) | 27,65 $ |
| Sokrates | 16,71 $ (3) | 32,32 $ |
| Perikles | 14,72 $ (14) | 33,04 $ |
| Homer | 14,04 $ (10) | 23,99 $ |
| Diogenes | 5,03 $ (6) | 10,15 $ |
| **Gesamt** | **152,35 $, Spiel 53 %** | **290,53 $, Spiel 50 %** (17.10.: 40 %) |

Vorräte: 60 Zeilen offen, davon 10 Muss; wartet auf dich: 2 Builds (unten). Quelle: `tools/kosten.py` aus `list_sessions` (331 Sitzungen, 5 gestern ohne Kostenangabe), `tools/startbar.py --stand`; Niederlassung nicht enthalten.

## Wartet auf dich

Zwei Builds warten auf deinen Test; dahinter hängt fast alle fertige Arbeit von Tom und Jerry. Zu entscheiden ist nichts offen.

| Folge | Version | Build | Was | Team | Dahinter wartet |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.1.869 | 31 | Kampf schneller (172), MARS-Absichten gegen die Aufstellung (72.10a.8), Prüfpunkt Gefühl (130.2) | Jerry | 72.10a.9, 72.10a.11 (gebaut, Sammelbuild) |
| 2 | 0.1.870 | 32 | Tempelszene neu (68), Mondlicht (27) | Tom | D29.3 Dorfhund, Kleinleben (gebaut, Sammelbuild) |

Testbögen: [Chefsache, Anzusehen](https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs/chefsache).

## Auffälliges

Von 02:54 bis 07:13 lief keine Arbeitssitzung, obwohl Jerry, Homer und Diogenes Startbares hatten; du hast heute früh 190 entschieden (alle sieben Punkte), Perikles setzt um.

| Ursache | Wirkung | Abhilfe (190) |
| --- | --- | --- |
| `startbar.py` hält „gebaut“ für startbar; `lauf.py` nimmt nur die oberste Kür | Jerrys D29.1, 27o, D3, 86.11, 141 nie geprüft | 190.1, 190.2 |
| Homer laut `lauf.py` nur Muss | Texte 72.10a.8T, .9T, .11T, auf die Jerry wartet, nie gestartet | 190.3 |
| Zeile 186.3 „wartet auf Chef“ sperrte die ganze Rolle | Diogenes 71 Teil C nicht gestartet (behoben 07:0x) | 190.4 |
| Wochenziel schließt 72u aus, Vorrat nicht | Ford wich von `lauf.py` ab, Jerrys Nachfolger 72u.1 nicht gestartet | 190.5 |
| Übernahme gesperrt, solange die Niederlassung ruht | Tom ohne Arbeit, Jerrys Zeilen lagen | 190.6 |
| „Nachfolger:“ der Übergabe liest kein Werkzeug | drei genannte Nachfolger (Jerry, Homer, Diogenes) nie gestartet | 190.7 |
| Uhr aus 03–06 Uhr (99h) | kein Lauf, der es hätte merken können | 190.6 |

Dazu: der Wecker für diesen Bericht (06:15) lief ins Leere, seine Sitzung war beim Neustart archiviert worden; Bericht nachgeholt (167.6).

## Gestern und heute je Rolle

Gestern (18.10., 07 bis 19.10., 07 Uhr) gingen Builds 27 bis 30 nach deinem Test auf `main` und Release 0.1.867 raus; heute hängt das meiste an deinem Test von 31 und 32.

| Rolle | Gestern erledigt oder gebaut | Heute als Nächstes |
| --- | --- | --- |
| Tom | 180 und 176a/175 auf `main` (Builds 27, 30); 68 Tempelszene und 27 Mondlicht als Build 32; D29.3/D29.4 Kleinleben, Dorfhund (Zweig) | wartet auf Test 32; dann Sammelbuild mit D29.3 |
| Jerry | Builds 28, 29 freigegeben (181–183, 174); 172 und 72.10a.8 als Build 31; 72.10a.9, .11 gebaut; Vorrat abgeglichen | Sammelbuild 31 + .9 + .11 (190); dann D29.1, 27o |
| Homer | 112 Tempelvorlage gemessen (`tools/bildmass.py`), 186.1 Prüfbogen, 146, 84.5 | Texte 72.10a.8T, .9T, .11T für Jerry (nach 190.3 Muss) |
| Diogenes | 186.2 Auswertung Prüfbogen; 71 Teil A (Lauf 30, Befunde D29) | 71 Teil C (Oberflächen) |
| Perikles | 167 Werkzeuge statt Sitzungen (`lauf.py`), 185 Ford-Grenze, 187 | 190 umsetzen (`lauf.py`, `startbar.py`) |
| Sokrates | 185, 156.1, 68 vorbereitet; Vorräte abgeglichen (189) | Wiedervorlage 167.6 am 26.10. |
