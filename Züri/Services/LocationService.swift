//
//  LocationService.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import FirebaseFirestore
import GeohashKit
import MapKit
import SwiftGFUtils

// Legacy Location structure for migration
typealias OldLocation = LegacyLocation

struct LegacyLocation: Codable {
    var id: String?
    var name: String?
    var latitude: Double
    var longitude: Double
    var geohash: String
    var primaryTypeID: String
    var images: [URL?]?
    var isFree: Bool?
    var prices: [String: Double]?
}

enum LocationServiceError: Error {
    case networkError(Error)
    case decodingError(Error)
    case invalidDocument
    case unknownLocationType(String)
}

@MainActor
class LocationService: ObservableObject {
    static let shared = LocationService()
    
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    func decodeLocation(from doc: DocumentSnapshot) -> (any Location)? {
        guard let data = doc.data() else {
            return nil
        }
        
        // Try new protocol-based structure first
        if let typeString = data["type"] as? String,
           let locationType = LocationType(rawValue: typeString) {
            
            do {
                switch locationType {
                case .brunnen:
                    return try doc.data(as: Fountain.self)
                case .wc:
                    return try doc.data(as: Toilet.self)
                case .bibliothek:
                    return try doc.data(as: Library.self)
                case .park:
                    return try doc.data(as: Park.self)
                }
            } catch {
                print("Error decoding new location format: \(error)")
            }
        }
        
        // Fallback to legacy Location struct
        do {
            let legacyLocation = try doc.data(as: OldLocation.self)
            return migrateLegacyLocation(legacyLocation)
        } catch {
            print("Error decoding legacy location: \(error)")
            return nil
        }
    }
    
    private func migrateLegacyLocation(_ legacy: OldLocation) -> (any Location)? {
        let coordinate = CLLocationCoordinate2D(latitude: legacy.latitude, longitude: legacy.longitude)
        let locationData = LocationData(
            coordinates: coordinate,
            name: legacy.name ?? "Unnamed Location",
            tags: [],
            imageUrls: legacy.images?.compactMap { $0?.absoluteString } ?? [],
            isPublic: true
        )
        
        // Map legacy primaryTypeID to new LocationType
        let locationType: LocationType
        switch legacy.primaryTypeID {
        case "fountain":
            locationType = .brunnen
        case "toilet":
            locationType = .wc
        case "library":
            locationType = .bibliothek
        case "park":
            locationType = .park
        default:
            locationType = .brunnen // default fallback
        }
        
        switch locationType {
        case .brunnen:
            return Fountain(data: locationData)
        case .wc:
            let price = legacy.isFree == true ? "Free" : legacy.prices?.first?.value.description
            return Toilet(data: locationData, price: price)
        case .bibliothek:
            return Library(data: locationData)
        case .park:
            return Park(data: locationData)
        }
    }
    
    func fetchLocations(ofType types: [LocationType], nearCoordinate coordinate: CLLocationCoordinate2D, radius: Double = 500) async throws -> [any Location] {
        isLoading = true
        defer { isLoading = false }
        
        let typeStrings = types.map { $0.rawValue }
        let legacyTypeStrings = types.map { type in
            switch type {
            case .brunnen: return "fountain"
            case .wc: return "toilet"
            case .bibliothek: return "library"
            case .park: return "park"
            }
        }
        
        let geoHashPairs = GeoHashUtils.geoHashUtils.queryBoundsForLocation(location: coordinate, radius: radius)
        
        var allLocations: [any Location] = []
        
        // Try new protocol-based structure first
        let newQueries = geoHashPairs.map { bound -> Query in
            return db.collection("locations")
                .whereField("type", in: typeStrings)
                .order(by: "data.geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        // Try legacy structure as fallback
        let legacyQueries = geoHashPairs.map { bound -> Query in
            return db.collection("locations")
                .whereField("primaryTypeID", in: legacyTypeStrings)
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        let allQueries = newQueries + legacyQueries
        
        // Execute all queries concurrently
        try await withThrowingTaskGroup(of: [any Location].self) { group in
            for query in allQueries {
                group.addTask {
                    do {
                        let snapshot = try await query.getDocuments()
                        var locations: [any Location] = []
                        
                        for document in snapshot.documents {
                            if let location = self.decodeLocation(from: document) {
                                locations.append(location)
                            }
                        }
                        
                        return locations
                    } catch {
                        // If query fails, return empty array
                        return []
                    }
                }
            }
            
            for try await locations in group {
                allLocations.append(contentsOf: locations)
            }
        }
        
        // Remove duplicates based on coordinates (in case same location exists in both formats)
        var uniqueLocations: [any Location] = []
        var seenCoordinates: Set<String> = []
        
        for location in allLocations {
            let coordKey = "\(location.coordinates.latitude),\(location.coordinates.longitude)"
            if !seenCoordinates.contains(coordKey) {
                seenCoordinates.insert(coordKey)
                uniqueLocations.append(location)
            }
        }
        
        // Sort by distance from the coordinate
        let currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        uniqueLocations.sort { loc1, loc2 in
            let coord1 = CLLocation(latitude: loc1.coordinates.latitude, longitude: loc1.coordinates.longitude)
            let coord2 = CLLocation(latitude: loc2.coordinates.latitude, longitude: loc2.coordinates.longitude)
            
            return coord1.distance(from: currentLocation) < coord2.distance(from: currentLocation)
        }
        
        return uniqueLocations
    }
    
    func fetchLocations(ofType type: LocationType, nearCoordinate coordinate: CLLocationCoordinate2D, radius: Double = 500) async throws -> [any Location] {
        return try await fetchLocations(ofType: [type], nearCoordinate: coordinate, radius: radius)
    }
    
    func uploadLocation<T: Location>(_ location: T) async throws {
        try db.collection("locations").document(location.id ?? UUID().uuidString).setData(from: location)
    }
}