//
//  Swifty360PlayerView.swift
//  Reverse
//
//  Created by Damien on 2025/7/25.
//

import SwiftUI
import AVKit
import Swifty360Player

struct Swifty360PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> Swifty360View {
        let motion = Swifty360MotionManager.shared
        let view = Swifty360View(withFrame: .zero, player: player, motionManager: motion)
        view.setup(player: player, motionManager: motion)
        return view
    }

    func updateUIView(_ uiView: Swifty360View, context: Context) {
        
    }
}

struct Swifty360LoopPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> Swifty360View {
        let motion = Swifty360MotionManager.shared
        let view = Swifty360View(withFrame: .zero, player: player, motionManager: motion)
        view.setup(player: player, motionManager: motion)
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        return view
    }
    
    func updateUIView(_ uiView: Swifty360View, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(player: player)
    }
    
    class Coordinator {
        var player: AVPlayer
        
        init(player: AVPlayer) {
            self.player = player
        }
        
        @objc func playerDidFinishPlaying() {
            player.seek(to: .zero)
            player.play()
        }
    }
}
//#Preview {
//    Swifty360PlayerView()
//}
