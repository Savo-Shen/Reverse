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
    @Published var trueIsPhotoFalseIsVideo: Bool = true
    @Published var videoUrl: String = ""
    private var cancellables = Set<AnyCancellable>()
    
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
    }
    
    func togglePhotoVideo() {
        trueIsPhotoFalseIsVideo.toggle()
    }
}
