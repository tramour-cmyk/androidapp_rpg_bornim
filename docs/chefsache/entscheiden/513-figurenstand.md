# 513 · Ein Figurenstand für alle Zweige, und Schild, Robe, Umhang jetzt beheben?
Sokrates · 03.11., 15:53 · E Figuren, Abläufe · berührt Tom, Spike, Jerry

Kurz: Du hast im Drehteller (499) Mängel gesehen, die schon behoben oder schon gemeldet waren, weil der Zweig den abgenommenen Stand nicht hatte.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/chefsache/ansehen/499-drehteller.md (Git, Zweige 15:52)

**Frage:** Gilt ab sofort ein gemeinsamer Figurenstand, und werden Schild und Robe jetzt behoben, trotz Einfrieren (488)?

**Votum:** „513 A“.

**Sachverhalt:** Der Drehteller-Zweig (Spike, `claude/spike-499-drehteller`) baut auf 417 (Waffe in der Hand), aber ohne deinen abgenommenen Umhang- und Robenstand 463 (Commit e3789d130, „463 passt“ 06:50). Der steckt in fünf anderen Zweigen und im Testbuild 245, aber nicht im Drehteller. Darum sahst du dort einen älteren Umhang und eine ältere Robe. Ob der Stand 463 die Knie des Magiers heilt, ist nicht geprüft. Der abstehende Schild (Kämpfer, Kleriker) steckt dagegen in allen Zweigen: du hast ihn am 02.11. (461.1), 03.11. (417) und jetzt (499) gemeldet; seit 488 (06:44) steht er auf „nach dem Durchspielen“, ebenso die Mängel an Umhang und Robe (463.1).

- **A (Votum):** (1) jetzt: ein Zweig „Figurenstand“ mit allem, was du an Figuren abgenommen hast (417, 463, 499-Maßstab); jeder Figurenzweig baut darauf; Perikles lässt `probelauf.py` keinen Bild- oder Filmlauf zu, dessen Zweig einen abgenommenen Figurencommit nicht enthält. (2) jetzt, je höchstens ein Lauf mit Messung (Abstand Schild–Rücken, Durchdringung Knie–Robe nach `pruef_kampf.py`): Schild liegt unten am Rücken an; Knie des Magiers nicht mehr durch die Robe. (3) Umhang bleibt eingefroren (463.1), weil er 20 Läufe gekostet hat; erst nach dem Durchspielen.
- **B:** wie A, dazu den Umhang jetzt.
- **C:** nur (1); Schild und Robe nach dem Durchspielen (488 wie beschlossen).

**Berührt:** 499, 417, 463, 463.1, 488 (Ausnahme für Schild und Robe), `probelauf.py` (Perikles), alle Figurenzweige.

**Auswertung:** Stärkstes Gegenargument zu A: 488 friert Feinarbeit am Aussehen ein, damit Kapitel 1 durchspielbar wird; jede Ausnahme frisst Läufe. **Entkräftet:** Der Schild ist das Erste, was jeder Spieler in der Erschaffung sieht, und du hast ihn jetzt dreimal gemeldet; zwei Punkte mit je einem Lauf und Messung kosten weniger als jede weitere Vorlage, in der du ihn wieder findest. Der Umhang bleibt draußen, weil dort ein Lauf nicht reicht. Gegen (1) spricht nur der Aufwand des Zusammenführens; er fällt ohnehin vor dem nächsten gemeinsamen Build an.

**Folgerungen:** Bei A oder B: Tom führt den Figurenstand zusammen, Spike legt 499 darauf neu vor (ein Standbild, Prüfer vorher nach 511a), Perikles baut die Sperre. Bei C: nur der Figurenstand und die Sperre; 499 kommt danach neu mit den bekannten Mängeln als „bekannt“.
