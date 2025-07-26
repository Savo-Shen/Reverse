//
//  PhotoView.swift
//  Reverse
//
//  Created by Damien on 2025/7/25.
//

import SwiftUI
import SwiftUIPanoramaViewer

struct PhotoView: View {
    @EnvironmentObject var reverseManager: ReverseManager
    let customImage: UIImage?
    
    // Marker
    @State private var currentYaw: Float = 0
    @State private var currentPitch: Float = 0
    // Motion
//    @StateObject var motionTracker = MotionTracker()
    
    init(panoramaImage: UIImage? = nil) {
        self.customImage = panoramaImage
    }
    
    
    var body: some View {
        ZStack {
            if let image = customImage ?? reverseManager.panoramaViewModel.panoramaImage {
                PanoramaViewer(
                    image: SwiftUIPanoramaViewer.bindImage(image),
                    controlMethod: .motion,
                    cameraMoved: { pitch, newYaw, roll in
                        // Marker
//                        self.currentYaw = newYaw
//                        self.currentPitch = pitch
                    }
                )
                
//                ForEach(markers) { marker in
//                    let pitchMin = normalizeTo360(marker.pitchCenter - marker.pitchRange / 2)
//                    let pitchMax = normalizeTo360(marker.pitchCenter + marker.pitchRange / 2)
//
//                    let yawMin = normalizeTo360(marker.yawCenter - marker.yawRange / 2)
//                    let yawMax = normalizeTo360(marker.yawCenter + marker.yawRange / 2)
//
//                    VStack {
//                        if fixedTargetHit(
//                            pitch: currentPitch,
//                            yaw: currentYaw,
//                            pitchLeading: pitchMax,
//                            pitchTrailing: pitchMin,
//                            yawLeading: yawMax,
//                            yawTrailing: yawMin
//                        ) {
//                            Button(action: marker.action) {
//                                Image(systemName: "mappin.circle.fill")
//                                    .font(.largeTitle)
//                                    .foregroundColor(marker.color)
//                            }
//                            .position(x: UIScreen.main.bounds.midX,
//                                      y: UIScreen.main.bounds.midY - 80)
//                        }
//                    }
//                }
                
                
            }
        }
        .ignoresSafeArea(.all)
//        .onReceive(motionTracker.$yaw) { newYaw in
//            self.currentYaw = newYaw
//        }
//        .onReceive(motionTracker.$pitch) { newPitch in
//            self.currentPitch = newPitch
//        }
    }
}

#Preview {
    PhotoView()
}
