//
//  ValueMonitor.swift
//  Reverse
//
//  Created by Damien on 2025/7/26.
//

import Foundation

class ValueMonitor: ObservableObject {
    
    static let shared = ValueMonitor()
    
    @Published var locationChangeTrigger: Int = 0
}
