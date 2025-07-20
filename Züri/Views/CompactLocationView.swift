//
//  CompactLocationView.swift
//  Züri
//
//  Created by Erik Schnell on 02.04.2025.
//

import SwiftUI
import MapKit

struct CompactLocationView: View {
    var location: Location
    var type: LocationType?
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let type {
                    HStack {
                        Image(systemName: type.systemImageName)
                            .font(.system(size: 8))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Circle().fill(type.tint))
                        Text(type.title)
                            .font(.body.weight(.black).width(.expanded))
                    }
                }
                if let name = location.name {
                    Text(name)
                        .fontWeight(.bold)
                }
                if let description = location.description {
                    Text(description)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                if let locationDescription = location.locationDescription {
                    Text(locationDescription)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                if let isOperational = location.isOperational {
                    HStack {
                        Circle()
                            .frame(width: 12, height: 12)
                        Text(isOperational ? "Wasser lauft" : "Wasser lauft nöd")
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(isOperational ? .green : .red)
                }
            }
            Spacer()
            
            Button(action: {
                openInAppleMaps(name: location.primaryType?.title ?? "", coordinate: location.coordinate)
            }) {
                VStack {
                    Image(systemName: "figure.walk")
                    if let travelTime = location.directions?.routes.first?.expectedTravelTime {
                        Text(travelTime.formattedAsHoursAndMinutes())
                    } else {
                        Text("1 mins")
                            .redacted(reason: .placeholder)
                    }
                }
                .font(.system(size: 14).bold())
                .padding(8)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    func openInAppleMaps(name: String, coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        // Optional: Set a name for the location in Maps (e.g., "Destination")
        mapItem.name = name
        
        // Open the map item in Apple Maps
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking // Set default to walking directions
        ])
    }
}
