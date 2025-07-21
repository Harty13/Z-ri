//
//  CompactLocationView.swift
//  Züri
//
//  Created by Erik Schnell on 02.04.2025.
//

import SwiftUI
import MapKit

struct CompactLocationView: View {
    var location: any Location
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: location.type.systemImageName)
                        .font(.system(size: 8))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Circle().fill(location.type.tint))
                    Text(location.type.title)
                        .font(.body.weight(.black).width(.expanded))
                }
                
                Text(location.name)
                    .fontWeight(.bold)
                
                if !location.tags.isEmpty {
                    Text(location.tags.first ?? "")
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                
                // Show pricing for toilets
                if let toilet = location as? Toilet, let price = toilet.price {
                    HStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(price == "Free" ? .green : .orange)
                        Text(price)
                            .fontWeight(.bold)
                            .foregroundStyle(price == "Free" ? .green : .orange)
                    }
                }
            }
            Spacer()
            
            Button(action: {
                openInAppleMaps(name: location.name, coordinate: location.coordinate)
            }) {
                VStack {
                    Image(systemName: "figure.walk")
                    Text("1 mins")
                        .redacted(reason: .placeholder)
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
