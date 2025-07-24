//
//  ImmersiveView.swift
//  Reverse
//
//  Created by 沈逸帆 on 2025/7/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVKit

struct ImmersiveView: View {
    @ObservedObject var manager = ReverseManager.shared
    @State private var showVideo = false

    var body: some View {
        RealityView { content in
            Task {
                if showVideo {
                    if let videoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4") {
                         manager.entity.addSkyboxVideo(from: videoURL)
                    } else {
                        print("未找到视频文件")
                    }
                } else {
                    if manager.isCustomPanorama {
                        
                    } else {
                        let bgList = [
                            "bg1",
    //                        "bg3"
                        ]
                        if let bgName = bgList.randomElement() {
                            Task {
    //                            print(bgName)
                                await manager.entity.addLocalSkyboxImage(from: bgName)
                            }
                        }
                    }
                    
                }
            }
            content.add(manager.entity)
        }
        .transition(.opacity)
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Button(showVideo ? "显示图片" : "播放视频") {
                        showVideo.toggle()
                    }
                    .padding()
                }
            }
        )
    }
}

extension Entity {
    func addSkyboxImage(from urlString: String? = nil, sid: String = "", year: Int = 2019) async {
        let texture = await SkyboxLoader.loadTexture(city: sid, year: year)
        guard let texture else {
            print("Texture not loaded!")
            return
        }
        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))
        self.components.set(ModelComponent(
            mesh: .generateSphere(radius: 5),
            materials: [material])
        )
    }
    func updateSkyboxImage(from texture: TextureResource) {
        print("hdm update ")
        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))
        self.components.set(ModelComponent(
            mesh: .generateSphere(radius: 5),
            materials: [material])
        )
    }
    func addSkyboxVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let material = VideoMaterial(avPlayer: player)
        self.components.set(ModelComponent(
            mesh: .generateSphere(radius: 5),
            materials: [material])
        )
        player.play()
    }
    func addLocalSkyboxImage(from url: String) async {
        let texture = await SkyboxLoader.loadLocalTexture(bgUrl: url)
        guard let texture else {
            print("Texture not loaded!")
            return
        }
        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))
        self.components.set(ModelComponent(
            mesh: .generateSphere(radius: 5),
            materials: [material])
        )
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
