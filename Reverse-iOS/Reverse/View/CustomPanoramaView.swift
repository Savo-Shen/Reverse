//
//  CustomPanoramaView.swift
//  Reverse
//
//  Created by Damien on 2025/7/25.
//

import SwiftUI
import PhotosUI
import SwiftUIPanoramaViewer

struct CustomPanoramaView: View {
    @StateObject private var viewModel = CustomPanoramaViewModel()
    @StateObject private var effectManager = EffectManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var gradientRotation: Double = 0
    @State private var buttonGradientRotation: Double = 0
    @State private var deviceCornerRadius: CGFloat = 0.0
    @State private var rainBowBlurLineWidth: CGFloat = 16.0
    @State private var rainBowLineWidth: CGFloat = 8.0
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    Color("BackgroundColor")
                        .ignoresSafeArea()
                    
                    if viewModel.showPanorama && viewModel.panoramaImage != nil {
                        // 显示生成的全景图
                        PhotoView(panoramaImage: viewModel.panoramaImage!)
                    } else {
                        // 图片选择和上传界面
                        VStack(spacing: 30) {
                            Text("创建全景图")
                                .font(.system(.largeTitle, design: .rounded, weight: .black))
                                .foregroundColor(Color("ButtonColor"))
                                .padding(.top, 50)
                            
                            Text("请选择8张图片")
                                .font(.system(.title2, design: .rounded, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            // 图片网格
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                                ForEach(0..<8, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .aspectRatio(1, contentMode: .fit)
                                        .overlay {
                                            if index < viewModel.selectedImages.count {
                                                Image(uiImage: viewModel.selectedImages[index])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            } else {
                                                Image(systemName: "plus")
                                                    .font(.title)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 20) {
                                // 选择图片按钮
                                PhotosPicker(
                                    selection: $viewModel.photoPickerItems,
                                    maxSelectionCount: 8,
                                    matching: .images
                                ) {
                                    Text("选择图片")
                                        .font(.system(.title3, design: .rounded, weight: .medium))
                                        .padding()
                                        .foregroundStyle(.black)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    AngularGradient(
                                                        colors: [
                                                            .red, .orange, .yellow, .green,
                                                            .mint, .cyan, .blue, .indigo,
                                                            .purple, .pink, .red
                                                        ],
                                                        center: .center,
                                                        angle: .degrees(buttonGradientRotation)
                                                    )
                                                )
                                        )
                                        .shadow(radius: 10)
                                }
                                .disabled(viewModel.isLoading)
                                
                                // 生成全景图按钮
                                Button {
                                    effectManager.triggerHaptic(.medium)
                                    Task {
                                        await viewModel.uploadImages()
                                    }
                                } label: {
                                    Text("生成全景图")
                                        .font(.system(.title3, design: .rounded, weight: .medium))
                                        .padding()
                                        .foregroundStyle(.black)
                                        .background(Color("ButtonColor"))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(radius: 10)
                                }
                                .disabled(viewModel.selectedImages.count != 8 || viewModel.isLoading)
                                .opacity(viewModel.selectedImages.count == 8 ? 1.0 : 0.5)
                            }
                            
                            // 进度条
                            if viewModel.isLoading {
                                VStack {
                                    Text("正在生成全景图...")
                                        .foregroundColor(Color("ButtonColor"))
                                        .font(.system(.title2, design: .rounded, weight: .medium))
                                    
                                    ProgressView(value: viewModel.uploadProgress)
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .accentColor(Color("ButtonColor"))
                                        .padding(.horizontal)
                                }
                            }
                            
                            // 错误信息
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // 返回按钮
                    HStack {
                        Button(action: {
                            if viewModel.showPanorama {
                                viewModel.showPanorama = false
                            } else {
                                dismiss()
                            }
                            effectManager.stopAllEffects()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.black)
                                .padding(10)
                        }
                        .tint(Color("ButtonColor"))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .opacity(0.8)
                        .padding()
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.top, 30)
                    
                    // 加载时的炫光边框
                    if viewModel.isLoading {
                        RoundedRectangle(cornerRadius: deviceCornerRadius)
                            .stroke(
                                AngularGradient(
                                    colors: [.red, .orange, .yellow, .green, .mint, .cyan, .blue, .indigo, .purple, .pink, .red],
                                    center: .center,
                                    angle: .degrees(gradientRotation)
                                ),
                                lineWidth: rainBowBlurLineWidth
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .blur(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: deviceCornerRadius)
                                    .stroke(
                                        AngularGradient(
                                            colors: [.red, .orange, .yellow, .green, .mint, .cyan, .blue, .indigo, .purple, .pink, .red],
                                            center: .center,
                                            angle: .degrees(gradientRotation + 180)
                                        ),
                                        lineWidth: rainBowLineWidth
                                    )
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            )
                    }
                }
                .onChange(of: viewModel.photoPickerItems) { _, _ in
                    Task {
                        await viewModel.loadSelectedImages()
                    }
                }
                .onChange(of: viewModel.isLoading) { _, value in
                    if value {
                        gradientRotation = 0
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                            gradientRotation = 360
                        }
                        rainBowLineWidthAnimation()
                    } else {
                        effectManager.stopAllEffects()
                    }
                }
                .onAppear {
                    deviceCornerRadius = UIScreen.main.displayCornerRadius
                    buttonGradientRotation = 0
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        buttonGradientRotation = 360
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden()
    }
    
    private func rainBowLineWidthAnimation() {
        rainBowBlurLineWidth = 16.0
        rainBowLineWidth = 8.0
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            rainBowBlurLineWidth = 32.0
            rainBowLineWidth = 16.0
        }
    }
}

#Preview {
    CustomPanoramaView()
}
