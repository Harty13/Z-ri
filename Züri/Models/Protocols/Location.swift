//
//  Location.swift
//  Züri
//
//  Created by Erik Schnell on 20.07.2025.
//

import Foundation
import FirebaseFirestore
import MapKit

protocol Location: Codable {
    var type: LocationType { get }
    var data: LocationData { get set }
    
    var coordinates: CLLocationCoordinate2D { get }
    var geohash: String { get }
    var name: String { get }
    var tags: [String] { get }
    var imageUrls: [String] { get }
    var isPublic: Bool { get }
    var coordinate: CLLocationCoordinate2D { get }
}

extension Location {
    var coordinates: CLLocationCoordinate2D { data.coordinates }
    var geohash: String { data.geohash }
    var name: String { data.name }
    var tags: [String] { data.tags }
    var imageUrls: [String] { data.imageUrls }
    var isPublic: Bool { data.isPublic }
    var coordinate: CLLocationCoordinate2D { data.coordinates }
}