//
//  MKCoordinateRegion_Extension.swift
//  Züri
//
//  Created by Erik Schnell on 15.03.2025.
//

import MapKit

extension MKCoordinateRegion {
    static var zürichRegion = MKCoordinateRegion(
        center: .zürichCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
    )
    
    static func forCoordinates(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let minLat = min(coord1.latitude, coord2.latitude)
        let maxLat = max(coord1.latitude, coord2.latitude)
        let minLon = min(coord1.longitude, coord2.longitude)
        let maxLon = max(coord1.longitude, coord2.longitude)
        
        // Calculate the center for longitude (no change)
        let centerLon = (minLon + maxLon) / 2
        
        // Calculate the center for latitude and shift it upwards
        let centerLat = (minLat + maxLat) / 2 - (maxLat - minLat) / 2 // Move it upwards
        
        let center = CLLocationCoordinate2D(
            latitude: centerLat,
            longitude: centerLon
        )
        
        // Adjust the latitude span by halving it to make it more squeezed vertically
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 2.5, // Squeeze the vertical span by 50%
            longitudeDelta: (maxLon - minLon) * 1.5 // Keep the horizontal padding
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    static func centerAndDistanceforCoordinates(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> (centerCoordinate: CLLocationCoordinate2D, distance: CLLocationDistance) {
        let minLat = min(coord1.latitude, coord2.latitude)
        let maxLat = max(coord1.latitude, coord2.latitude)
        let minLon = min(coord1.longitude, coord2.longitude)
        let maxLon = max(coord1.longitude, coord2.longitude)
        
        // Calculate the center for longitude (no change)
        let centerLon = (minLon + maxLon) / 2
        
        // Calculate the center for latitude and shift it upwards
        let centerLat = (minLat + maxLat) / 2 - (maxLat - minLat) / 2 // Move it upwards
        
        let center = CLLocationCoordinate2D(
            latitude: centerLat,
            longitude: centerLon
        )
        
        // Calculate the distance in meters between the two coordinates
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        let distance = location1.distance(from: location2)  // Distance in meters
        
        // Adjust the span to make sure the entire region fits on the map
//        let latitudeDelta = distance / 111000.0 // Convert meters to degrees (approx. 1 degree latitude ≈ 111 km)
//        let longitudeDelta = (maxLon - minLon) * (latitudeDelta / (maxLat - minLat))
//        
//        let span = MKCoordinateSpan(
//            latitudeDelta: latitudeDelta,
//            longitudeDelta: longitudeDelta
//        )
//        
        return (centerCoordinate: center, distance: distance*5)
    }

}
