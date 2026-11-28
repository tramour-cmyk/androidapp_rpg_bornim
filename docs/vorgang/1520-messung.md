# 1520 · Messung und Rechnung Neustart-Schwellen (22.11., 18:00, Tanja/Werkzeug)

**Quelle:** `get_session` (usage: cost_usd, cache_read_tokens, output_tokens; context_usage.used_tokens) und `list_events` (Startlast S = Token der ersten Antwort, `first_request_input_tokens` im ältesten result-Ereignis, in Stichproben gleich input + cache_creation + cache_read der ersten Antwort). Alle 76 Sitzungen ab 22.11., 07:00 (`list_sessions` 17:48), außer dieser.
**Preise** Opus 5.5 (platform.claude.com/docs/en/about-claude/pricing, gelesen 22.11.2026, 17:50): 1h-Cache schreiben 8 $, Cache lesen 0,20 $, Ausgabe 20 $ je MTok. Probe: Spike `…79Aq9nhhczCoQQ5pGA` 14,29 M × 0,20 + 0,188 M × 8 + 45,7 Tsd. × 20 = 5,28 $ (gemessen 5,285 $).

**Rechnung** (Erneuerung): Kontext je Schritt C_i = S + g·i. Aus R = n·(S+F)/2 folgt n = 2R/(S+F), g = (F−S)/n, o = Ausgabe/n. Kosten je Schritt bei Sperre T: n_T = (T−S)/g; c(T) = S·8 $/n_T + 0,20 $·(S + g·n_T/2) + g·8 $ + o·20 $. Minimum T* = S + √(2·S·g·8/0,20).

## Ergebnis je Rolle (Mediane)

| Rolle | Sitzungen | S | g je Schritt | c(300) | c(450) | c(600) | Minimum T* | gewählt |
|---|---|---|---|---|---|---|---|---|
| Spike | 27 | 91 Tsd. | 1610 | 6,75 ct | 8,01 ct | 9,42 ct | 199 Tsd. | 300 (Erinnerung 200) |
| Diogenes | 14 | 89 Tsd. | 1505 | 6,45 ct | 7,74 ct | 9,15 ct | 192 Tsd. | 300 |
| Arbeitsplaner | 9 | 83 Tsd. | 1946 | 6,92 ct | 8,17 ct | 9,57 ct | 197 Tsd. | 300 |
| Sokrates | 9 | 91 Tsd. | 1271 | 7,30 ct | 8,62 ct | 10,04 ct | 188 Tsd. | 500 bleibt (Chef 1643), Frage |
| Werkzeug | 3 | 83 Tsd. | 1977 | 7,29 ct | 8,55 ct | 9,94 ct | 197 Tsd. | 300 |
| Prüfer | 2 | 85 Tsd. | 2117 | 7,18 ct | 8,41 ct | 9,79 ct | 204 Tsd. | 300 |
| Wache | 2 | 82 Tsd. | 4638 | 9,51 ct | 10,44 ct | 11,70 ct | 256 Tsd. | 300 |
| Homer | 1 | 89 Tsd. | 1764 | 7,34 ct | 8,59 ct | 9,99 ct | 201 Tsd. | 300 |
| Tagesbericht | 1 | 82 Tsd. | 1598 | 6,39 ct | 7,70 ct | 9,12 ct | 184 Tsd. | 300 |
| Welt | 1 | 83 Tsd. | 1045 | 5,74 ct | 7,11 ct | 8,55 ct | 167 Tsd. | 300 |
| Ford/Disponent | 3 | 87 Tsd. | – | – | – | – | – | nie gesperrt (1574); Verdichtung, Rechnung gilt nicht |

Grenze der Rechnung: S zählt nur die erste Antwort; Einlesen und Übergabe nach einem Neustart stecken im Zuwachs g. Bei jeder Rolle liegt das Minimum unter 300 Tsd.: Längere Sitzungen kosten je Schritt mehr.

## Je Sitzung

Sitzung | Rolle | Kosten $ | S | F (Ende) | R (Cache gelesen) | n | g | Titel
---|---|---|---|---|---|---|---|---
session_01Hmoj76nxhntxhJYYddMPGq|Arbeitsplaner|0.90|83366|117535|1696741|17|2023|Doris – Auftrag 1960
session_01Hmoj79ZgpMW1THsZbYBzJZ|Arbeitsplaner|0.94|83223|124979|1515147|15|2869|Olga – Auftrag 1961
session_01Hmoj77TZBC79avEm4yiXQ4|Arbeitsplaner|0.56|83266|102252|904994|10|1946|Sabine – Auftrag 1963
session_01Hmoj77J6uJAaNn8KhozyjY|Arbeitsplaner|0.77|83515|112844|1403419|14|2052|Nora – Auftrag 1959
session_01Hmoj75dZt7ghbrhUjhDBih|Arbeitsplaner|0.93|83254|112057|2156801|22|1304|Doris – 1566
session_01Hmoj77g5ysHrmcYskr89MH|Arbeitsplaner|0.85|83379|110121|1749569|18|1479|Rita – Auftrag 1967
session_01Hmoj77ZNfe1rzD48LaT9m2|Arbeitsplaner|0.71|83131|107676|1242753|13|1884|Frieda – Auftrag 1520
session_01Hmoj75tPrg7caUib7YUAmX|Arbeitsplaner|0.88|83107|116586|1734347|17|1927|Carla – 1675
session_01Hmoj7ABizvCYsSqPn7zCpC|Arbeitsplaner|1.05|83234|124673|1909124|18|2256|Elke – Auftrag 1957
session_01Hmoj769mKUkZ32bCQXVrbF|Diogenes|1.60|88575|144592|3522205|30|1854|Diogenes – 1952
session_01Hmoj78yG8B8Bh1ac4ukUgC|Diogenes|4.22|88530|209517|12302840|83|1466|Diogenes – 1871
session_01Hmoj79TjtjkyN4fmEATTAb|Diogenes|3.99|88441|207107|11522449|78|1522|Diogenes – 1871 Abruf
session_01Hmoj79HXUVWUVwPiciQWcM|Diogenes|4.44|88442|205557|12917768|88|1333|Diogenes – Abruf
session_01Hmoj79k8diQ4BQpkURZYfE|Diogenes|4.81|88699|210820|14054372|94|1301|Diogenes – 1892
session_01Hmoj78KwJtPGy2TD2inBJo|Diogenes|4.52|88866|213057|12938067|86|1449|Diogenes – 1903, 1904
session_01Hmoj77TooVH1Lzh3PFXZnb|Diogenes|2.69|89013|186879|6224643|45|2169|Diogenes – 1893
session_01Hmoj77Q9Hwa5wXei6hUroa|Diogenes|4.53|88488|203811|10421522|71|1617|Diogenes – 1732
session_01Hmoj75koCfFkpKPUSP4UiR|Diogenes|5.13|88794|224133|15096375|96|1403|Diogenes – 1855, 1866
session_01Hmoj77TDb6mhAKmW6pg7An|Diogenes|5.32|88952|234240|15361014|95|1528|Diogenes – 1782
session_01Hmoj77PCVCc6pAEaWf2KDa|Diogenes|2.22|88801|170312|5247737|41|2012|Diogenes – 1789
session_01Hmoj79Yac79BJsSsRqN5ks|Diogenes|3.95|88926|207969|11616202|78|1521|Diogenes – 1874
session_01Hmoj75Z4Wv3TFp4tJjmvnM|Diogenes|4.78|88809|214635|14119426|93|1352|Diogenes – 1795, 1887, 1888
session_01Hmoj75RZKDwbGpBQvdoTJd|Diogenes|4.29|88930|215055|12874422|85|1489|Diogenes – 1801
session_01Hmoj77eawfwxZTjnt3cZap|Figur|–|83335|–|–|–|–|Dana – 1570 (läuft, ohne usage)
session_01Hmoj794iJPGuxtZCKhpEce|Ford|74.34|86560|217954|303987413|–|–|Ford – Betriebsleiter 11:11 (Verdichtung)
session_01Hmoj78swtcWnfPZeEocJxd|Disponent|8.20|85287|290194|25816803|138|1490|Disponent – Betrieb
session_01Hmoj75isNEtDyWupWmoFTR|Ford|55.53|89322|710264|231988216|–|–|Ford – Betriebsleiter 07:27
session_01Hmoj78PxfB5g1zzMuFetjQ|Homer|0.19|88671|88671|67390|–|–|Homer – 1628 (eine Antwort)
session_01Hmoj77kqEWhTzZssekzAxK|Homer|4.21|88907|211686|10463983|70|1764|Homer – 1900
session_01Hmoj783oi2m7x8RonkMvae|Prüfer|1.57|84478|149665|2886438|25|2644|Elke – 1957 Prüfung
session_01Hmoj79TvK79BhE8thDVp26|Prüfer|1.51|84772|137508|3685112|33|1590|Marta – 1566
session_01Hmoj77phAJFWjArJhz3Zn6|Sokrates|29.31|92393|418325|53157087|208|1566|Sokrates – 1727 Falltest
session_01Hmoj79ToN2N5UfxtXKt55p|Sokrates|27.85|91678|418902|66951286|262|1248|Sokrates – 1727 Vorlagen
session_01Hmoj766KCj14w54LxrDwYN|Sokrates|20.53|91631|412131|55699008|221|1449|Sokrates – 1727 Nachprüfung 3b
session_01Hmoj78cQFrwz9xMJtEJtun|Sokrates|14.66|83692|355124|44311393|202|1344|Sokrates – 1727 Leitung
session_01Hmoj791kx5aardWqqRc5ry|Sokrates|17.18|91054|409985|46164853|184|1731|Sokrates – 1931
session_01Hmoj75WtnahrGRxTf79xEr|Sokrates|41.58|91147|410069|98512540|393|811|Sokrates – 1727 Korrektur Lauf 4
session_01Hmoj75rguNmWmGrhnXztKJ|Sokrates|33.43|91348|419309|97140856|380|862|Sokrates – 1727j
session_01Hmoj75enoNdfP2VxtiQFxv|Sokrates|24.18|91490|416563|82350391|324|1003|Sokrates – 1727h–k
session_01Hmoj75SrwmjpvNxeNEdckU|Sokrates|27.76|91339|426864|68396872|264|1271|Sokrates – 1727 Nachprüfung 2
session_01Hmoj77X6zwSFVaw5svzZoj|Sonstige|1.05|83179|116681|2354241|24|1422|Britta – Auftrag 1570
session_01Hmoj76z6vML6SVpCxgLchV|Sonstige|0.96|83140|129024|1740215|16|2797|Anna – Auftrag 1727
session_01Hmoj79FMGAiVYf2iGQky9P|Spike|5.89|91112|244998|16793032|100|1540|Spike – 1895
session_01Hmoj787KJ4un4X2q9HM7Fe|Spike|4.10|91023|216661|10891716|71|1775|Spike – 1804
session_01Hmoj778HYhvtMFZAaJ8bQm|Spike|5.70|91736|233650|16036636|99|1440|Spike – 1739
session_01Hmoj76qhQiC75aX1Sjeb85|Spike|3.52|90758|206621|8840526|59|1949|Spike – 1951
session_01Hmoj77zGdKNkwecBKHuACS|Spike|4.18|90565|214039|11677539|77|1610|Spike – 1871 Kopie
session_01Hmoj78dqqQMjbyquheWmi7|Spike|4.96|90615|223563|14802179|94|1411|Spike – 1934
session_01Hmoj77NBDu91DNPyLZtugN|Spike|4.55|90524|224555|13475116|86|1567|Spike – 1871 C Rest
session_01Hmoj7A5MmSkcWkMLvM6TJ8|Spike|5.99|90913|245864|17134548|102|1523|Spike – 1878
session_01Hmoj79Aq9nhhczCoQQ5pGA|Spike|5.29|91322|255695|14290929|82|1996|Spike – 1893 Leser
session_01Hmoj79MHTCBn6mpr9Afs4E|Spike|6.42|91141|254113|19268287|112|1460|Spike – 1893 Restpunkte
session_01Hmoj76sWYxv4q1nTYKZ7Vw|Spike|4.36|90554|216434|12601095|82|1533|Spike – 1937 Rest
session_01Hmoj75QQNHz2VqyWqMxXYR|Spike|3.67|90518|212079|9117889|60|2017|Spike – 1923
session_01Hmoj7A53fegV6Leaz5iS6C|Spike|4.08|90475|225478|10527859|67|2026|Spike – 1927
session_01Hmoj78LKdchyGmK4stKLCq|Spike|5.35|91197|244650|15585459|93|1653|Spike – 1893 Rollennamen
session_01Hmoj77RWe34VKegaegSzpU|Spike|4.87|90897|243330|11924589|71|2136|Spike – 1792
session_01Hmoj77R6bCuvqYQAhpLvDZ|Spike|5.71|91030|246928|16346909|97|1612|Spike – 1872
session_01Hmoj77uCmd1fm8c8DJsLPr|Spike|4.54|90868|224983|13405640|85|1580|Spike – 1871 Vorprüfung
session_01Hmoj77WgC94L5eZV3iESSh|Spike|4.62|90666|253887|11888152|69|2365|Spike – 1944–1950
session_01Hmoj75Tbbx4depg8834LDn|Spike|12.78|90532|350825|44884711|203|1280|Spike – 1890
session_01Hmoj7A96zsuShakukwNTJg|Spike|4.20|90522|229043|10554569|66|2097|Spike – 1937 Probelauf
session_01Hmoj79A4WRf9iFhEAGiYS1|Spike|4.41|90528|224472|12378246|79|1704|Spike – 1871 C Rest g, h
session_01Hmoj76UCbCmmXCRMubEUbd|Spike|6.38|91155|226926|17297730|109|1248|Spike – 1922
session_01Hmoj79svCNnFH7mPcHYULH|Spike|6.66|91002|261200|19357925|110|1548|Spike – 1918
session_01Hmoj77wXvWRKKYcxscqvz7|Spike|5.72|90857|245714|16522370|98|1577|Spike – 1908
session_01Hmoj76y5AUboipbZuKAjZf|Spike|6.33|91030|244140|19185025|114|1337|Spike – 1781
session_01Hmoj76qK6JeQ7t8ffKmSaU|Spike|3.55|91158|223503|8882884|56|2344|Spike – 1893 lauf.py
session_01Hmoj79tQTiER1tcELHt1vz|Spike|6.55|91131|267181|19387538|108|1627|Spike – 1871 Kopie 07:50
session_01Hmoj76xeNdxekwR3jYyGX7|Tagesbericht|1.20|81586|123397|2681079|26|1598|Tagesbericht – 448
session_01Hmoj79hhHhCGNJXFC7Jdqe|Wache|0.53|81745|115949|488535|5|6921|Wache 17:44
session_01Hmoj779h8WNFhiAqG8Ydzj|Wache|1.04|81992|131164|2224641|21|2356|Wache 17:12
session_01Hmoj76t2ZJHkQA6XfyRfjJ|Welt|5.20|83227|202407|16282818|114|1045|Emil – 1566
session_01Hmoj77LVWvnt4N4nXLUZT8|Werkzeug|3.58|81974|180167|10465600|80|1230|Paula – 1959
session_01Hmoj76hXn4hcKC8cB2nTuY|Werkzeug|2.90|82845|185754|6229483|46|2219|Dirk – 1957
session_01Hmoj77Pyd6JdrG1AyQNLZT|Werkzeug|3.48|82959|199532|8328958|59|1977|Lena – 1960

Summe 610,38 $ (75 Sitzungen mit Kosten).
