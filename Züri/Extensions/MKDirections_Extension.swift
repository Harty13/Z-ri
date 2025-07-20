//
//  MKDirections_Extension.swift
//  Züri
//
//  Created by Erik Schnell on 16.03.2025.
//

import MapKit

extension MKDirections {
    static func calculate(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) async -> MKDirections.Response? {
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        directionsRequest.requestsAlternateRoutes = false
        directionsRequest.transportType = .walking
        let directions = MKDirections(request: directionsRequest)
        do {
            let response = try await directions.calculate()
            return response
        } catch {
            return nil
        }
    }
}
