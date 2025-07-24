//
//  ToggleCompositeViewButton.swift
//  Reverse
//
//  Created by 沈逸帆 on 2025/7/25.
//


import SwiftUI
import RealityFoundation

struct ToggleCompositeViewButton: View {
    @ObservedObject var manager = ReverseManager.shared
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(AppModel.self) private var appModel
//    @EnvironmentObject var appModel: AppModel

    var body: some View {
        
        Button {
            ToggleCompositeViewState()
        } label: {
            Text(appModel.compositeViewState == .open ? "Hide Composite View" : "Composite Images View")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
    
    func ToggleCompositeViewState() {
//        appModel.compositeViewState = appModel.compositeViewState == .open ? .closed : .open
        if appModel.compositeViewState == .open {
            appModel.compositeViewState = .closed
            Task {
                await dismissImmersiveSpace()
            }
            manager.isCustomPanorama = false
        } else {
            appModel.compositeViewState = .open
            manager.isCustomPanorama = true
        }
        
        
    }
    
}

