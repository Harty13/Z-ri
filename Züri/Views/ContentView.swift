//
//  ContentView.swift
//  Züri
//
//  Created by Erik Schnell on 12.03.2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationService = LocationService.shared
    @StateObject var mapManager = MapManager()
    
    @State var locations: [any Location] = []
    @State var selectedLocationTypes: [LocationType] = []
    
    @State var selectedLocation: (any Location)? = nil
    @State var selectedLocationSheetIsPresented = false
    @State var limmatTemperature: WeatherAPI.LimmatTemperature? = nil
    
    @State private var currentMapCameraDistance: Double = 1
    
    @Namespace var mapScope

    var body: some View {
        ZStack {
            Map(position: $mapManager.cameraPosition, selection: $selectedLocation, scope: mapScope) {
                ForEach(locations) { location in
                    LocationMarkerView(location: location)
                }
                
                if let directionsPolyline = selectedLocation?.directions?.routes.first?.polyline {
                    MapPolyline(directionsPolyline)
                        .stroke(.blue, style: .directions)
                }
                
                MapPolyline(coordinates: CLLocationCoordinate2D.zürichBounds)
                    .stroke(.blue, style: .cityBounds)
                
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
            .mapControlVisibility(.hidden)
            .onMapCameraChange(mapManager.onMapCameraChange)
            .mapScope(mapScope)
            .animation(.easeInOut(duration: 0.2), value: mapManager.cameraPosition.camera?.centerCoordinate.latitude)
            .animation(.default, value: selectedLocation)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    mapManager.zoomToUser()
                }
            }
            .onChange(of: selectedLocation?.id) {
                if let selectedLocation {
                    mapManager.zoomToLocation(location: selectedLocation)
                    // Request route
                    DispatchQueue.main.async {
                        Task {
                            guard let userCoordinate = mapManager.location?.coordinate else { return }
                            let directions = await MKDirections.calculate(
                                sourceCoordinate: userCoordinate,
                                destinationCoordinate: selectedLocation.coordinate
                            )
                            
                            self.selectedLocation?.directions = directions
                            if let index = self.locations.firstIndex(of: selectedLocation) {
                                self.locations[index].directions = directions
                            }
                        }
                    }
                    
                } else {
                    mapManager.zoomToBeforeSelection()
                }
            }
            
//            VStack {
//                Spacer()
//                MapUserLocationButton(scope: mapScope)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                    .padding()
//            }
            
//            VerticalMapSlider(value: $currentMapCameraDistance)
//                .onChange(of: currentMapCameraDistance) {
//                    if let centerCoordinate = mapManager.currentMapCameraState?.centerCoordinate {
//                        mapManager.cameraPosition = .camera(MapCamera(centerCoordinate: centerCoordinate, distance: currentMapCameraDistance * 10000, pitch: 40))
//                    }
//                }
            
        }
        .safeAreaInset(edge: .top) {
            topBar
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                .background(
                    VariableBlurView(maxBlurRadius: 15, direction: .blurredTopClearBottom)
                        .ignoresSafeArea(edges: [.top, .horizontal])
            )

        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
//                .animation(.default, value: selectedLocation)
            .padding(.top)
            .background(
                VariableBlurView(maxBlurRadius: 15, direction: .blurredBottomClearTop)
                    .ignoresSafeArea(edges: [.bottom, .horizontal])
            )
        }
        .sheet(isPresented: .constant(true)) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(locations, id: \.id) { location in
                        CompactLocationView(location: location)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.thinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 8)
                        )
                        .padding()
//                        .containerRelativeFrame(.vertical, alignment: .top)
                    }
                }
                .presentationDetents([.height(300)])
                .presentationBackgroundInteraction(.enabled)
                .presentationBackground(.ultraThinMaterial)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $selectedLocation)
            .safeAreaInset(edge: .top) {
                VStack(spacing: 8) {
                    HStack {
                        if let locationType = selectedLocationTypes.first {
                            Text(locationType.title)
                                .font(.title.weight(.black).width(.expanded))
                            
                            Spacer()
                            XButton {
                                selectedLocationTypes = []
                                locations = []
                                selectedLocation = nil
                            }
                        }
                    }
                    Divider()
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .background(.thinMaterial)
            }
        }
        .animation(.default, value: selectedLocation)
        .sheet(isPresented: $selectedLocationSheetIsPresented, onDismiss: {
            selectedLocation = nil
        }) {
            if let location = selectedLocation {
                LocationSheetView(location: location)
                    .id(location)
                    .presentationDetents([.height(300), .large])
                    .presentationBackgroundInteraction(.enabled)
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
    
    var topBar: some View {
        VStack(alignment: .leading) {
                Text("Züri.")
                    .font(.largeTitle.weight(.black).width(.expanded))
                    .waveEffect(isLoading: locationService.isLoading)
                    .sensoryFeedback(.success, trigger: locationService.isLoading == false)
            
            HStack {
                Image(systemName: "water.waves")
                    .foregroundStyle(.blue)
                
                if let limmatTemperature {
                    Text("\(limmatTemperature.temperature, specifier: "%.1f")°C")
                        
                } else {
                    Text("\(10.0, specifier: "%.1f")°C")
                        .redacted(reason: .placeholder)
                }
            }
            .font(.system(size: 16, weight: .black))
            .onAppear {
                Task {
                    limmatTemperature = await WeatherAPI().limmatTemp()
                }
            }
        }
    }
    
    var bottomBar: some View {
        VStack(alignment: .leading) {
            HStack {
                if selectedLocationTypes.isEmpty {
                    Text("Was suechsch?")
                        .font(.title.weight(.black).width(.expanded))
                        .foregroundStyle(.primary)
                    Spacer()
                    
                } else {
                    if let locationType = selectedLocationTypes.first {
                        Text(locationType.title)
                            .font(.title.weight(.black).width(.expanded))
                        
                        Spacer()
                        XButton {
                            selectedLocationTypes = []
                            locations = []
                            selectedLocation = nil
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            if selectedLocationTypes.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(LocationType.allCases, id: \.self) { locationType in
                            Button(action: {
                                if selectedLocationTypes.contains(locationType) {
                                    selectedLocationTypes = []
                                    self.locations = []
                                    
                                } else {
                                    selectedLocationTypes = [locationType]
                                    
                                    guard let userLocation = mapManager.location else { return }
                                    
                                    Task {
                                        do {
                                            let fetchedLocations = try await locationService.fetchLocations(
                                                ofType: locationType,
                                                nearCoordinate: userLocation.coordinate
                                            )
                                            
                                            await MainActor.run {
                                                self.locations = fetchedLocations
                                                self.selectedLocation = self.locations.first
                                                mapManager.zoomToLocations(locations: Array(self.locations.prefix(3)))
                                            }
                                        } catch {
                                            print("Error fetching locations: \(error)")
                                        }
                                    }
                                }
                                
                            }) {
                                Text("\(locationType.emoji) \(locationType.title)")
                                    .fontWeight(.bold)
                                    .padding(12)
                                    .background(selectedLocationTypes.contains(locationType) ? .thickMaterial : .thinMaterial)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().strokeBorder(
                                            selectedLocationTypes.contains(locationType) ? .blue : .primary.opacity(0.5),
                                            lineWidth: 3
                                        )
                                    )
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 2)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.horizontal)
                    .padding(.horizontal, -2)
                }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(locations, id: \.id) { location in
                            CompactLocationView(location: location)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.thinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 8)
                            )
                            .padding()
                            .containerRelativeFrame(.horizontal, alignment: .center)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .scrollPosition(id: $selectedLocation)
            }
            Spacer()
        }
        .frame(height: 200)
    }
}

extension CLLocationCoordinate2D {
    static let zurichCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 47.425, longitude: 8.48),
        CLLocationCoordinate2D(latitude: 47.42, longitude: 8.57),
        CLLocationCoordinate2D(latitude: 47.35, longitude: 8.57),
        CLLocationCoordinate2D(latitude: 47.35, longitude: 8.48),
        CLLocationCoordinate2D(latitude: 47.425, longitude: 8.48) // Schließt das Polygon
    ]
}



#Preview {
    ContentView()
}
