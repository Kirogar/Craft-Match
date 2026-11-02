# Craft-Match: Projektübergabe an Claude Code

Nov 2, 2026 · @Thomas

## Auftrag

Craft-Match ist ein Addon für WoW Forever (Interface 16001, Client 1.60.1). Es beantwortet eine Frage: Welche Rezepte, die meine Freunde herstellen können, wären ein Upgrade für meinen Charakter?

**Nutzer:** Thomas und seine Freunde, eine kleine Gruppe in einer gemeinsamen Gilde. Alle installieren das Addon.

**Basisversion (MVP):**

- Eigene Berufe und Rezepte scannen, sobald das Berufsfenster geöffnet wird.
- Rezepte und Handwerker (Charakter, Beruf, Skill) per Addon-Nachricht mit den Gildenmitgliedern austauschen, die das Addon haben.
- Die eigene angelegte Ausrüstung pro Slot merken.
- Eine Liste "Craft-Match" zeigen: Rezepte von Freunden, deren Ergebnis-Item für meinen Charakter ein Upgrade ist. Pro Eintrag: Item, Slot, Itemlevel-Differenz, Handwerker, Beruf, online ja oder nein, Button zum Anflüstern.
- Upgrade-Kriterium der Basisversion: höheres Itemlevel als das angelegte Item im selben Slot, für die Klasse tragbarer Rüstungs- oder Waffentyp, Levelanforderung erfüllt. Keine Stat-Gewichte.

**Nicht im MVP:** Stat-Gewichte pro Spec, Materialkosten, Aufträge und Wunschlisten, Camp-Funktionen, Auktionshauspreise, Loot-Weitergabe an Freunde (das wäre ein zweites Modul auf demselben Sync).

## Abgrenzung

Die Recherche vom 2. November 2026 fand kein Forever-Addon, das Rezepte von Freunden mit dem Gear-Bedarf des eigenen Charakters verknüpft. Ein Crafter-Verzeichnis soll Craft-Match nicht nachbauen.

| Addon | Was es kann | Was fehlt |
| --- | --- | --- |
| [Zunftbuch](https://www.curseforge.com/wow/addons/zunftbuch) | Crafter-Verzeichnis mit Gilden-Sync, Aufträge, Wunschliste, Camp-Übersicht, DE/EN | Keine Gear-Empfehlungen |
| [CraftBoard](https://www.curseforge.com/wow/addons/allemano-craftboard), [ForeverCodex](https://www.curseforge.com/wow/addons/forevercodex) | Crafter-Verzeichnis, Flüstern per Klick | Keine Gear-Funktion erwähnt |
| [CommunitiesForever](https://www.curseforge.com/wow/addons/communitiesforever) | Teilt Klasse, Level, Itemlevel, Berufe, Talente, Rolle, Quests mit Freunden | Keine Rezepte |
| [WhoNeedsThis](https://www.curseforge.com/wow/addons/whoneedsthis) | Tooltip: welcher eigene Charakter profitiert | Nur eigene Charaktere |
| [GearQuest Forever](https://www.curseforge.com/wow/addons/gearquest-forever), [ForeverGear](https://www.curseforge.com/wow/addons/forevergear) | Beste Items nach Klasse, Spec, Level | Kennen keine Freunde als Hersteller |
| [Loot It Forward](https://www.curseforge.com/wow/addons/loot-it-forward) | Zeigt, welches Gruppenmitglied von einem Drop profitiert | Laut Seite nur Retail |

Vor dem Start kurz auf CurseForge mit dem Filter "WoW Forever" nachsehen, ob inzwischen ein Addon diese Lücke füllt. Die Szene verändert sich wöchentlich.

## Technische Rahmenbedingungen

Forever läuft auf dem modernen Retail-Client, Classic-Addons laden dort nicht. Ein Spieltest ist soweit ich sehe erst ab dem Release am 4. November möglich: Die Beta ist laut [Blizzard](https://eu.forums.blizzard.com/en/wow/t/637227) beendet, den Release nennt [GosuGamers](https://www.gosugamers.net/entertainment/news/79204-world-of-warcraft-forever-beta-gets-off-to-a-rocky-start-as-players-face-hours-long-queues).

- **Client:** Laut [Kami Labs](https://kami-labs.fr/en/addons-wow-forever/) läuft Forever auf dem Midnight-Retail-Client mit der Interface-Nummer 16001. Die Addon-Seiten nennen Version 1.60.1. Das `.toc` braucht `## Interface: 16001`.
- **Regeln:** Forever übernimmt laut [Icy Veins](https://www.icy-veins.com/wow-forever/news/addons-in-wow-forever-blizzard-devs-just-addressed-the-big-question/) die UI-Architektur und die meisten APIs von Mainline 12.1.5 samt Midnight-Einschränkungen. Laut [Kami Labs](https://kami-labs.fr/wow-classic/wow-forever-addons-restreints-comme-sur-midnight/) betreffen sie den Kampf, Darstellungs- und Erkundungshilfen sind nicht betroffen.
- **Sync-Praxis:** [Zunftbuch](https://www.curseforge.com/wow/addons/zunftbuch) synchronisiert über den versteckten Gildenkanal, pausiert im Kampf, Raid und Dungeon und erfasst Rezepte erst, wenn das Berufsfenster geöffnet wurde. Craft-Match sollte dasselbe Muster nutzen.
- **Berufsfenster:** Forever hat laut [Warcraft Tavern](https://www.warcrafttavern.com/forever/guides/professions/) ein eigenes Berufsfenster wie das moderne WoW. Die Klassik-APIs dürfen nicht einfach vorausgesetzt werden.
- **Ordner:** Die Quellen widersprechen sich: [Mobalytics](https://mobalytics.gg/wow-forever/profile/broog-ccb0gf/guides/how-to-install-addons-wow-forever) nennt `World of Warcraft/forever/Interface/AddOns`, [allthings.how](https://allthings.how/world-of-warcraft-forever-how-to-install-addons-without-the-curseforge-app/) für die Beta `_classic_beta_\Interface\AddOns`. Den echten Pfad auf Thomas' Rechner prüfen.
- **SavedVariables:** Beim Beta-Client setzten manche Addons ihre Einstellungen beim Ausloggen zurück, laut [Inked](https://wowinterface.com/downloads/info27223-Inked.html) eine Beta-Einschränkung. Nach dem Release prüfen, ob gespeicherte Daten halten.
- **Abhängigkeiten:** Keine externen Libraries nötig. Andere Forever-Addons binden LibStub und Co. direkt ein.

## Schritt 0: Mini-Test

Bevor irgendetwas gebaut wird, muss ein winziges Addon drei Annahmen bestätigen. Der Test ist bestanden, wenn zwei Spieler in der Gilde je die Rezeptanzahl des anderen und ein Ergebnis-Item mit Slot und Itemlevel sehen.

1. Minimales Addon mit `.toc` (`## Interface: 16001`) und Slash-Befehl `/cm` anlegen.
2. **Rezepte lesen:** Beim Öffnen des Berufsfensters die Anzahl der Rezepte und drei Namen ausgeben. Welches Event und welche API dafür gelten, aus der Dokumentation für Interface 16001 ermitteln, nicht aus dem Classic-Gedächtnis raten.
3. **Senden:** Die Liste der Rezept-IDs per Addon-Nachricht an die Gilde schicken, beim Empfänger ausgeben. Vermutlich laufen die Aufrufe über `C_ChatInfo`, das ist zu prüfen.
4. **Item-Daten:** Für das Ergebnis-Item eines Rezepts Itemlevel, Slot, Rüstungs- oder Waffentyp und Mindestlevel abfragen. Item-Infos laden asynchron, das Addon muss auf den Abschluss warten.

**Wenn ein Schritt scheitert:**

- Gildenkanal trägt nicht: Party-Kanal oder Freundesverbindung testen, so machen es [Sharing Is Caring](https://www.curseforge.com/wow/addons/sharing-is-caring) und [CommunitiesForever](https://www.curseforge.com/wow/addons/communitiesforever).
- Rezept-API liefert nichts: ein manuelles Scan-Fenster, in dem der Spieler jede Berufsseite einmal öffnet.
- Item-Daten fehlen für Forever-Items: Ergebnis dokumentieren und mit Thomas besprechen, bevor weitergebaut wird.

## Architektur und Reihenfolge

Vorschlag mit fünf Modulen, gebaut in dieser Reihenfolge. Nach jedem Modul wird im Spiel getestet.

| Reihenfolge | Modul | Aufgabe | Hängt ab von |
| --- | --- | --- | --- |
| 1 | Mini-Test | Die drei Annahmen bestätigen | - |
| 2 | Scanner | Liest eigene Rezepte beim Öffnen des Berufsfensters und die angelegte Ausrüstung | Mini-Test |
| 3 | Store | Speichert pro Charakter Rezept-IDs, Beruf, Skill, Zeitstempel in SavedVariables, eigene und empfangene Daten getrennt | Scanner |
| 4 | Sync | Tauscht Rezeptlisten mit Gildenmitgliedern, die das Addon haben, pausiert im Kampf und in Instanzen | Store |
| 5 | Matcher | Prüft das Ergebnis-Item jedes fremden Rezepts gegen das eigene Item im selben Slot | Store, Item-Daten |
| 6 | UI | Liste "Craft-Match" mit Sortierung nach Itemlevel-Gewinn, Online-Status, Button zum Anflüstern, Minimap-Button | Matcher |

Das Sync-Muster "erst Hash vergleichen, dann nur Fehlendes nachladen" nutzt laut Beschreibung auch [TOG Profession Master](https://www.curseforge.com/wow/addons/togprofessionmaster). Gesendet werden sollten IDs statt Namen, weil Namen je nach Spielsprache verschieden sind.

Später, nicht jetzt: Stat-Gewichte pro Spec und die Loot-Weitergabe an Freunde, die dieselben Daten (Ausrüstung statt Rezepte) mitnutzt.

## Offene Annahmen

Diese Punkte sind nicht geklärt und dürfen nicht stillschweigend entschieden werden. Thomas fragen oder im Mini-Test prüfen.

1. **Upgrade-Kriterium:** Reicht das Itemlevel als Maßstab, oder soll von Anfang an nach Spec bewertet werden? Beim Leveln ist Itemlevel ein grobes Maß. Thomas hat die Frage noch nicht beantwortet.
2. **Equipment-Filter:** Forever-Rezepte erzeugen auch Camp-Objekte und Verbrauchsgüter. Craft-Match soll nur Rezepte listen, deren Ergebnis ausrüstbar ist.
3. **Item-Daten:** Woher kommen Slot, Typ und Level für neue Forever-Rezepte? Die Spielabfrage ist der bevorzugte Weg, mitgelieferte Datentabellen wären Wartungsaufwand.
4. **Eigener Sync oder Zunftbuch mitnutzen:** Eine dokumentierte Schnittstelle von Zunftbuch habe ich nicht gefunden. Vorschlag: eigener Sync, damit Craft-Match auch ohne Zunftbuch läuft.
5. **Reichweite des Gildenkanals:** [Forever Layer Hop](https://www.curseforge.com/wow/addons/forever-layer-hop) beobachtet mehrere Backend-Realms unter einem Ruleset. Ob alle Freunde über den Gildenkanal erreichbar sind, mit echten Spielern testen.
6. **Namensformat:** [TaskMaster Forever](https://www.curseforge.com/wow/addons/taskmaster-forever) weist auf zweiteilige Charakternamen in Forever hin. Beim Vergleichen, Speichern und Anflüstern beachten.
7. **Mats:** Ob ein Freund ein Item machen kann, heißt nicht, dass er die Materialien hat. In der Basisversion nicht gelöst, der Hinweis gehört ins UI.

## Arbeitsweise

Thomas arbeitet unter Windows und möchte das Addon in einem GitHub-Repo entwickeln, getestet wird direkt im Spiel.

- **Repo:** Ein eigenes Repo für das Addon, Name legt Thomas fest. Dieses Dokument als erste Datei (`PROJEKT.md`) einchecken.
- **Testschleife:** Das Repo liegt außerhalb des Spiels. Eine Ordner-Verknüpfung (`mklink /J`) zeigt aus dem AddOns-Ordner auf den Addon-Ordner im Repo. Ändern, `/reload`, Fehler lesen. Als Fehleranzeige eignen sich BugSack und BugGrabber, die auch der Zunftbuch-Autor für Fehlerberichte empfiehlt.
- **Dokumentation:** APIs nur verwenden, wenn sie für den Mainline-Client 12.1.5 belegt sind, zum Beispiel auf [warcraft.wiki.gg](https://warcraft.wiki.gg). Nichts aus dem Classic-Gedächtnis annehmen.
- **Commits:** Klein, ein Modul pro Schritt, jeweils nach einem Test im Spiel.
- **Zusammenarbeit:** Antworten auf Deutsch, knapp. Vor größeren Schritten Rückfragen stellen. Bei Unsicherheit das sagen statt raten. Immer nennen, was geändert wurde und warum.
- **Erste Aufgabe:** Mini-Test aus Schritt 0 bauen und Thomas das Ergebnis zeigen, bevor Scanner, Store, Sync, Matcher und UI folgen.
