//
//  LocationMarkerView.swift
//  Züri
//
//  Created by Erik Schnell on 22.03.2025.
//

import SwiftUI
import MapKit

struct LocationMarkerView: MapContent {
    var location: Location

    var body: some MapContent {
        Marker("", systemImage: location.primaryType?.systemImageName ?? "", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            .tint(location.primaryType?.tint ?? .blue)
            .tag(location)
    }
}
