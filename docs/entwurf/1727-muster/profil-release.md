# 1727, Profil Release (Gesamtbild 3.2; Entwurf Perikles 21.11., 20:15, ungeprüft)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`. **Nur Anschauung, nicht in Betrieb.** Vorschlag Sokrates (G:351), nicht entschieden.

Lädt: der Disponent dazu, wenn der Chef „Release“ sagt oder der Vorschlagsfall eintritt. Den Bau trägt Profil Technik (F12, entschieden 21.11., 15:15: „Release nur auf Zuruf des Chefs“).

Quellen: `LISTE-RELEASE-NEUSTART.md` „Release vorschlagen“ (65.6) und „Release“ (Schritte 0–3; 622: bis zum Godot-AAB kein Release-Weg); `CLAUDE.md` „Release nur auf Zuruf“; Gesamtbild 4.4 Zeile Spike „Release auf Zuruf“, Zeile Diogenes „`main` prüfen vor Release“ → Tester (Komplexabnahme); Profil Technik F12.

## Text

```markdown
**Release.** Ein Release gibt es nur auf das Wort „Release“ des Chefs, belegt in der Vorgangsdatei oder im Archiv.

**Vorschlagen:** stehen unter „## Unveröffentlicht“ in `CHANGELOG.md` fünf getestete Vorgänge oder ist das letzte Release sieben Tage alt, fragst du einmal über Sokrates „Zeit für ein Release?“. Nicht wiederholen, bis ein Release war oder der Chef neu fragen lässt.

**Auf „Release“:** zuerst ein Auftrag an den Tester (Komplexabnahme über `main`); ohne sein Ergebnis kein Release. Befunde, die das Release aufhalten, gehen als Vorgang an den Arbeitsplaner. Dann Auftrag an eine Fachkraft mit Profil Technik: Release nach `docs/LISTE-RELEASE-NEUSTART.md`. Gibt es keinen Release-Weg (vor 622), fragst du über Sokrates, ob 622 vorgezogen wird.

Ende: Link des Release an den Chef, lautlos.
```

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Profil Release** | Chefwort „Release“ (Haken D oder Sokrates); Vorschlagsfall (fünf Vorgänge oder sieben Tage) | `CHANGELOG.md`, Ergebnis des Testers | Release gebaut (Profil Technik), Link | Frage über Sokrates; Link an den Chef | Tester → Fachkraft Technik → Chef | offen: wer den Vorschlagsfall zählt (heute niemand mechanisch); kein Release-Weg vor 622 |

## Offen, Fragen

1. **Wer zählt den Vorschlagsfall?** Heute steht 65.6 nur als Regel; niemand zählt. Vorschlag: `tagesbericht.py` zeigt „getestet unter Unveröffentlicht: n, letztes Release vor x Tagen“; ab Schwelle gibt `lauf.py` die Zeile „Release vorschlagen“ aus.
2. **Tester statt Diogenes:** Schritt 0 heute „Prüfung zuerst“ durch Diogenes; 4.4 legt „`main` prüfen vor Release“ auf den Tester. Übernommen; Prüfart des Testers für ein Release steht im Profil Tester nicht (Frage an Sokrates).

## Votum

**Nicht als eigenes Profil laden, bis 622 gebaut ist.** Bis dahin gibt es keinen Release-Weg (Liste Schritt 1), der Text wäre totes Gewicht. Bis 622 reichen zwei Zeilen im Profil Disponent: „Release nur auf Wort des Chefs; vor 622 über Sokrates fragen, ob 622 vorgezogen wird.“ **Stärkstes Gegenargument:** wer den Vorschlagsfall nicht zählt, vergisst ihn, und ein Profil, das erst später kommt, wird vergessen. **Dagegen:** die Zeile im Tagesbericht (Frage 1) zählt ohne Profil; das Profil kommt als Auftrag mit 622 (Abhängigkeit in die Zeile 622 eintragen).
