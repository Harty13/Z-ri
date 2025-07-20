//
//  LocationSheetView.swift
//  Züri
//
//  Created by Erik Schnell on 16.03.2025.
//

import SwiftUI
import MapKit

struct LocationSheetView: View {
    var location: Location
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(location.primaryType?.title ?? "")
                    .font(.title.weight(.black).width(.expanded))
                Spacer()
                XButton(action: dismiss.callAsFunction)
            }
            VStack(alignment: .leading) {
                if let name = location.name {
                    Text(name)
                        .fontWeight(.bold)
                }
                if let description = location.description {
                    Text(description)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                openInAppleMaps(name: location.primaryType?.title ?? "", coordinate: location.coordinate)
            }) {
                HStack {
                    Image(systemName: "figure.walk")
                    if let travelTime = location.directions?.routes.first?.expectedTravelTime {
                        Text(travelTime.formattedAsHoursAndMinutes())
                    } else {
                        ProgressView()
                    }
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
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
