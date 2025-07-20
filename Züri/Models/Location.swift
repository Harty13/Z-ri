//
//  Location.swift
//  Züri
//
//  Created by Erik Schnell on 12.03.2025.
//

import Foundation
import FirebaseFirestore
import GeohashKit
import MapKit
import SwiftUI

struct Location: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String?
    var description: String?
    var address: String?
    var latitude: Double
    var longitude: Double
    var geohash: String
    var locationDescription: String?
    
    var primaryTypeID: LocationType.ID
    var secondaryTypeIDs: [LocationType.ID]?
    
    var images: [URL?]?
    var additionalInformation: String?
    
    var isFree: Bool?
    var prices: [String: Double]?
    
    var openingHours: [OpeningHour]?
    var isOperational: Bool?
    
    var isAccessible: Bool?
    var accessibilityInformation: String?
    
    var website: URL?
    var contact: String?
    
    // Init
    init(id: String? = nil,
         name: String? = nil,
         description: String? = nil,
         address: String? = nil,
         latitude: Double,
         longitude: Double,
         geohash: String,
         locationDescription: String? = nil,
         primaryTypeID: LocationType.ID,
         secondaryTypeIDs: [LocationType.ID]? = nil,
         images: [URL?]? = nil,
         additionalInformation: String? = nil,
         isFree: Bool? = nil,
         prices: [String: Double]? = nil,
         openingHours: [OpeningHour]? = nil,
         isOperational: Bool? = nil,
         isAccessible: Bool? = nil,
         accessibilityInformation: String? = nil,
         website: URL? = nil,
         contact: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.geohash = geohash
        self.locationDescription = locationDescription
        self.primaryTypeID = primaryTypeID
        self.secondaryTypeIDs = secondaryTypeIDs
        self.images = images
        self.additionalInformation = additionalInformation
        self.isFree = isFree
        self.prices = prices
        self.openingHours = openingHours
        self.isOperational = isOperational
        self.isAccessible = isAccessible
        self.accessibilityInformation = accessibilityInformation
        self.website = website
        self.contact = contact
    }
    
    // CodingKeys for Codable compliance
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case address
        case latitude
        case longitude
        case geohash
        case locationDescription
        case primaryTypeID
        case secondaryTypeIDs
        case images
        case additionalInformation
        case isFree
        case prices
        case openingHours
        case isOperational
        case isAccessible
        case accessibilityInformation
        case website
        case contact
    }
    
    var directions: MKDirections.Response? = nil
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    struct OpeningHour: Codable, Hashable {
        let day: Int    // 0=Sonntag, 1=Montag, ..., 6=Samstag
        let open: Int   // Minuten seit Mitternacht
        let close: Int  // Minuten seit Mitternacht
    }
}

extension Location {
    var primaryType: LocationType? {
        guard let primaryTypeID else { return nil }
        return LocationType.all.first(where: { $0.locationTypeID == primaryTypeID })
    }
}
