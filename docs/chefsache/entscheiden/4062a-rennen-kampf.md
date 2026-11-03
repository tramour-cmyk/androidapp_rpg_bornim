# 406.2a · Im Kampf zum Angriff rennen wie im Dorf: jetzt oder nach dem Durchspielen?
Sokrates · 03.11., 09:00 · E Kampf · berührt D Aussehen

Kurz: Das Dorf-Laufen (UAL) gefällt, im Kampf läuft eine andere Bewegung (Paket Sword & Shield).

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/claude/jerry-406-2-parade/godot/kampf/figur.gd#L953

**Frage:** Soll Jerry den Angriffsweg im Kampf jetzt auf das Dorf-Laufen umstellen, oder erst nach dem Durchspielen?

**Votum:** „406.2a nach dem Durchspielen“, weil 488 Feinarbeit am Aussehen einfriert; „406.2a jetzt“, wenn dich das schnelle Gehen beim Durchspielen stört.

**Berührt:** 406.2 (Jerry), 488 (Einfrieren), 438a (Schild durchdringt Körper).

**Sachverhalt** (Chef 08:57: „wir haben doch im Dorfmodus, wenn die Klerikerin da rumläuft, die können doch auch vorlaufen … ist das ein anderes Modell wieder, oder?“): Ja. Dorf `Rennen` = UAL `Jog_Fwd_Loop` (`held_klassen.py:346`); Kampf mit Schild = Protofactor `SS_RunForward` (das Hopsen), seit 406.2 `SS_WalkForward` (schnelles Gehen).

**Vorschlag:** Beine und Rumpf aus `Jog_Fwd_Loop`, Schildarm in der Haltung aus Sword & Shield; ein Lauf mit Film.

**Stärkstes Gegenargument:** Mischen zweier Bewegungen kann den Schildarm in den Körper treiben (438a). **Entkräftet:** Der Schildarm bleibt ganz aus dem Paket, nur Beine und Rumpf wechseln; Durchdringung misst `pruef_kampf.py`.

**Folgerungen:** jetzt: ein Lauf bei Jerry, Film an dich; danach: Zeile bei Jerry „nach dem Durchspielen“.
