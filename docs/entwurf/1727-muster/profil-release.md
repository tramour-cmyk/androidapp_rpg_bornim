# 1727, Profil Release (Gesamtbild 3.2; Fassung 2, Perikles 21.11., 20:19, nach Gegenprüfung 20:18)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`. **Nur Anschauung, nicht in Betrieb.** Vorschlag Sokrates (G:351), nicht entschieden.

## Votum: erst mit 622 laden

Bis 622 (Godot-AAB für Play) gibt es keinen Release-Weg (`LISTE-RELEASE-NEUSTART.md` Schritt 1); bis dahin trägt die Zeile im Profil Disponent („Release nur auf sein Wort; vor 622 über Sokrates fragen, ob 622 vorgezogen wird“). Das Profil kommt als Auftrag mit 622 (Abhängigkeit in die Zeile 622). **Stärkstes Gegenargument:** ein später kommendes Profil wird vergessen. **Dagegen:** die Abhängigkeit an 622 hält es fest; den Vorschlagsfall zählt das Werkzeug ohne Profil (Frage 1).

Lädt (ab 622): der Disponent dazu, wenn das Chefwort „Release“ bei ihm ankommt oder das Werkzeug den Vorschlagsfall meldet. Den Bau trägt Profil Technik (F12, VA 21.11., 15:15).

Quellen: `LISTE-RELEASE-NEUSTART.md` „Release vorschlagen“ (65.6) und „Release“ (0–3); Gesamtbild 4.4 (Diogenes „`main` prüfen vor Release“ → Tester; Spike „Release auf Zuruf“), G:873 (Testaufträge schreibt der Arbeitsplaner), 3.3 F2 Nr. 5, 7.

## Text (ab 622)

```markdown
**Release.** Nur auf das Wort „Release“ des Chefs, belegt in der Vorgangsdatei oder im Archiv.

**Vorschlagen:** meldet das Werkzeug fünf getestete Themen unter „## Unveröffentlicht“ in `CHANGELOG.md` oder sieben Tage seit dem letzten Release, bittest du Sokrates einmal um die Rückfrage „Zeit für ein Release?“ als Chefsache. Nicht wiederholen, bis ein Release war oder der Chef neu fragen lässt.

**Auf „Release“:** Vorgang „Release“ als Zeile an den Arbeitsplaner (er schreibt zuerst den Testauftrag für den Tester über `main`, nach dessen Ergebnis den Release-Auftrag für Profil Technik). Ohne Ergebnis des Testers kein Release. Befunde, die es aufhalten, legst du als Vorgang an.
```

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Profil Release** (ab 622) | Chefwort „Release“; Vorschlagsfall vom Werkzeug | `CHANGELOG.md`, Ergebnis des Testers | Release gebaut (Profil Technik), Link an den Chef | Rückfrage über Sokrates als Chefsache | Arbeitsplaner → Tester → Fachkraft Technik → Chef | unklar: Haken D schreibt Chefworte an den Arbeitsplaner, nicht an den Disponenten (3.3 F2 Nr. 7); wie L-U15 |

## Offen, Fragen

1. **Vorschlagsfall zählen:** `tagesbericht.py` zeigt „getestete Themen unter Unveröffentlicht: n, letztes Release vor x Tagen“; ab Schwelle Zeile in `lauf.py`.
2. **Weg des Chefworts „Release“:** gleich lösen wie L-U15 („gut“ aus fremder Sitzung): Chefwort-Zeile an den Disponenten. Chefsache, ändert 3.3 bzw. Profil Technik F12.
3. **Prüfart des Testers für ein Release** steht im Profil Tester nicht (Frage an Sokrates).

## Gegenprüfung 20:18, mein Wort

18 Disponent schreibt Aufträge, Befunde an den Arbeitsplaner: **stimmt**, Vorgang an den Arbeitsplaner, Befunde legt der Disponent an · 19 Auslöser kommt nicht an; Wortlaut 65.6: **stimmt**, Frage 2, „Themen“ und „Rückfrage als Chefsache“ übernommen · 20 Zeilen im Disponenten fehlten: **stimmt**, dort ergänzt.
