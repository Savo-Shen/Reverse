//
//  ContentView.swift
//  Reverse
//
//  Created by 沈逸帆 on 2025/7/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @ObservedObject var manager = ReverseManager.shared
    
    
    var body: some View {
        ZStack {
            VStack {
                if appModel.immersiveSpaceState == .open && !manager.isCustomPanorama {
                    RecommendSceneryView()
                }
                else if appModel.compositeViewState == .open {
                    CompositeImagesView()
                        
                } else {
                    HStack {
                        Spacer()
                        ToggleImmersiveSpaceButton()
                        Spacer()
                        ToggleCompositeViewButton()
                        Spacer()
                    }
                    
                }

            }
        }
    }
    
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
