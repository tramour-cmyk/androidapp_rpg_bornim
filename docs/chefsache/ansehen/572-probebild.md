# 572 · Film der Effektprobe neu starten · Team Jerry · 04.11., 23:1x

Kurz: Lauf 2 hat den Film in Compatibility fehlerfrei gerendert (alle Abschnitte im Protokoll, Lauf 41912439909), aber das Umwandeln in MP4 fehlte: im Filmschritt war ffmpeg nicht geholt (nur der Probebild-Schritt holte es, und der ist beim Film aus). Behoben (f9c541655). Das Probebild ist dasselbe wie um 21:44 (Lauf 41900840979); der Filmwächter (511) braucht nach jedem Filmlauf ein neues „passt“.

Antwort: „572 Probebild passt“, dann läuft der Film noch einmal (gut 40 Minuten bis zum Film).

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41912439909
