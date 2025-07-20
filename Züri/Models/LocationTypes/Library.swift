//
//  Library.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import FirebaseFirestore
import MapKit

struct Library: Location, Identifiable {
    @DocumentID var id: String?
    let type: LocationType = .bibliothek
    var data: LocationData
    
    init(data: LocationData) {
        self.data = data
    }
    
    init(coordinates: CLLocationCoordinate2D, name: String, tags: [String] = [], imageUrls: [String] = [], isPublic: Bool = true) {
        self.data = LocationData(coordinates: coordinates, name: name, tags: tags, imageUrls: imageUrls, isPublic: isPublic)
    }
}