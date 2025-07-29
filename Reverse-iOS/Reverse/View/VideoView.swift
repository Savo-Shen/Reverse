//
//  VideoView.swift
//  Reverse
//
//  Created by Damien on 2025/7/25.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @EnvironmentObject var reverseManager: ReverseManager
    @StateObject private var playerWrapper = PlayerWrapper()

    var body: some View {
        Swifty360LoopPlayerView(player: playerWrapper.player)
            .onAppear {
                updatePlayer()
            }
            .onChange(of: reverseManager.videoUrl) { _, _ in
                updatePlayer()
            }
            .edgesIgnoringSafeArea(.all)
    }

    private func updatePlayer() {

        let url: URL
        print("当前所在" + reverseManager.videoUrl)

        if reverseManager.videoUrl.isEmpty,
           let mapUrl = reverseManager.mapViewModel.videoUrl {
            url = mapUrl
        } else {
            guard let bundleUrl = Bundle.main.url(forResource: reverseManager.videoUrl, withExtension: "mov") else {
                print("视频资源未找到")
                return
            }
            url = bundleUrl
        }
        
        print("视频URL: \(url)")
        
        playerWrapper.player.replaceCurrentItem(with: AVPlayerItem(url: url))
        playerWrapper.player.play()
    }
}

class PlayerWrapper: ObservableObject {
    let player = AVPlayer()
    init() { }
}



//struct VideoView: View {
//    @EnvironmentObject var reverseManager: ReverseManager
//
//    private var player: AVPlayer = {
//        guard let videoURL = Bundle.main.url(forResource: "demo", withExtension: "mp4") else {
//            fatalError("❌ 视频文件没找到")
//        }
//        return AVPlayer(url: videoURL)
//    }()
//    
//    private var player: AVPlayer {
//        guard let videoURL = Bundle.main.url(forResource: reverseManager.videoUrl , withExtension: "mp4") else {
//            fatalError("❌ 视频文件没找到")
//        }
//        return AVPlayer(url: videoURL)
//    }
//    
//    var body: some View {
////        Swifty360PlayerView(player: player)
//        Swifty360LoopPlayerView(player: player)
//            .onAppear {
//                player.play()
//            }
//            .onDisappear {
//                player.pause()
//            }
//            .edgesIgnoringSafeArea(.all)
//    }
//}

#Preview {
    VideoView()
}
