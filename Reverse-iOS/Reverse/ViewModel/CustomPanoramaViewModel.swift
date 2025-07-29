//
//  CustomPanoramaViewModel.swift
//  Reverse
//
//  Created by Damien on 2025/7/25.
//

import Foundation
import SwiftUI
import PhotosUI

class CustomPanoramaViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var panoramaImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var uploadProgress: Double = 0.0
    @Published var showPanorama: Bool = false
    
    private let urlSession = URLSession.shared
    private let maxImages = 8
    
    func loadSelectedImages() async {
        selectedImages.removeAll()
        
        for item in photoPickerItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImages.append(image)
                }
            }
        }
    }
    
    func uploadImages() async {
        guard selectedImages.count == maxImages else {
            await MainActor.run {
                errorMessage = "请选择\(maxImages)张图片"
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            uploadProgress = 0.0
        }
        
        guard let url = URL(string: "\(baseURL)/composite_image") else {
            await MainActor.run {
                errorMessage = "无效的URL"
                isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = createMultipartBody(boundary: boundary, images: selectedImages)
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                await MainActor.run {
                    errorMessage = "网络请求失败"
                    isLoading = false
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                await MainActor.run {
                    errorMessage = "全景图解析失败"
                    isLoading = false
                }
                return
            }
            
            await MainActor.run {
                panoramaImage = image
                showPanorama = true
                isLoading = false
                uploadProgress = 1.0
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "上传失败: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func createMultipartBody(boundary: String, images: [UIImage]) -> Data {
        var body = Data()
        
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    func reset() {
        selectedImages.removeAll()
        photoPickerItems.removeAll()
        panoramaImage = nil
        errorMessage = nil
        uploadProgress = 0.0
        showPanorama = false
    }
}
