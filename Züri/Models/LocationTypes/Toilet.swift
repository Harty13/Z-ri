//
//  Toilet.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import FirebaseFirestore
import MapKit

struct Toilet: Location, Identifiable {
    @DocumentID var id: String?
    let type: LocationType = .wc
    var data: LocationData
    
    var price: String?
    
    init(data: LocationData, price: String? = nil) {
        self.data = data
        self.price = price
    }
    
    init(coordinates: CLLocationCoordinate2D, name: String, price: String? = nil, tags: [String] = [], imageUrls: [String] = [], isPublic: Bool = true) {
        self.data = LocationData(coordinates: coordinates, name: name, tags: tags, imageUrls: imageUrls, isPublic: isPublic)
        self.price = price
    }
}