//
//  ReverseManager.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import Foundation
import Combine

class ReverseManager: ObservableObject {
    @Published var panoramaViewModel = PanoramaViewModel()
    @Published var customPanoramaViewModel = CustomPanoramaViewModel()
    @Published var mapViewModel = MapViewModel.shared
    @Published var trueIsPhotoFalseIsVideo: Bool = true
    @Published var videoUrl: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    @Published var savedLatitude: CGFloat = 0
    @Published var savedLongitude: CGFloat = 0
    
    init() {
        self.setupBindings()
    }
    
    func setupBindings() {
        panoramaViewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        customPanoramaViewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        mapViewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
    }
    
    func togglePhotoVideo() {
        trueIsPhotoFalseIsVideo.toggle()
    }
    
    func saveGenerationLocation() {
        self.savedLatitude = mapViewModel.lastLatitude
        self.savedLongitude = mapViewModel.lastLongitude
    }
}
