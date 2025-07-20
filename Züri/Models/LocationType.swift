//
//  LocationType.swift
//  Züri
//
//  Created by Erik Schnell on 23.03.2025.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct LocationType: Identifiable, Codable {
    @DocumentID var id: String?
    
    var locationTypeID: String
    
    var title: String
    var emoji: String
    
    var tint: Color
    var systemImageName: String
    
    // Init
    init(id: String? = nil,
         locationTypeID: String,
         title: String,
         emoji: String,
         tint: Color,
         systemImageName: String) {
        self.id = id
        self.locationTypeID = locationTypeID
        self.title = title
        self.emoji = emoji
        self.tint = tint
        self.systemImageName = systemImageName
    }
}

extension LocationType {
    static var all: [LocationType] {
        [
            LocationType(locationTypeID: "fountain", title: "Brunne", emoji: "⛲️", tint: .blue, systemImageName: "drop.fill"),
            LocationType(locationTypeID: "toilet", title: "WC", emoji: "🚽", tint: .white, systemImageName: "toilet.fill"),
        ]
    }
}
