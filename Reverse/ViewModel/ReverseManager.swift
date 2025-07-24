//
//  ReverseManager.swift
//  Reverse
//
//  Created by 沈逸帆 on 2025/7/24.
//

import Foundation
import RealityKit
import RealityKitContent

class ReverseManager: ObservableObject {
    static let shared = ReverseManager()
    
    @Published var entity: Entity = Entity()
    @Published var yearList: [String] = []
    @Published var sid: String = ""
    @Published var loadingYear: Bool = false
    
    @Published var isCustomPanorama = false
    
    init() {
        entity.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
        entity.scale *= .init(x: -1, y: 1, z: 1)

    }

    func getYear(sid: String , year: String) {
        self.loadingYear = true
        Task {
            await entity.addSkyboxImage(from: "http://localhost:5001/", sid: sid, year: Int(year)!)
            DispatchQueue.main.async {
                self.loadingYear = false
            }
        }
    }
}
