//
//  LocationMarkerView.swift
//  Züri
//
//  Created by Erik Schnell on 22.03.2025.
//

import SwiftUI
import MapKit

struct LocationMarkerView: MapContent {
    var location: any Location

    var body: some MapContent {
        Marker("", systemImage: location.type.systemImageName, coordinate: location.coordinates)
            .tint(location.type.tint)
            .tag(AnyHashable(location.id))
    }
}
