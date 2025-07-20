//
//  LocationData.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import MapKit
import GeohashKit

struct LocationData: Codable {
    var coordinates: CLLocationCoordinate2D
    var geohash: String
    var name: String
    var tags: [String]
    var imageUrls: [String]
    var isPublic: Bool
    
    init(coordinates: CLLocationCoordinate2D,
         name: String,
         tags: [String] = [],
         imageUrls: [String] = [],
         isPublic: Bool = true) {
        self.coordinates = coordinates
        self.geohash = Geohash.encode(latitude: coordinates.latitude, longitude: coordinates.longitude, precision: 12)
        self.name = name
        self.tags = tags
        self.imageUrls = imageUrls
        self.isPublic = isPublic
    }
}