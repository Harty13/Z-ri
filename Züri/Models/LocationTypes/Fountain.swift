//
//  Fountain.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import FirebaseFirestore
import MapKit

struct Fountain: Location, Identifiable {
    @DocumentID var id: String?
    let type: LocationType = .brunnen
    var data: LocationData
    
    init(data: LocationData) {
        self.data = data
    }
    
    init(coordinates: CLLocationCoordinate2D, name: String, tags: [String] = [], imageUrls: [String] = [], isPublic: Bool = true) {
        self.data = LocationData(coordinates: coordinates, name: name, tags: tags, imageUrls: imageUrls, isPublic: isPublic)
    }
}