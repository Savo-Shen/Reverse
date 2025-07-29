//
//  MapView.swift
//  Reverse
//
//  Created by Damien on 2025/7/26.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = .hybrid
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.updateMapView(uiView, coordinate: selectedCoordinate)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        weak var mapView: MKMapView?
        private var currentAnnotation: MKPointAnnotation?
        
        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }
        
        func updateMapView(_ mapView: MKMapView, coordinate: CLLocationCoordinate2D?) {
            mapView.delegate = self
            
            if let annotation = currentAnnotation {
                mapView.removeAnnotation(annotation)
            }
            
            guard let coordinate = coordinate else { return }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "选中位置"
            mapView.addAnnotation(annotation)
            currentAnnotation = annotation
            
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = mapView else { return }
            let location = gesture.location(in: mapView)

            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            parent.selectedCoordinate = coordinate
            print("📍 点击坐标：\(coordinate.latitude), \(coordinate.longitude)")
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "LocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.markerTintColor = .systemRed
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}

struct TapMapView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var reverseManager: ReverseManager
    @StateObject private var locationManager = LocationManager()
    @Binding var tappedCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        ZStack {
            MapView(selectedCoordinate: $tappedCoordinate)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    if let current = locationManager.currentLocation {
                        tappedCoordinate = current
                    }
                }
            
            VStack {
                Spacer()
                Button {
                    ValueMonitor.shared.locationChangeTrigger += 1
                } label: {
                    Text("跃迁")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .foregroundStyle(.black)
                        .background(
                            LinearGradient(
                                colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color("ButtonColor").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                if reverseManager.mapViewModel.videoGenerateStatus == .videoReady {
                    Button {
                        tappedCoordinate?.latitude = reverseManager.savedLatitude
                        tappedCoordinate?.longitude = reverseManager.savedLongitude
                        ValueMonitor.shared.locationChangeTrigger += 1
                    } label: {
                        Text("回到之前的位置")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .foregroundStyle(.black)
                            .background(
                                LinearGradient(
                                    colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color("ButtonColor").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }

            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if let current = locationManager.currentLocation {
                        tappedCoordinate = current
                    }
                    dismiss()
                    reverseManager.trueIsPhotoFalseIsVideo = true
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(10)
                }
                .tint(Color("ButtonColor"))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .opacity(0.8)
                .padding()
            }
        }
        .onReceive(locationManager.$currentLocation) { location in
            if let location = location, tappedCoordinate == nil {
                tappedCoordinate = location
            }
        }
        .onChange(of: tappedCoordinate?.latitude) { _, _ in
            updateCoordinates()
        }
        .onChange(of: tappedCoordinate?.longitude) { _, _ in
            updateCoordinates()
        }
        
    }
    private func updateCoordinates() {
        reverseManager.mapViewModel.lastLatitude = tappedCoordinate?.latitude ?? 0
        reverseManager.mapViewModel.lastLongitude = tappedCoordinate?.longitude ?? 0
        
    }
}

