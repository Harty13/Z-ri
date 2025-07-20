# Züri - SwiftUI App

## Project Overview

Leitbild Züri-App

Zielgruppe & Personas
Die App richtet sich an junge Erwachsene zwischen 16 und 30 Jahren, die in der Stadt Zürich wohnen.

Name: Lara, 17
Hintergrund: 5. Jahr am Literargymi Rämibühl
Interessen & Lebensstil: Lernt viel, macht Kickboxen, geht in die Pfadi, verbringt viel Zeit am See, grilliert oft mit Freunden.
Potenzielle App-Funktionen: Grillstellen & Brunnen, Bänkli & Aussichtspunkte, Wassertemperatur, Konzerte

Name: Emir, 15
Hintergrund: 3. Sek in Zürich-Oerlikon
Interessen & Lebensstil: Spielt Fussball im Verein, trifft sich oft mit Freunden, liebt Fast Food.
Potenzielle App-Funktionen: Brunnen, Fusballfelder

Name: Julia, 22
Hintergrund: Psychologie-Studentin an der Uni Zürich
Interessen & Lebensstil: Lebt in einer WG, oft in Bibliotheken oder Cafés, interessiert an Nachhaltigkeit.
Potenzielle App-Funktionen: Lernorte (Bibliotheken & Cafés), Termine für Abfallentsorgung, Flohmärkte, Demo-Ankündigungen, Velopumpen

Name: Dario, 28
Hintergrund: IT-Consultant bei einer Zürcher Firma
Interessen & Lebensstil: Pendelt zwischen Homeoffice und Büro, geht ins Gym, spart für die Zukunft.
Potenzielle App-Funktionen: Calisthenics-Anlagen, Jogging-Routen, Clubs & Bars


Problem & Bedürfnis
Viele junge Erwachsene in Zürich kennen nicht alle lokalen Angebote, nützlichen Orte oder Events, die ihren Alltag bereichern könnten. Informationen sind oft verstreut, nicht aktuell oder schwer zugänglich.

Die Zielgruppe sucht eine einfache, zentrale Plattform, die:
lokale Freizeit- und Infrastruktur-Angebote bündelt
auf ihre individuellen Interessen abgestimmt ist
schnell und mobil zugänglich bleibt

Vision

Die Züri-App soll das Gefühl bringen, die Stadt in der Tasche zu haben.

Aufbau
Die App unterscheidet drei Nutzerstufen, die aufeinander aufbauen:

1. Info
Der Nutzer hat noch kein Profil erstellt und verwendet die App ausschließlich zur manuellen Suche von Inhalten.


2. Entdecken
Der Nutzer hat ein Profil angelegt und grundlegende Informationen sowie Interessen angegeben. Dadurch erhält er personalisierte Inhaltsempfehlungen.

3. Moderator
Der Nutzer ist mit der App vertraut und verfügt über Erfahrung. In dieser Stufe kann er aktiv an der Inhaltsmoderation mitwirken.

Inhalt
Der Inhalt, der in der App angezeigt wird, wird in mehrere Hauptklassen und diese jeweils in Unterthemen aufgeteilt.

Orte
Gastronomie
Cafés
Restaurants
Gelaterias
Take-Away (Döner)
Bars

Shopping
Bekleidung
Second Hand

Natur / im Freien
Parks
Wiesen
Aussichtspunkte
Schöne Bänke
Seen / Flüsse

Öffentliche Infrastruktur
WCs
Brunnen
Velopumpstationen

Kulturorte
Museen
Bibliotheken

Sport & Freizeit
Sportplätze
Skateparks
Spraye
Fotoautomaten
Outdoor-Fitnessanlagen
Schwimmbäder
Lost Places

Veranstaltungen
Nachtleben & Musik
Konzerte
Clubveranstaltungen
Festivals

Kunst & Kultur
Ausstellungen
Theater / Oper
Filmvorführungen

Märkte & Messen
Flohmärkte
Märkte

Sport
Public Viewing
Lauf-Events

Jahreszeitliche Highlights
Weihnachtsmärkte
Street Parade
Quartierfeste

Aktuelle Hinweise & Informationen
Regelmässige Hinweise
Papier- und Kartonsammlung

Spontane Hinweise
Demonstrationen
Ausfälle ÖV

Dauerhafte Informationen
Wetter
See- und Flusstemperatur

Technische Umsetzung
Grundsätzlicher Aufbau
Die Variabeln, Klassen, etc. werden auf Englisch benannt, es sei denn dies ist nicht möglich.
Backend
Die App verwendet Firebase als Backend-Plattform. Zum Einsatz kommen Firestore für die Datenspeicherung, Firebase Auth für die Benutzerverwaltung sowie Cloud Functions für die Verarbeitung von Hintergrundaufgaben und Datenimporten.
Frontend
Die mobile App wird primär für iOS mit SwiftUI entwickelt. Eine spätere Version für Android ist vorgesehen. Je nach Komplexität und Ressourcen kann zu einem späteren Zeitpunkt eine Cross-Plattform-Lösung wie React Native in Betracht gezogen werden.
Admin-Panel
Zur Verwaltung und Korrektur von Inhalten wird eine separate Web-Oberfläche erstellt. Diese dient ausschliesslich der internen Nutzung (z. B. für Datenpflege, Einsicht in Statistiken, manuelle Korrekturen). Sie basiert auf modernen Webtechnologien wie React und ist direkt mit der Firebase-Datenbank verbunden.
Automatisierte Skripte
Im Hintergrund laufen regelmässig automatisierte Prozesse. Diese kümmern sich unter anderem um:
das Abrufen und Aktualisieren von Daten aus externen Quellen (z. B. Open Data, Wetterdienste, Abfallkalender)
das Einpflegen und Prüfen von durch Nutzer vorgeschlagenen Inhalten
die Verwaltung und Auswertung von Nutzungsdaten

Datenstruktur
Die App unterscheidet drei zentrale Inhaltstypen: Orte, Veranstaltungen und Hinweise & Informationen. Diese werden in separaten Collections gespeichert. Jeder dieser Typen wird als eigene Basisklasse (Protokoll) geführt und in strukturierter Form gespeichert. Für jede Basisklasse existieren mehrere Subtypen, die zusätzliche Felder besitzen.
1. Orte (Basistyp: Location)
Gemeinsame Felder:
id
type: Subtyp des Ortes (z. B. fountain, restaurant)
coordinates: Koordinaten (Latitude, Longitude)
tags: Liste an Schlagwörtern
imageUrls: Bild-URLs (optional)
public: Sichtbarkeit (true/false)

Subtypen erben von dieser Basisklasse / Protokoll und fügen weitere Argumente hinzu. Bspw. Cafe, Park, Fountain, etc.

2. Veranstaltungen (Basistyp: Event)
Gemeinsame Felder:
id
type: Subtyp der Veranstaltung (z. B. concert, market)
startDate, endDate
locationId (Verknüpfung mit einem Ort)
tags
public
Subtypen sind bspw. Concert, Market


3. Hinweise & Informationen (Basistyp: Info)

// Werden erst später implementiert.

## Current Implementation Status

### Already Implemented (Legacy - to be replaced)
- Location.swift: Concrete struct with comprehensive fields including geohash, Firebase integration
- LocationType.swift: Struct with fountain and toilet types
- FirebaseAPI.swift: Complete service with geohash-based spatial queries
- MapManager.swift: Location services and camera management
- ContentView.swift: Full map UI with filters, location browsing, route display
- UI Components: CompactLocationView, LocationMarkerView, LocationSheetView

### Architecture Migration Plan
The current implementation uses concrete structs rather than the protocol-based architecture specified above. The migration involves:

1. Implement protocol-based Location architecture
2. Create specific location type structs (Fountain, Toilet, Library, Park)
3. Update Firebase service to work with protocols
4. Migrate UI components to use new architecture
5. Remove legacy concrete Location struct

### Technical Requirements
- All variables, classes, and types must be named in English
- Use protocol-based design for extensibility
- Firebase Firestore integration with @DocumentID support
- Geohash-based spatial queries for performance
- CLLocationCoordinate2D integration for MapKit
- Codable compliance for Firebase serialization

### Location Type Specifications
Based on requirements clarification:
- Fountain: No additional properties beyond base Location protocol
- Toilet: Additional property `price: String?` (e.g., "Free", "1 CHF", "2 CHF")
- Library: No additional properties beyond base Location protocol
- Park: No additional properties beyond base Location protocol
