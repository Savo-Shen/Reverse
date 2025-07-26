//
//  PanoramaViewModel.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import Foundation
import SwiftUI

class PanoramaViewModel: ObservableObject {
    @Published var panoramaImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var meetSomeProblem: Bool = false
    @Published var isShowTimeLine: Bool = false
    @Published var errorMessage: String?
    @Published var timeLine: TimeLine? = nil
    
    private let urlSession = URLSession.shared
    
    func debug() {
        self.isLoading = false
        self.isShowTimeLine = true
        self.timeLine = nil
        self.panoramaImage = UIImage(named: "Street")
    }
    
    func fetchPanoramaYear(request: PanoramaRequest) async {
        isLoading = true
        errorMessage = nil
        panoramaImage = nil
        
        guard let url = request.url else {
            errorMessage = "无效的URL"
//            isLoading = false
            meetSomeProblem = true
            return
        }
        
        guard let postData = request.postData else {
            errorMessage = "请求数据格式错误"
//            isLoading = false
            meetSomeProblem = true
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = postData
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "网络请求失败"
//                isLoading = false
                meetSomeProblem = true
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let timelineData = json["timeline"] as? [String: Any],
               let years = timelineData["years"] as? [String],
               let sid = timelineData["sid"] as? String {
                self.timeLine = TimeLine(years: years, sid: sid)
                self.isShowTimeLine = true
            }
            
            isLoading = false
            
        } catch {
            errorMessage = "获取日期失败: \(error.localizedDescription)"
//            isLoading = false
            meetSomeProblem = true
            print("获取日期失败: \(error.localizedDescription)")
        }
    }
    
    func fetchPanoramaImage(year: String, sid: String = "", fromTimeLine: Bool = true) async {
        isLoading = true
        errorMessage = nil
        panoramaImage = nil
        var nsid: String = ""
        if fromTimeLine {
            nsid = timeLine?.sid ?? ""
        } else {
            nsid = sid
        }
        
        var components = URLComponents(string: "\(baseURL)/get_image")
        components?.queryItems = [
            URLQueryItem(name: "year", value: year),
            URLQueryItem(name: "sid", value: nsid)
        ]
        
        guard let url = components?.url else {
            errorMessage = "无效的URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "网络请求失败"
                isLoading = false
                return
            }
            
            guard let image = UIImage(data: data) else {
                errorMessage = "图片解析失败"
                isLoading = false
                return
            }
            
            panoramaImage = image
            self.isShowTimeLine = false
            isLoading = false
            
        } catch {
            errorMessage = "获取全景图失败: \(error.localizedDescription)"
            isLoading = false
            print("获取全景图失败: \(error.localizedDescription)")
        }
    }
    
    func fetchPanoramaYearSync(request: PanoramaRequest) {
        Task {
            await fetchPanoramaYear(request: request)
        }
    }
    
    func fetchPanoramaImageSync(year: String) {
        Task {
            await fetchPanoramaImage(year: year)
        }
    }
}
