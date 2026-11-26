# 2029 Bildherkunft der Paketbilder (Auftrag 26.11., 08:59)

Geprüft 26.11.2026, 16:24–16:34 (Anna, Figur). Pakete frisch geladen von `files.makehumancommunity.org/asset_packs/<paket>/<paket>_cc0.zip` (HTTP 200: hats02 24.018.546 Byte, hair01 227.775.853, bodyparts05 6.616.507; Dateien im Zip vom 14.04.2024). Je Bild: ganzes Bild und vier Ecken (je 30 % der kürzeren Seite) angesehen, Metadaten gelesen (PIL `info`, EXIF).

| Bild (Paket, Stück im Spiel) | Größe | Marke / Wasserzeichen / Fremd-URL | Metadaten | Urteil |
|---|---|---|---|---|
| `casco.jpg` (hats02, `Helm_Templer`, `Helm_Templer_B`) | 1600×1100 | **ja:** unten links „http://gallery.world/wallpaper/100982.html“ | JFIF, 72 dpi, kein EXIF | **unsicher, raus** (eigenes Bild) |
| `diffuse_black.png` (hair01 `culturalibre_hair_01`, `Haar_MH01`) | 2048×2048 | nein | nur dpi | frei (CC0 laut Paketseite) |
| `BeardViking.png` (bodyparts05 `rehmanpolanski_beard_viking`, `Bart_Wikinger`) | 1024×1024 | nein | „Creation Time: zo 19 apr 2020“ | frei (CC0 laut Paketseite) |
| `braid01_diffuse_black.png` (hair01 `elvs_double_mh_braid`, Zopf `zopf_zwergin.glb`, main 431) | 2048×2048 | **ja:** oben links CC0-Zeichen (Kreis mit 0) und „www.makehuman.org“, auch im Spielbild `zopf_zwergin__zopf.jpg` (Ausschnitt `2029-zopf-marke.webp`) | nur dpi | **Ausnahme** (Sokrates 26.11., 16:51: A, so lassen) |

## casco.jpg: Herkunft nicht belegbar

- `https://gallery.world/wallpaper/100982.html` (26.11., 16:25): HTTP 200, 114 Byte, nur Weiterleitung auf `/lander` (geparkte Domain), Startseite gleich. Keine Lizenz lesbar.
- Internet Archive (`archive.org/wayback/available?url=gallery.world/wallpaper/100982.html`, 26.11., 16:25): `"archived_snapshots": {}`, keine Sicherung der Seite (Startseite nur 17.05.2026). CDX-Abfrage: Verbindung abgebrochen.
- Websuche „"gallery.world" wallpaper 100982 metal scratched texture“ (26.11., 16:25): kein Treffer zu gallery.world oder 100982, nur fremde Tapetenseiten.
- Eine Bildrückwärtssuche (Google Lens, TinEye) ist aus der Sitzung nicht möglich (braucht eine öffentliche Bild-URL oder Anmeldung); das ändert nichts: die Marke zeigt eine Tapetenseite als Quelle, die CC0 der Paketseite deckt dieses Bild nicht.
- Kopf der .mhclo: „author Unknown, license AGPL3“ (MakeClothes-Vorgabe), `.mhmat` ohne Bildquelle.

Folge (Querprofil Fremde Inhalte, unsicher = kein Einbau): Helm und Schirm B tragen ein eigenes Bild aus `tools/blender348/v3/kopfteil_mh.py` (`eigen_bild`, Schalter `HELMBILD`, Vorgabe eigen). Netz bleibt CC0 aus dem Paket.

## Eigenes Helmbild

1024×704 (wie vorher), Eisengrau 0,34 mit kaltem Stich, Rand dunkler (0,62; Abstand zur Kante des offenen Netzes, bis 0,8 cm ganz, bis 3 cm gleitend), Nasenschutz vorn in der Mitte dunkler (0,68), Rauschen grob ±5 % und Korn ±2,5 % aus festem Startwert 2029; kein Glanz (Rauheit 1, Metall 0). Netz und Bildkoordinaten des Helms gleich wie 74fb13347 (Abweichung 0,0 an Ecken und Bildkoordinaten).

Schirm B: das alte Fenster (176,240 und 176,168, 732×258) lag im eigenen Bild über dem Netz des Helms mitsamt dunklem Rand und Nasenschutz; der Schirm zeigte dort Stücke davon. Darum liegt sein Fenster jetzt quer im freien Streifen links (ab x 40, gleiche Bilddichte 1571/1584 px/m, Bogen nach unten), Streifen zum unteren Schirmrand hin ebenso dunkel wie der Helmrand. Gleiches Verfahren wie 74fb13347 (eigene Bildkoordinaten aus ruhiger Stelle), andere Stelle.

## Zopf: Ausnahme (Sokrates 26.11., 16:51, 2029-Ü32: A)

Die Marke ist das CC0-Zeichen von MakeHuman selbst, keine fremde Seite; sie liegt außerhalb jeder Bildkoordinate des Zopfnetzes (0 von 8.491 Bildkoordinaten im Feld der Marke), ist im Spiel also nicht sichtbar. Liegt aber im Spielbild auf main. Entscheid Sokrates 16:51: A, so lassen (CC0 verlangt nichts, im Spiel unsichtbar); im Test als geprüfte Ausnahme.

## Prüfung

`tools/kopfteil_marke_2029_test.py`: Fingerabdruck (dHash 256 Bit) jedes Paketbilds, verglichen mit jedem Bild in `godot/figuren` und in den .glb dort. Gegenbeweis: altes Helmbild 08510eeb4 zu casco.jpg Abstand 8 (FALSCH), eigenes Bild 134; Spielbilder zum eigenen Paketbild 3 bis 11, zu fremden ≥ 104.
