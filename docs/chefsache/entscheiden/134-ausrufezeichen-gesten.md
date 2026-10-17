# 134 · Zeichen und Gesten bei Leuten mit Neuem: so bauen?
Tom · 17.10., 09:5x · Idee des Chefs (17.10., über Ford), geprüft, nichts gebaut

Kurz: machbar und passt; Empfehlung: ja, in zwei Schritten (erst goldenes „!“, dann Gesten), Kür

**Frage:** Leute, mit denen der Held schon gesprochen hat und die Neues zu sagen haben, zeigen es beim Herankommen: Zeichen über dem Kopf, dazu eine kleine Geste (drei Varianten). So bauen?

**Empfehlung: ja, in zwei Schritten, je ein Build.**

1. **Zeichen** (etwa eine Sitzung): ein **goldenes „!“** ohne Karte über der Person, ab etwa 5 Kacheln Nähe; weg, sobald der Held mit ihr gesprochen hat. Nicht das rote „!“ auf weißer Karte, das bei Monstern „hat dich bemerkt“ heißt (D3.5); Gold passt zur schwarz-goldenen Oberfläche.
   - **„Neues“** erkennt das Spiel selbst: Gespräche hängen nur vom Spielstand ab. Der Spielstand merkt sich je Person einen Fingerabdruck der zuletzt gehörten Zeilen; weicht das jetzige Gespräch ab oder kann der Held einen Auftrag abgeben, gibt es Neues. Kein Pflegeaufwand je Text, wächst mit jedem Kapitel mit; Kerntests je Person.
   - Fremde bekommen kein Zeichen (wie gesagt: nur wer schon gesprochen hat); sie zu finden bleibt Erkunden.
2. **Gesten** (ein bis zwei Sitzungen): drei Varianten, (a) **Hand heben** (Gruß), (b) **herwinken**, (c) **zum Helden drehen und nicken**. Einmal beim Herankommen, dann etwa alle 10 s, solange er nah ist und Neues wartet. Wer welche Geste macht, schlägt Homer vor (Spielgefühl; Garrick winkt anders als Aldric). Wer sitzt (Borin), hebt nur die Hand. Technik ist da: Garrick und Rowena haben schon eigene Bewegungsschleifen (`MapFolk.kt`).

**Stärkstes Gegenargument:** Ein schwebendes „!“ ist Spieloberfläche über der Welt (bekanntes Muster aus Online-Rollenspielen) und reibt sich mit „düster, glaubwürdig“ und mit 33 („wer etwas nicht will, wird nicht daran erinnert“). Die Gesten allein wären glaubwürdiger. Dagegen: Figuren sind auf dem Handy klein, eine Geste übersieht man leicht; das Zeichen verschwindet nach einem Gespräch, drängt also nicht. Wer es testet und störend findet, kann Schritt 2 behalten und Schritt 1 streichen.

<details><summary>Vier Fragen (33), Kosten, Berührtes</summary>

- Freiheit: nichts wird Pflicht; ein abgelehnter Nebenauftrag zeigt kein „!“ mehr, sobald gehört.
- Wenige Schritte: kein Fenster, kein Knopf.
- Bekannte Bedienung: wie das „!“ der Monster, nur andere Farbe.
- Wachstum: Erkennung aus dem Gespräch selbst, keine Liste zu pflegen.
- Berührt: `Story.kt`/`Game.kt` (Fingerabdruck beim Gespräch), Spielstand (eine Zuordnung je Person, alte Stände laden ohne Zeichen), `WorldScreen.kt` (eine Zeichenstelle neben dem Monster-„!“; Absprache mit Jerry), `MapFolk.kt` (Gesten).
- Offen bei Ja: ob Leute mit Neuem auch auf der Karte im Menü gekennzeichnet werden (62c) – Vorschlag nein, Karte erinnert nur.

</details>
