//
//  AppModel.swift
//  Reverse
//
//  Created by 沈逸帆 on 2025/7/24.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    enum CompositeViewState {
        case closed
        case inTransition
        case open
    }
    var compositeViewState = CompositeViewState.closed
    
}
