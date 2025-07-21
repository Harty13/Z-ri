//
//  MapManager.swift
//  Züri
//
//  Created by Erik Schnell on 22.03.2025.
//

import Foundation
import SwiftUI
import MapKit

class MapManager: CLLocationManager, ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion.zürichRegion)
    
    @Published var currentMapCameraState: MapCamera? = nil
    private var mapCameraStateBeforeSelection: MapCamera? = nil
    
    override init() {
        super.init()
        self.requestWhenInUseAuthorization()
    }
    
    func zoomToUser() {
        guard let userLocation = self.location else { return }
        let camera = MapCamera(centerCoordinate: userLocation.coordinate, distance: 2000, pitch: 40)
        cameraPosition = .camera(camera)
    }
    
    func zoomToLocation(location: any Location) {
        guard let userLocation = self.location else { return }
        
        mapCameraStateBeforeSelection = currentMapCameraState

        let (centerCoordinate, distance) = MKCoordinateRegion.centerAndDistanceforCoordinates(
            location.coordinate,
            userLocation.coordinate
        )
        
        let camera = MapCamera(centerCoordinate: centerCoordinate, distance: distance, heading: heading?.trueHeading ?? 0, pitch: 40)
        cameraPosition = .camera(camera)
    }
    
    func zoomToLocations(locations: [any Location]) {
        guard let userLocation = self.location else { return }
        
        let furthestLocationDistance = locations.map({ $0.coordinate }).map {
            userLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))

        }.max() ?? 400
        
        let camera = MapCamera(centerCoordinate: userLocation.coordinate, distance: furthestLocationDistance*2.5, pitch: 40)
        cameraPosition = .camera(camera)
    }
    
    func zoomToBeforeSelection() {
        if let camera = mapCameraStateBeforeSelection {
            cameraPosition = .camera(camera)
        }
    }
    
    
    func onMapCameraChange(context: MapCameraUpdateContext) {
        currentMapCameraState = context.camera
    }
}
