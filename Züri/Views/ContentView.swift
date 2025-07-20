//
//  ContentView.swift
//  Züri
//
//  Created by Erik Schnell on 12.03.2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var firebaseAPI = FirebaseAPI()
    @StateObject var mapManager = MapManager()
    
//    @State private var position: MapCameraPosition = .region(MKCoordinateRegion.zürichRegion)
//    @State var lastMapCameraState: MapCamera? = nil
//    @State var currentMapCameraState: MapCamera? = nil
    
    @State var locations: [Location] = []
    @State var locationTypes: [LocationType] = []
    
    
    @State var selectedLocation: Location? = nil
    @State var selectedLocationSheetIsPresented = false
    @State var limmatTemperature: WeatherAPI.LimmatTemperature? = nil
    
    @State var selectedLocationTypeIDsFilters: [String] = []
    
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
            .task {
                locationTypes = await firebaseAPI.downloadLocationTypes() ?? []
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
                    ForEach(locations, id: \.self) { location in
                        CompactLocationView(
                            location: location,
                            type: locationTypes.first(where: { $0.locationTypeID == location.primaryTypeID })
                        )
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
                        if let locationTypeID = selectedLocationTypeIDsFilters.first, let locationType = locationTypes.first(where: { $0.locationTypeID == locationTypeID }) {
                            Text(locationType.title)
                                .font(.title.weight(.black).width(.expanded))
                            
                            Spacer()
                            XButton {
                                selectedLocationTypeIDsFilters = []
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
                    .waveEffect(isLoading: firebaseAPI.isLoading)
                    .sensoryFeedback(.success, trigger: firebaseAPI.isLoading == false)
            
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
                if selectedLocationTypeIDsFilters.isEmpty {
                    Text("Was suechsch?")
                        .font(.title.weight(.black).width(.expanded))
                        .foregroundStyle(.primary)
                    Spacer()
                    
                } else {
                    if let locationTypeID = selectedLocationTypeIDsFilters.first, let locationType = locationTypes.first(where: { $0.locationTypeID == locationTypeID }) {
                        Text(locationType.title)
                            .font(.title.weight(.black).width(.expanded))
                        
                        Spacer()
                        XButton {
                            selectedLocationTypeIDsFilters = []
                            locations = []
                            selectedLocation = nil
                        }
                    }
                }


            }
            .padding(.horizontal)
            
            if selectedLocationTypeIDsFilters.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(locationTypes, id: \.locationTypeID) { locationType in
                            Button(action: {
                                if selectedLocationTypeIDsFilters.contains(locationType.locationTypeID) {
                                    selectedLocationTypeIDsFilters = []
                                    self.locations = []
                                    
                                } else {
                                    selectedLocationTypeIDsFilters = [locationType.locationTypeID]
                                    
                                    guard let userLocation = mapManager.location else { return }
                                    firebaseAPI.downloadLocations(types: selectedLocationTypeIDsFilters, currentLocation: userLocation.coordinate, completion: { locations in
                                        self.locations = locations ?? []
                                        self.selectedLocation = self.locations.first
                                        mapManager.zoomToLocations(locations: Array(self.locations.prefix(3)))
                                    })
                                }
                                
                            }) {
                                Text("\(locationType.emoji) \(locationType.title)")
                                    .fontWeight(.bold)
                                    .padding(12)
                                    .background(selectedLocationTypeIDsFilters.contains(locationType.locationTypeID) ? .thickMaterial : .thinMaterial)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().strokeBorder(
                                            selectedLocationTypeIDsFilters.contains(locationType.locationTypeID) ? .blue : .primary.opacity(0.5),
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
                        ForEach(locations, id: \.self) { location in
                            CompactLocationView(
                                location: location,
                                type: locationTypes.first(where: { $0.locationTypeID == location.primaryTypeID })
                            )
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
