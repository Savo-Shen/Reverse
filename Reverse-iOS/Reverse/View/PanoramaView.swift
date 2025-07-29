//
//  PanoramaView.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import SwiftUI
import UIKit
import SwiftUIPanoramaViewer

@MainActor
struct PanoramaView: View {
    @State var displayYearInfo: Bool = false
    @State private var gradientRotation: Double = 0
    @State private var buttonGradientRotation: Double = 0
    @EnvironmentObject var reverseManager: ReverseManager
    @Environment(\.dismiss) private var dismiss
    @State var deviceCornerRadius: CGFloat = 0.0
    @State var rainBowBlurLineWidth: CGFloat = 16.0
    @State var rainBowLineWidth: CGFloat = 8.0
    @StateObject private var effectManager = EffectManager.shared
    @State var selectedYear: String? = nil
    // Marker
    @State private var currentYaw: Float = 0
    @State private var currentPitch: Float = 0
    // Motion
    @StateObject var motionTracker = MotionTracker()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .top) {
                    // PanoramaV iew
                    if !reverseManager.panoramaViewModel.meetSomeProblem {
                        if reverseManager.trueIsPhotoFalseIsVideo {
                            PhotoView()
                                .environmentObject(reverseManager)
                        } else {
                            VideoView()
                                .environmentObject(reverseManager)
                        }
                    }
                    
                    VStack {
                        Spacer()
                        
                        Button {
                            if reverseManager.videoUrl == "" {
                                // If Generate Mode
                                switch reverseManager.mapViewModel.videoGenerateStatus {
                                case .idle:
                                    // 生成视频 保存坐标
                                    reverseManager.saveGenerationLocation()
                                    Task {
                                        await runGenerateAIVideo(year: selectedYear ?? "", sid: reverseManager.panoramaViewModel.timeLine?.sid ?? "")
                                    }
                                    self.reverseManager.mapViewModel.videoGenerateStatus = .waitingForVideo
                                    break
                                case .waitingForVideo:
                                    // 等待生成视频 不做任何事情
                                    break
                                case .videoReady:
                                    // 回到上一次的坐标
                                    
                                    //然后切换为当前视频并播放
                                    reverseManager.trueIsPhotoFalseIsVideo = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        
                                    }
                                }
                                
                            } else {
                                // 进入推荐视频
                                reverseManager.togglePhotoVideo()
                            }
                        } label: {
                            Section {
                                if reverseManager.videoUrl == "" {
                                    switch reverseManager.mapViewModel.videoGenerateStatus {
                                    case .idle:
                                        Text("Reverse")
                                    case .waitingForVideo:
                                        Text("Waiting")
                                    case .videoReady:
                                        Text("ReverseRE")
                                    }
                                } else {
                                    Text("ReverseCC")
                                }
                            }
                                .padding()
                                .foregroundStyle(.black)
                                .clipShape(.capsule)
                                .opacity(0.8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            AngularGradient(
                                                colors: [
                                                    .red,
                                                    .orange,
                                                    .yellow,
                                                    .green,
                                                    .mint,
                                                    .cyan,
                                                    .blue,
                                                    .indigo,
                                                    .purple,
                                                    .pink,
                                                    .red
                                                ],
                                                center: .center,
                                                angle: .degrees(buttonGradientRotation)
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.3))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            .white.opacity(0.6),
                                                            .white.opacity(0.2),
                                                            .white.opacity(0.8)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                        )
                                )
                                .foregroundColor(.white)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: buttonGradientRotation)
                                .animation(.default, value: self.selectedYear)
                        }
                        .opacity(!reverseManager.panoramaViewModel.isShowTimeLine && reverseManager.trueIsPhotoFalseIsVideo ? 1.0 : 0.0)
                        
                        if !reverseManager.panoramaViewModel.isShowTimeLine {
                            Button(action: {
                                reverseManager.panoramaViewModel.isShowTimeLine = true
                            }) {
                                Image(systemName: "chevron.up")
                                    .font(.title3)
                                    .foregroundColor(.black)
                                    .padding(10)
                            }
                            .tint(Color("ButtonColor"))
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.circle)
                            .opacity(0.8)
                            .padding()
                        }

                        Button {
                            reverseManager.mapViewModel.videoGenerateStatus = .idle
                            reverseManager.mapViewModel.videoUrl = nil
                            reverseManager.trueIsPhotoFalseIsVideo = true
                            dismiss()
                        } label: {
                            Image(systemName: "trash")
                                .font(.title3)
                                .foregroundColor(.black)
                                .padding(10)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .opacity(0.8)
                        .padding()
                        .opacity(reverseManager.mapViewModel.videoGenerateStatus == .videoReady ? 1.0 : 0.0)
                    }
                    
                    // TimeLine View
                    if let timeLine = reverseManager.panoramaViewModel.timeLine, reverseManager.panoramaViewModel.isShowTimeLine{
                        VStack {
                            HStack(spacing: 16) {
                                ForEach(0..<timeLine.years.count, id: \.self) { index in
                                    Text(timeLine.years[index])
                                        .font(.system(.title3, design: .rounded, weight: .medium))
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    AngularGradient(
                                                        colors: [
                                                            .red,
                                                            .orange,
                                                            .yellow,
                                                            .green,
                                                            .mint,
                                                            .cyan,
                                                            .blue,
                                                            .indigo,
                                                            .purple,
                                                            .pink,
                                                            .red
                                                        ],
                                                        center: .center,
                                                        angle: .degrees(buttonGradientRotation + Double(index * 60))
                                                    )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.black.opacity(0.3))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [
                                                                    .white.opacity(0.6),
                                                                    .white.opacity(0.2),
                                                                    .white.opacity(0.8)
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 2
                                                        )
                                                )
                                                .shadow(
                                                    color: Color.rainbow(index: index, total: timeLine.years.count).opacity(0.8),
                                                    radius: 8,
                                                    x: 0,
                                                    y: 2
                                                )
                                        )
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .scaleEffect(selectedYear == timeLine.years[index] ? 1.1 : 0.9)
                                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: buttonGradientRotation)
                                        .onTapGesture {
                                            effectManager.triggerHaptic(.medium)
                                            reverseManager.trueIsPhotoFalseIsVideo = true
                                            self.selectedYear = timeLine.years[index]
                                            reverseManager.panoramaViewModel.fetchPanoramaImageSync(year: timeLine.years[index])
                                        }
                                        .animation(.default, value: self.selectedYear)
                                }
                            }
                            .padding(.horizontal, 10)
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .onAppear {
                            buttonGradientRotation = 0
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                                buttonGradientRotation = 360
                            }
                        }
                    }
                    
                    VStack {
                        if let year = selectedYear {
                            Text("欢迎来到\(year)年")
                                .foregroundColor(Color("ButtonColor"))
                                .font(.system(.largeTitle, design: .default, weight: .black))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(.ultraThinMaterial)
                    .opacity(displayYearInfo ? 1.0 : 0.0)
                    .animation(.easeInOut, value: displayYearInfo)
                    
                    VStack {
                        Text("正在前往")
                            .foregroundColor(Color("ButtonColor"))
                            .font(.system(.largeTitle, design: .default, weight: .black))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(.ultraThinMaterial)
                    .opacity(reverseManager.panoramaViewModel.isLoading ? 1.0 : 0.0)
                    .animation(.easeInOut, value: reverseManager.panoramaViewModel.isLoading)
                    
                    VStack {
                        Text("此处暂无街景")
                            .foregroundColor(Color("ButtonColor"))
                            .font(.system(.largeTitle, design: .default, weight: .black))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(.ultraThinMaterial)
                    .opacity(reverseManager.panoramaViewModel.meetSomeProblem ? 1.0 : 0.0)
                    .animation(.easeInOut, value: reverseManager.panoramaViewModel.meetSomeProblem)
                    
                    
                    
                    HStack {
                        Button(action: {
                            dismiss()
                            reverseManager.trueIsPhotoFalseIsVideo = true
                            reverseManager.panoramaViewModel.meetSomeProblem = false
                            self.reverseManager.videoUrl = ""
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
                    
                    // 炫光边框
                    if reverseManager.panoramaViewModel.isLoading {
                        RoundedRectangle(cornerRadius: deviceCornerRadius)
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        .red,
                                        .orange,
                                        .yellow,
                                        .green,
                                        .mint,
                                        .cyan,
                                        .blue,
                                        .indigo,
                                        .purple,
                                        .pink,
                                        .red
                                    ],
                                    center: .center,
                                    angle: .degrees(gradientRotation)
                                ),
                                lineWidth: self.rainBowBlurLineWidth
                            )
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .blur(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: deviceCornerRadius)
                                    .stroke(
                                        AngularGradient(
                                            colors: [
                                                .red,
                                                .orange,
                                                .yellow,
                                                .green,
                                                .mint,
                                                .cyan,
                                                .blue,
                                                .indigo,
                                                .purple,
                                                .pink,
                                                .red
                                            ],
                                            center: .center,
                                            angle: .degrees(gradientRotation + 180)
                                        ),
                                        lineWidth: self.rainBowLineWidth
                                    )
                                    .frame(
                                        width: geometry.size.width,
                                        height: geometry.size.height
                                    )
                            )
                            .ignoresSafeArea(.all)
                            .onAppear {
                                withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                                    gradientRotation = 360
                                }
                            }
                    }
                    
//                    Text("debug")
//                        .font(.largeTitle)
//                        .background(.white)
//                        .padding(.top, 200)
//                        .onTapGesture {
//                            reverseManager.panoramaViewModel.debug()
//                        }
                    
                }
                .onChange(of: reverseManager.panoramaViewModel.isLoading, { _, value in
                    if value {
                        gradientRotation = 0
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                            gradientRotation = 360
                        }
                        rainBowLineWidthAnimation()
                        
                    } else {
                        effectManager.stopAllEffects()
            
                        withAnimation {
                            if let _ = selectedYear {
                                displayYearInfo = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    displayYearInfo = false
                                }
                            }
                        }
                    }
                })
                .animation(.default, value: reverseManager.panoramaViewModel.isShowTimeLine)
                .background(Color("BackgroundColor"))
                .onAppear {
                    self.deviceCornerRadius = UIScreen.main.displayCornerRadius
                    self.rainBowLineWidthAnimation()
                }
                .bold()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    func rainBowLineWidthAnimation() {
        self.rainBowBlurLineWidth = 16.0
        self.rainBowLineWidth = 8.0
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            self.rainBowBlurLineWidth = 32.0
            self.rainBowLineWidth = 16.0
        }
    }
    
    func runGenerateAIVideo(year: String, sid: String) async {
        self.reverseManager.mapViewModel.isLoading = true
        reverseManager.mapViewModel.fetchPanoramaAIVideoUrlSync(request: GenerateVideoRequest(
            year: year,
            sid: sid
        ))
    }
}


#Preview {
    PanoramaView()
        .ignoresSafeArea(.all)
        .environmentObject(ReverseManager())
}
