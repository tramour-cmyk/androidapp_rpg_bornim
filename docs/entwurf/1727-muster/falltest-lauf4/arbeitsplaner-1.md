# Falltest Lauf 4 · Arbeitsplaner · Gruppe 1 (A1–A7, A17–A19)

Geladen: `lt4/sockel.md`, `lt4/kern-buero.md`, `lt4/kern-arbeitsplaner.md`. Gelesen zum Nennen: die Profile Figur und Prüfbild, Signatur und Leben, Technik, Release, Oberfläche, Welt, Klang, Fremde Inhalte, Kampf, Story, Zugang Kaufrepo, Werkzeug, Tester, Disponent, Chefrunde. Werkzeug: `kopie/` (nur lesen, `--pruefen`).

## A1

(a) Was ich tue:
1. `python3 tools/vorgang.py 1694` gelesen (die Vorgangsdatei `docs/vorgang/1694.md` gibt es in der Kopie nicht; Stand, Absätze „Zu 1694“ und Archiv aus dem Werkzeug). Ähnliche Vorgänge: `vorgang.py 1657 1621 1711`; Git: `claude/spike-1694-griff` (`c64616f7a`, `1659ed4cb`, `7c7ce0f02`).
2. Steht das Chefwort nicht schon in der Vorgangsdatei (der Haken trägt es sonst ein): `python3 tools/vorgang.py chefwort 1694 "Als Systemlösung, genau. Jetzt sind wir nämlich wieder mal so weit damit, dass wir Sachzusammenhänge erkennen und deswegen auch Lösungen suchen und nicht ständig einzeln rumflicken." --zeit "18.11., 17:01"`.
3. Auftrag geschrieben, geprüft, dann eingetragen: `python3 tools/vorgang.py auftrag 1694 --datei A1.auftrag.md` (im Test nur `--pruefen`).
4. `python3 tools/vorgang.py rueckmeldung 1694 "Auftrag steht: 1694 Griff für alle gehaltenen Dinge (Stiel in der geschlossenen Faust), Systemlösung nach Chef 18.11., 17:01; Profil Figur und Prüfbild, Signatur und Leben, Zugang Kaufrepo; Lauf ab 21.11., 20:00 frei (Archiv 19.11., 07:46)."`

(b) Auftrag: `A1.auftrag.md`. Prüfung: `vorgang.py auftrag 1694: gültig (2069 Byte, davon Zitate unter „Bisher“ 127)` (erster Entwurf hielt an: „2387 Byte ohne Zitate unter „Bisher“, höchstens 2048“; gekürzt).

(c) Lücken:
- Die Lage nennt nur das Chefwort von 17:01; der Text sagt „Jedes frühere Nein des Chefs … steht wörtlich unter ‚Bisher‘“. Ich habe die Neins aus den Absätzen „Zu 1694“ und dem Archiv genommen (17:38, 21:37), weil `docs/vorgang/1694.md` fehlt. Wo die Neins stehen, wenn es keine Vorgangsdatei gibt, sagt der Text nicht.
- Das Chefwort in der Liste ist länger („… Das ist wichtig.“) als in der Lage. Welche Fassung „wörtlich“ gilt, sagt der Text nicht; ich habe die der Lage genommen.
- Systemfrage „Wie lösen es andere Spiele? Mit Quelle“: Ich habe keine fremde Quelle mit Datum (nur Spikes Satz 18.11., 17:05 „wie in Unreal/Unity“), also ist das der erste Schritt der Fachkraft.
- 2 KB reichen kaum für Ziel, vier Neins, drei Commits und die Lauffreigabe: Zitate im Ziel zählen mit, nur die unter „Bisher“ nicht.
- Lauffreigabe: der Kern sagt „genau ein Beleglauf“, aber nicht, wer ihn freigibt; die Freigabe stand im Archiv (Sokrates).

## A2

(a) Was ich tue (Lage 18.11., 21:37):
1. Bild `ansehen/1694-griff-laengs.md` angesehen (`git show 4d32f3947:docs/chefsache/ansehen/1694-griff-laengs.md`): alt und neu ohne Beschriftung, Waffe schwarz, nur Nahsicht, Spikes eigener Befund „neu wirkt nicht“, Messung gegen Bild widersprüchlich.
2. Chefwort mit Lesart: `python3 tools/vorgang.py chefwort 1694 "1694 ist nix zu erkennen..." --zeit "18.11., 21:37"`; Lesart `[Bild nicht beurteilbar]` in eckigen Klammern daneben in `docs/vorgang/1694.md` (Edit, gepusht).
3. Neuer Auftrag mit beiden Neins als Prüffragen: `python3 tools/vorgang.py auftrag 1694 --datei A2.auftrag.md`.
4. `python3 tools/vorgang.py rueckmeldung 1694 "Auftrag steht: 1694 Griff für alle gehaltenen Dinge, neu nach Chef 21:37 (Bild nicht beurteilbar): erst Messung gegen Bild rot nachstellen, Waffe farbig, Bild beschriftet mit Spielkamera in Handygröße; Lauf erst nach Freigabe Sokrates."`

(b) Auftrag: `A2.auftrag.md`. Prüfung: `vorgang.py auftrag 1694: gültig (2085 Byte, davon Zitate unter „Bisher“ 98)` (erster Entwurf: „2059 Byte ohne Zitate unter „Bisher“, höchstens 2048“).

(c) Lücken:
- „eine Lesart in eckigen Klammern daneben, wenn die Vorlage sie eindeutig macht“: Ich lese „nix zu erkennen“ als „Bild nicht beurteilbar“; die Gründe (unbeschriftet, schwarz, nur Nahsicht) sind mein Befund am Bild, nicht Chefwort. Ob das „eindeutig“ genug ist, sagt der Text nicht.
- Wie ich die Lesart eintrage, sagt der Text nicht: `vorgang.py chefwort` hat kein Feld für eine Lesart (`--zeit`, `--sitzung`, `--an`), Notizen nur mit Edit.
- Ob ein Nein zum Bild (Prüfart) einen neuen Auftrag braucht oder nur Feld 6 geändert wird, sagt der Text nicht. Ein Auftrag über dem alten in derselben Datei? Das Werkzeug trägt „## Auftrag (TT.MM., HH:MM)“ ein; ob es den alten ersetzt, sagt `--help` nicht.
- Ob dieses Chefwort „wie ein Nein klingt“ und deshalb auch an Sokrates geht, entscheidet laut Profil Disponent der Disponent; für mich steht es nicht im Text.

## A3

(a) Was ich tue:
1. `docs/LISTE-CHECK-BUILD-TEST.md` 9 und 10 gelesen (Art je Punkt: Aussehen Bild, Bewegung Film, Antippen Handy; Testbitte ab 4 Handypunkten; Grafikstufe in jeder Zeile).
2. Vorgang für Build 299 gesucht: keiner in der Liste. Prüfung mit 1694 wie verlangt.
3. Auftrag für den Build-Macher (Profil Technik): 299.1, 299.2 als Bild, 299.3 Handy mit Satz „warum nicht Bild“.
4. `python3 tools/vorgang.py rueckmeldung <Vorgang des Builds> "Auftrag steht: Build 299 Prüfliste: 299.1 und 299.2 als Bild (Aussehen), 299.3 am Handy (Antippen); Profil Technik, Figur und Prüfbild."`

(b) Auftrag: `A3.auftrag.md`. Prüfung: `vorgang.py auftrag 1694: gültig (2046 Byte, davon Zitate unter „Bisher“ 0)` (erster Entwurf hielt an: „2292 Byte …“ und „Feld 7 „Zurück“ hat Platzhalter <Nr>“).

(c) Lücken:
- Zu einem Build gibt es keine Vorgangsnummer; der Text verlangt „Vorgangsnummer und Titel in Worten“ und `rueckmeldung <Nr>`. Das Werkzeug verbietet `<Nr>` als Platzhalter; ich habe 1694 als Ersatz eingesetzt. Welche Nummer ein Build-Auftrag trägt, sagt der Text nicht.
- Kern: „Handy nur mit Satz ‚warum nicht Bild‘“; Checkliste 9 verlangt zusätzlich mindestens 4 Handypunkte für eine Testbitte. Mit nur 299.3 gibt es keine Testbitte; das steht in keinem meiner Texte, nur in der Checkliste.
- 299.3 ist ein Kampfpunkt (Ausweichen). Profil Kampf: „Bis Vorgang 1589.4 … ruht alles zu Plätzen und Bewegungen im Kampf: kein Auftrag, kein Lauf“; 1589.4 ist offen. Ob ein reiner Handy-Prüfpunkt dazu darunter fällt, sagt kein Text; ich habe das Profil Kampf nicht genannt.
- Wer den Build-Auftrag sonst schreibt (Build-Macher schreibt die Prüfliste laut Checkliste 9) und was davon meins ist, sagt der Kern nicht.
- Vorgänge hinter 299.1–299.3 nennt die Lage nicht; die Herkunft im Ziel ist darum nur „vorliegender Build-Auftrag“.

## A4

(a) Was ich tue: kein Auftrag. Ein 👎 ohne Wort sagt nicht, was falsch ist; ein Ziel daraus wäre eigene Auslegung (Kern Feld 1), Sockel 3: unklar, also anhalten und fragen.
1. `python3 tools/vorgang.py 1535` gelesen; Meldung und Bild `ansehen/1535-garrick-alt-neu.md` in Git gesucht (im Test kein Bild, kein „Beleg zeigt“).
2. Steht der 👎 nicht in der Vorgangsdatei: `python3 tools/vorgang.py chefwort 1535 "👎 (Telegram, zur Meldung „1535 Garrick alt gegen neu“, ohne Wort)" --zeit "21.11., abends"`.
3. Rückmeldung wörtlich:
`python3 tools/vorgang.py rueckmeldung 1535 "Frage: 1535 Kleidung bei gehobenem Arm (Garrick und Kittel): 👎 des Chefs zur Meldung „1535 Garrick alt gegen neu“, ohne Wort. Was ist falsch: kein Unterschied alt gegen neu, Beule noch da, Bild nicht beurteilbar, oder etwas anderes? Ohne sein Wort kein neuer Auftrag."`

(b) Rückmeldung oben (geht laut Werkzeug als Zeile an Sokrates).

(c) Lücken:
- Der Text kennt kein 👎 ohne Wort; nur „Fehlt ein Chefwort zu seiner Frage: ‚Frage‘ statt Auftrag“. Ich habe das sinngemäß angewandt.
- Uhrzeit des 👎 fehlt in der Lage; „Chefworte wörtlich mit Zeit“ ist so nicht erfüllbar. Ob ein Emoji ein „Chefwort“ für `vorgang.py chefwort` ist, sagt der Text nicht.
- Ob ich das Bild selbst ansehen und eine Lesart vorschlagen darf (Kern Büro: „Lesart … wenn die Vorlage sie eindeutig macht“), sagt der Text nicht für ein Zeichen ohne Wort.

## A5

(a) Was ich tue:
1. `python3 tools/vorgang.py 1727 235 535` gelesen: 235 = Regel „wer die Freigabe hört, führt zusammen“ (20.10.); 535 = erledigter Kampfvorgang ohne Bezug zur Vorlage.
2. Das Chefwort steht laut Lage schon in `docs/vorgang/1727.md` (Haken). Daneben, unverändert, die Lesart in eckigen Klammern (Edit, gepusht): „Ja, soweit alles klar. Profiltechnik-Jahr zu 535 Jahren“ `[Profil Technik ja, zu 235 ja]`. Eindeutig, weil die Vorlage genau Profil Technik und 235 nannte, „Jahr“/„Jahren“ wie „ja“ klingt und 535 mit der Vorlage nichts zu tun hat.
3. Kein Auftrag: 1727 gehört Sokrates (Abläufe), der Folgeauftrag ist eine Notizänderung (Checkliste 13: „Freigabe mit Einschränkungen“, Build-Macher führt zusammen statt wer die Freigabe hört), für die kein Profil passt, und die gebilligte Fassung liegt unter `docs/entwurf/`, die ich nicht belegen kann.
4. Rückmeldung wörtlich:
`python3 tools/vorgang.py rueckmeldung 1727 "Frage: 1727 Neustrukturierung: Chefwort 21.11., 15:15 aus der Spracherkennung gelesen als [Profil Technik ja, zu 235 ja]. Folge: Checkliste 13 nennt „mit Einschränkungen“ noch nicht, Profil Technik verweist schon darauf; 235 (wer die Freigabe hört, führt zusammen) wird ersetzt durch „der Build-Macher führt zusammen“. Wer zieht die Checkliste nach, und ab wann gilt das (Umstellung)? Kein Profil für Notizen; ohne das kein Auftrag."`

(b) Rückmeldung oben.

(c) Lücken:
- Wie die Lesart in die Vorgangsdatei kommt, sagt der Text nicht (kein Feld in `vorgang.py chefwort`).
- Ein Chefwort, das eine Vorlage billigt und keinen Bau verlangt, kennt mein Text nicht: Rückmeldung nur „Auftrag steht“ oder „Frage“; ein „kein Auftrag nötig“ kennt das Werkzeug (`rueckmeldung.py` 1797), mein Text nicht.
- Widerspruch Profil gegen Checkliste: Profil Technik: „welche Worte gelten und was ‚mit Einschränkungen‘ heißt: Checkliste 13“; `docs/LISTE-CHECK-BUILD-TEST.md` 13 sagt „Nach ‚passt‘ oder ‚freigegeben‘ (235): wer das Wort des Chefs hört … führt den PR selbst zusammen“, ohne „mit Einschränkungen“.
- In der Kopie steht die Lesart schon im Archiv (21.11., 15:15, Sokrates); ob ich sie dann noch einmal setze, sagt der Text nicht.

## A6

(a) Was ich tue:
1. `python3 tools/vorgang.py 1724 760` gelesen; Git: `git log --oneline 508bbbbad^2` (Merge von `claude/jerry-760-biss` auf `claude/build-300`, 760-Commits `a607a1d3d`, `18be49d71`, `13f6a3f70`, `be2c0d8f0`).
2. Lesart neben das Chefwort in `docs/vorgang/1724.md`: „lass es klar ziehen“ `[PR 221 nach main, ohne 760]` (Vorlage: Archiv „Build 300 freigegeben ohne 760 … PR 221 auf main ohne 760“).
3. Auftrag für den Build-Macher: `python3 tools/vorgang.py auftrag 1724 --datei A6.auftrag.md`.
4. `python3 tools/vorgang.py rueckmeldung 1724 "Auftrag steht: 1724 Build 300 auf main ohne 760 (Wolfssprung): nur die vier 760-Commits zurücknehmen, grüner Lauf, PR 221 zusammenführen; Profil Technik."`

(b) Auftrag: `A6.auftrag.md`. Prüfung: `vorgang.py auftrag 1724: gültig (2012 Byte, davon Zitate unter „Bisher“ 36)`; mit 1694 ebenso gültig.

(c) Lücken:
- In der Kopie ist 1724 schon erledigt (Archivzeile „erledigt, Geprüft an: 3db05d4e5“, Revert `dbdff8bc2` auf `claude/build-300`). Mein Text sagt nicht, was ich tue, wenn der Vorgang schon gebaut ist (kein „kein Auftrag nötig“ im Kern); ich habe nach der Lage geschrieben. Das Werkzeug prüft den Auftrag zu einem erledigten Vorgang ohne Hinweis als „gültig“.
- „lass es klar ziehen“: ob „klar“ eine Spracherkennung ist (etwa „glatt“), sagt keine Quelle; die Lesart stützt sich nur auf das Archiv.
- Profil Technik verweist für „mit Einschränkungen“ auf Checkliste 13, die das nicht enthält (siehe A5).
- Feld 6 „die erste, mit der der Chef allein urteilt: Bild, Film, Hörprobe; sonst Prüfung mit Ausgabe“: für einen Merge passt nur die Ausgabe; Prüffragen zu „Ist das Neue … im Beleg“ auf einen Revert umzudeuten, sagt der Text nicht.

## A7

(a) Was ich tue:
1. `python3 tools/vorgang.py 1535` gelesen; Git: `git show 7ffa715` ergibt „431 Tuch letzter Lauf“ (Kleiderschrank, Umhang), kein 1535-Commit. Der Versuch „Gewichte am Rumpf“ ist `547033f9f` (18.11., 16:25, `claude/tom-1535-gruss`: „Flanke des Kleids unter der Achsel an den Rumpf statt an den Oberarm“).
2. Ursache unbekannt, also nach Kern Feld 3: erst rot zeigen, Ursache mit Commit, dann beheben, in einem Auftrag.
3. `python3 tools/vorgang.py auftrag 1535 --datei A7.auftrag.md`.
4. `python3 tools/vorgang.py rueckmeldung 1535 "Auftrag steht: 1535 Kleidung bei gehobenem Arm (Garrick und Kittel): Beule rot zeigen, Ursache mit Commit, für alle Figuren mit Kaufkleid beheben, Bild alt gegen neu; Hinweis: der genannte Commit 7ffa715 gehört zu 431, nicht zu 1535."`

(b) Auftrag: `A7.auftrag.md`. Prüfung: `vorgang.py auftrag 1535: gültig (2173 Byte, davon Zitate unter „Bisher“ 159)` (erster Entwurf: „2127 Byte ohne Zitate unter „Bisher“, höchstens 2048“).

(c) Lücken:
- Die Lage nennt `7ffa715` als bisherigen Versuch; Git zeigt einen 431-Commit. Der Text sagt „Nicht raten, sondern belegen“, aber nicht, ob ein falscher Commit in der Vorlage eine „Frage“ ist oder ob ich den richtigen selbst suche. Ich habe ihn selbst gesucht und den Widerspruch in „Bisher“ benannt.
- In der Kopie ist 1535 „gebaut, Geprüft an: bfd783a3c (Bild 👍 21:40)“; die Lage sagt „Ursache unbekannt“. Ich habe nach der Lage geschrieben.
- „liegt die Ursache außerhalb des Ziels: ‚Frage‘“: ob ein gekauftes Modell (Kleid aus dem Kaufpaket) „außerhalb“ ist, sagt der Text nicht. Ich habe es als innerhalb gewertet, weil das Bauskript `kauf_kleid.py` uns gehört.
- Querprofil Fremde Inhalte genannt („bei fremder Datei“); ob ein Bauskript, das eine gekaufte Datei verarbeitet, schon „fremde Datei“ ist, sagt der Text nicht.

## A17

(a) Was ich tue:
1. Vorgang 1999 gesucht: `python3 tools/vorgang.py 1999` gibt „nichts gefunden“; ähnliche: 59e (Händlervorrat), 785.24 (Wirkungszeile), 649.3. Abgleich: `docs/LISTE-ABGLEICH-OBERFLAECHE.md` Zeile „Laden“: „da, mehrfach besser“.
2. „schöner“ ist Geschmack, aber mit Maß: die alte Fassung (Profil Oberfläche: Untergrenze). Darum Auftrag: Abgleich alt gegen neu, dann zwei bis drei Varianten zur Wahl des Chefs, kein Umbau vor seiner Wahl.
3. `python3 tools/vorgang.py auftrag 1999 --datei A17.auftrag.md`.
4. `python3 tools/vorgang.py rueckmeldung 1999 "Auftrag steht: 1999 Händlermenü: Kaufen alt gegen neu abgleichen, zwei bis drei Varianten als Bild zur Wahl des Chefs; Profil Oberfläche, Zugang Kaufrepo (alte Fassung)."`

(b) Auftrag: `A17.auftrag.md`. Prüfung: `vorgang.py auftrag 1999: gültig (2061 Byte, davon Zitate unter „Bisher“ 68)`; mit 1694 ebenso.

(c) Lücken:
- 1999 steht nicht in der Liste, das Werkzeug prüft trotzdem „gültig“ und hätte eingetragen (`vorgang.py 1999`: „nichts gefunden“).
- Kern: „Geschmack ohne Maß (‚düsterer‘): zwei bis drei Varianten“; hier gibt es ein Maß (alte Fassung), aber nicht, was genau schöner war. Ob Abgleich plus Varianten in einen Auftrag gehört oder erst eine „Frage“, sagt der Text nicht.
- Die alte Fassung liegt im Kaufrepo (`kotlin-alt/`); dass die Fachkraft dafür das Profil Zugang Kaufrepo braucht, steht nur im Profil selbst.
- Widerspruch Liste gegen Chef: Abgleichliste urteilt „mehrfach besser“; der Text sagt „ein Chefwort geht vor“, nicht, wer die Liste berichtigt.

## A18

(a) Was ich tue: kein Auftrag.
1. `python3 tools/vorgang.py 1998` (nichts gefunden in der Kopie); ähnliche Vorgänge gesucht: 1210 „Regen wie alt (D3.10) fehlt in Godot … Klang in 598“ (Tom, Kür, ruht nach dem Durchspielen 488), 598 „Umweltklang je Ort, Tageszeit, Wind und Wetter“ (Jerry, ruht bis 23.11.); `docs/LISTE-EFFEKTE.md`: „Wetter je Ort | Regen, Sturm mit Blitz, Nebel … | Frage (neues Spielgefühl)“; `docs/LISTE-IDEEN.md`: „neues Wetter erst mit neuen Orten“.
2. Das Chefwort „Wetter machen wir.“ sagt nicht, welches Wetter, wo, wie es aussieht und klingt; der Titel („Regen in allen Außengebieten, mit Klang und Licht“) hat keine Herkunft. Aussehen und Klang sind nicht meins, Ziel ohne eigene Auslegung, und es gibt schon 1210 und 598.
3. Rückmeldung wörtlich:
`python3 tools/vorgang.py rueckmeldung 1998 "Frage: 1998 Wetter (Regen in allen Außengebieten, mit Klang und Licht): Chefwort 10.11. nur „Wetter machen wir.“; Titel ohne Herkunft. Dasselbe liegt schon in 1210 (Regen wie alt, Tom, Kür, ruht nach dem Durchspielen) und 598 (Klang, Jerry, ruht bis 23.11.); LISTE-EFFEKTE führt Wetter als Frage (neues Spielgefühl). Bitte klären: zusammenlegen mit 1210, Muss oder Kür, Umfang (nur Regen wie alt in Wald und Dorf oder alle Außengebiete), Vorgabe zu Aussehen und Klang oder zwei bis drei Varianten zur Wahl des Chefs?"`

(b) Rückmeldung oben.

(c) Lücken:
- Doppelte Vorgänge: mein Text sagt „ähnliche Vorgänge … lesen“, aber nicht, was bei einem sicheren Doppel geschieht (das Zusammenlegen steht nur im Profil Disponent: „Eingang. Gibt es ihn schon?“).
- Muss gegen ruhende Kür (1210): wer das entscheidet, sagt mein Text nicht.
- „Großes Vorhaben“ (neues Spielgefühl) kennt mein Text nicht als Grund für „Frage“; ich stütze mich auf „Nicht deins: … Aussehen, Klang“ und „Keine eigene Auslegung“.

## A19

(a) Was ich tue:
1. `python3 tools/vorgang.py 1997` (nichts gefunden in der Kopie); ähnliche: 1674 (Bewohner am Brunnen, Wegfindung). Alte Fassung: `docs/LISTE-ABGLEICH-ALT.md` Brunnen (16/16, Steinring) und Hofdinge „Eimer/Waschzuber … je drei Varianten“. Godot: kein Eimer (`grep -rni "eimer\|bucket" godot` leer). Bestand: `Bucket_Metal` (MegaKit Standard, CC0), `Bucket_Wooden_2` (Source, gekauft 16.11.).
2. `python3 tools/vorgang.py auftrag 1997 --datei A19.auftrag.md`.
3. `python3 tools/vorgang.py rueckmeldung 1997 "Auftrag steht: 1997 Eimer am Dorfbrunnen: Brunnen und Hofstellen gegen die alte Fassung abgleichen, Eimer aus dem Bestand setzen, Bild alt gegen neu; Profil Welt, Signatur und Leben, Figur und Prüfbild, Fremde Inhalte."`

(b) Auftrag: `A19.auftrag.md`. Prüfung: `vorgang.py auftrag 1694: gültig (1903 Byte, davon Zitate unter „Bisher“ 23)`; mit 1997 ebenso gültig (Erstfassung).

(c) Lücken:
- Ob ein Eimer „Aussehen“ ist (nicht meins) oder ein Spielfund mit klarem Ziel, sagt der Text nicht; ich werte ihn als Fund mit Maß (alte Fassung, Bestand).
- Welcher Eimer (CC0-Metall oder gekaufter Holzeimer) ist Aussehen; das überlasse ich der Fachkraft nach Profil Welt und Fremde Inhalte, der Text sagt nicht, ob ich das vorgeben muss.
- 1997 steht nicht in der Liste; das Werkzeug prüft trotzdem „gültig“.

## Allgemein

- Mein Text verlangt „Lies zuerst die Vorgangsdatei (`docs/vorgang/<Nr>.md`)“; für keinen der Fälle gibt es sie in der Kopie (nur 1760, 1789, … 1937). Ich habe `vorgang.py <Nr>` gelesen.
- Kern Arbeitsplaner: „Felder und Größe: `vorgang.py auftrag <Nr>`“; die Vorlage dort nennt Feld 6 „Prüfart und Prüfe vor dem Senden“, der Kern nur „Prüfart“; das Werkzeug nimmt beides.
- „höchstens fünf Punkte und der Pfad des Profils“: ob die Profilpfade unter die fünf Punkte zählen, sagt der Text nicht; ich habe sie mitgezählt.
- Die Profile liegen künftig unter `docs/profile/`; dort gibt es in der Kopie noch keine. Ich nenne den künftigen Pfad.
