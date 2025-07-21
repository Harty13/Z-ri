//
//  DataImporter.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import MapKit

enum DataImportError: Error {
    case fileNotFound(String)
    case parseError(Error)
    case invalidCoordinates
    case uploadError(Error)
}

class DataImporter {
    
    static func importBrunnenData() async throws {
        print("🚰 Starting import of fountain data from Brunnen.json...")
        
        guard let url = Bundle.main.url(forResource: "Brunnen", withExtension: "json") else {
            throw DataImportError.fileNotFound("Brunnen.json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let geoJSON = try JSONDecoder().decode(GeoJSONFeatureCollection.self, from: data)
            
            print("📄 Parsed GeoJSON with \(geoJSON.features.count) fountain features")
            
            var fountains: [Fountain] = []
            var successCount = 0
            var errorCount = 0
            
            for feature in geoJSON.features {
                do {
                    let fountain = try createFountainFromFeature(feature)
                    fountains.append(fountain)
                    successCount += 1
                } catch {
                    print("⚠️ Error processing fountain feature: \(error)")
                    errorCount += 1
                }
            }
            
            print("✅ Successfully processed \(successCount) fountains, \(errorCount) errors")
            
            // Upload to Firestore
            await uploadLocationsToFirestore(fountains)
            
        } catch {
            throw DataImportError.parseError(error)
        }
    }
    
    static func importWCData() async throws {
        print("🚽 Starting import of toilet data from WCs.json...")
        
        guard let url = Bundle.main.url(forResource: "WCs", withExtension: "json") else {
            throw DataImportError.fileNotFound("WCs.json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let geoJSON = try JSONDecoder().decode(GeoJSONFeatureCollection.self, from: data)
            
            print("📄 Parsed GeoJSON with \(geoJSON.features.count) toilet features")
            
            var toilets: [Toilet] = []
            var successCount = 0
            var errorCount = 0
            
            for feature in geoJSON.features {
                do {
                    let toilet = try createToiletFromFeature(feature)
                    toilets.append(toilet)
                    successCount += 1
                } catch {
                    print("⚠️ Error processing toilet feature: \(error)")
                    errorCount += 1
                }
            }
            
            print("✅ Successfully processed \(successCount) toilets, \(errorCount) errors")
            
            // Upload to Firestore
            await uploadLocationsToFirestore(toilets)
            
        } catch {
            throw DataImportError.parseError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private static func createFountainFromFeature(_ feature: GeoJSONFeature) throws -> Fountain {
        guard feature.geometry.coordinates.count >= 2 else {
            throw DataImportError.invalidCoordinates
        }
        
        let longitude = feature.geometry.coordinates[0]
        let latitude = feature.geometry.coordinates[1]
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Extract fountain information from properties
        let properties = feature.properties
        let standort = properties["standort"]?.stringValue ?? ""
        let ortsbezeichnung = properties["ortsbezeichnung"]?.stringValue ?? ""
        let quartier = properties["quartier"]?.stringValue ?? ""
        
        // Combine location information for name
        var name = "Brunnen"
        if !ortsbezeichnung.isEmpty {
            name = ortsbezeichnung
        } else if !standort.isEmpty {
            name = standort
        }
        
        // Create tags from available information
        var tags: [String] = []
        if let quartierValue = quartier, !quartierValue.isEmpty {
            tags.append("Quartier: \(quartierValue)")
        }
        if let brunnenart = properties["brunnenart"]?.stringValue, !brunnenart.isEmpty {
            tags.append(brunnenart)
        }
        if let wasserart = properties["wasserart"]?.stringValue, !wasserart.isEmpty {
            tags.append(wasserart)
        }
        
        // Extract image URL if available
        var imageUrls: [String] = []
        if let foto = properties["foto"]?.stringValue, !foto.isEmpty {
            imageUrls.append(foto)
        }
        
        // Check if fountain is operational
        let abgestellt = properties["abgestellt"]?.stringValue
        let isPublic = abgestellt != "ja" // Not shut down = public
        
        return Fountain(
            coordinates: coordinate,
            name: name,
            tags: tags,
            imageUrls: imageUrls,
            isPublic: isPublic
        )
    }
    
    private static func createToiletFromFeature(_ feature: GeoJSONFeature) throws -> Toilet {
        guard feature.geometry.coordinates.count >= 2 else {
            throw DataImportError.invalidCoordinates
        }
        
        let longitude = feature.geometry.coordinates[0]
        let latitude = feature.geometry.coordinates[1]
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Extract toilet information from properties
        let properties = feature.properties
        let name = properties["name"]?.stringValue ?? "WC"
        let adresse = properties["adresse"]?.stringValue ?? ""
        let kategorie = properties["kategorie"]?.stringValue ?? ""
        
        // Create tags from available information
        var tags: [String] = []
        if !adresse.isEmpty {
            tags.append("Adresse: \(adresse)")
        }
        if !kategorie.isEmpty {
            tags.append(kategorie)
        }
        
        // Extract infrastructure information for pricing
        let infrastruktur = properties["infrastruktur"]?.stringValue ?? ""
        var price: String?
        
        if infrastruktur.lowercased().contains("gebührenfrei") || 
           infrastruktur.lowercased().contains("gratis") {
            price = "Free"
        } else if infrastruktur.lowercased().contains("gebühr") {
            price = "Paid"
        }
        
        // Add infrastructure info to tags
        if !infrastruktur.isEmpty {
            tags.append(infrastruktur)
        }
        
        return Toilet(
            coordinates: coordinate,
            name: name,
            price: price,
            tags: tags,
            imageUrls: [],
            isPublic: true
        )
    }
    
    private static func uploadLocationsToFirestore<T: Location>(_ locations: [T]) async {
        print("📤 Uploading \(locations.count) locations to Firestore...")
        
        let service = LocationService.shared
        var successCount = 0
        var errorCount = 0
        
        for location in locations {
            do {
                try await service.uploadLocation(location)
                successCount += 1
                
                if successCount % 10 == 0 {
                    print("📤 Uploaded \(successCount)/\(locations.count) locations...")
                }
            } catch {
                print("❌ Failed to upload location \(location.name): \(error)")
                errorCount += 1
            }
        }
        
        print("✅ Upload complete: \(successCount) successful, \(errorCount) failed")
    }
    
    // MARK: - Public Import Methods
    
    static func importAllData() async throws {
        print("🚀 Starting import of all data files...")
        
        do {
            try await importBrunnenData()
            try await importWCData()
            print("🎉 All data import completed successfully!")
        } catch {
            print("❌ Data import failed: \(error)")
            throw error
        }
    }
}