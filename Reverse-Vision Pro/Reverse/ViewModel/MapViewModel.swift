//
//  ImageAI.swift
//  Reverse
//
//  Created by Damien on 2025/7/26.
//

import SwiftUI
import Foundation

class MapViewModel: ObservableObject {
    
    static let shared = MapViewModel()
    
    @Published var videoUrl: URL?
    @Published var videoGenerateStatus: VideoGenerateStatus = .idle
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var meetSomeProblem: Bool = false
    
    @Published var lastLongitude: Double = 0.0
    @Published var lastLatitude: Double = 0.0
    
    private let urlSession = URLSession.shared
    
    enum VideoGenerateStatus {
        case idle
        case waitingForVideo
        case videoReady
    }
    
    func fetchPanoramaAIVideoUrl(request: GenerateVideoRequest) async {
        isLoading = true
        errorMessage = nil
        
        guard let url = request.url else {
            errorMessage = "无效的URL"
            meetSomeProblem = true
            return
        }
        
        guard let postData = request.postData else {
            errorMessage = "无效的请求数据"
            meetSomeProblem = true
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = postData
        urlRequest.timeoutInterval = 600.0
        
        do {
            let (data, response) = try await
                urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "网络请求失败"
                meetSomeProblem = true
                return
            }
            
            if let json = try?
                JSONSerialization.jsonObject(with: data) as? [String: Any],
                let videoUrl = json["video_url"] as? String {
                self.videoUrl = URL(string: videoUrl)
                print("get\(self.videoUrl)")
                self.videoGenerateStatus = .videoReady
            }
            
            isLoading = false
            
        } catch {
            errorMessage = "请求AI视频失败: \(error.localizedDescription)"
            meetSomeProblem = true
            self.videoGenerateStatus = .idle
            print("请求AI视频失败: \(error.localizedDescription)")
        }
        
    }
    
    func fetchPanoramaAIVideoUrlSync(request: GenerateVideoRequest) {
        self.videoGenerateStatus = .waitingForVideo
        Task.detached { [weak self] in
            await self?.fetchPanoramaAIVideoUrl(request: request)
        }
    }
    
}
