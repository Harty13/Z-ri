//
//  FirebaseAPI.swift
//  Züri
//
//  Created by Erik Schnell on 12.03.2025.
//

import Foundation
import FirebaseFirestore
import GeohashKit
import MapKit
import SwiftGFUtils

class FirebaseAPI: ObservableObject {
    @Published var isLoading: Bool = false
    let db = Firestore.firestore()
    
//    func uploadLocationsToFirebase(locations: [Location]) {
//        
//        for location in locations {
//            do {
//                // Speichern der Location im Firestore
//                try db.collection("locations").document(location.id ?? UUID().uuidString).setData(from: location) { error in
//                    if let error = error {
//                        print("Error uploading location: \(error.localizedDescription)")
//                    } else {
//                        print("Location uploaded successfully!")
//                    }
//                }
//            } catch {
//                print("Error encoding location: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func downloadLocations(types: [String], currentLocation: CLLocationCoordinate2D, completion: @escaping ([Location]?) -> Void) {
        isLoading = true
        
        let geoHashPairs = GeoHashUtils.geoHashUtils.queryBoundsForLocation(location: currentLocation, radius: 500)
        
        let queries = geoHashPairs.map { bound -> Query in
            return db.collection("locations")
                .whereField("primaryTypeID", in: types.map({ $0 }))
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        // Alle Queries parallel ausführen und Ergebnisse zusammenführen
        var allLocations: [Location] = []
        let group = DispatchGroup()

        for query in queries {
            group.enter()
            query.getDocuments { snapshot, error in
                defer { group.leave() } // Sicherstellen, dass die Gruppe verlassen wird
                
                if let error = error {
                    print("Error downloading locations: \(error.localizedDescription)")
                    return
                }

                for document in snapshot?.documents ?? [] {
                    do {
                        let location = try document.data(as: Location.self)
                        allLocations.append(location)
                    } catch {
                        print("Error decoding location: \(error.localizedDescription)")
                        self.isLoading = false
                    }
                }
            }
        }

        // Abschluss-Handler nach allen Requests aufrufen
        group.notify(queue: .main) {
            self.isLoading = false
            
            // Sortieren der Standorte nach Entfernung zu currentLocation
            allLocations.sort { loc1, loc2 in
                let coord1 = CLLocation(latitude: loc1.latitude, longitude: loc1.longitude)
                let coord2 = CLLocation(latitude: loc2.latitude, longitude: loc2.longitude)
                let current = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                
                return coord1.distance(from: current) < coord2.distance(from: current)
            }
            
            completion(allLocations)
        }
    }
    
    func downloadLocationTypes() async -> [LocationType]? {
        
        do {
            let snapshot = try await db.collection("locationTypes").getDocuments()
            
            var locationTypes: [LocationType] = []
            
            for document in snapshot.documents {
                do {
                    let locationType = try document.data(as: LocationType.self)
                    locationTypes.append(locationType)
                } catch {
                    print("Error decoding location type: \(error.localizedDescription)")
                }
            }
            
            return locationTypes
        } catch {
            print("Error downloading location types: \(error.localizedDescription)")
            return nil
        }
    }

}
