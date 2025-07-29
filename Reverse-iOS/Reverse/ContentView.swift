//
//  ContentView.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import SwiftUI
import MapKit
import SwiftUIPanoramaViewer

struct ContentView: View {
    @StateObject var reverseManager = ReverseManager()
    @State var startStory: Bool = false
    @State var longitude: String = "116.313393"
    @State var latitude: String = "40.047783"
    @State var year: String = "2023"
    @FocusState private var longitudeFocused: Bool
    @FocusState private var latitudeFocused: Bool
    @FocusState private var yearFocused: Bool
    @StateObject private var effectManager = EffectManager.shared
    @State private var tappedCoordinate: CLLocationCoordinate2D?
    @ObservedObject private var valueMonitor = ValueMonitor.shared
    @Environment(\.dismiss) private var dismiss
    
    @State var handleInputDateModel: Bool = false
    
    @State private var isRecommendPressed = false
    @State private var isMapPressed = false
    @State private var isPanoramaPressed = false
    @State private var selectedCityIndex: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                PanoramaViewer(
                    image: SwiftUIPanoramaViewer.bindImage("bg"),
                    controlMethod: .motion,
                    cameraMoved: { pitch, newYaw, roll in
                    }
                )
                .ignoresSafeArea()
                
                VStack {
                    CityImageCard(
                        imageName: "hdm",
                        cityName: "Swift是世界上最好的语言",
                        gradientColors: [.gray, .blue, .purple],
                        isSelected: selectedCityIndex == nil
                    ) {
                        selectedCityIndex = nil
                    }
                    .padding(.top, 50)
                    
                    ZStack {
                        VStack(spacing: 15) {
                            HStack(spacing: 15) {
                                CityImageCard(
                                    imageName: "shanghai",
                                    cityName: "上海",
                                    gradientColors: [.blue, .cyan, .teal],
                                    isSelected: selectedCityIndex == 0
                                ) {
                                    selectedCityIndex = selectedCityIndex == 0 ? nil : 0
                                    self.runVisit(lo: "0", la: "0", year: "", sid: "01000300001310131258181905J")
                                    self.reverseManager.videoUrl = "东方明珠"
                                }
                                
                                CityImageCard(
                                    imageName: "chongqing",
                                    cityName: "重庆",
                                    gradientColors: [.purple, .pink, .red],
                                    isSelected: selectedCityIndex == 1
                                ) {
                                    selectedCityIndex = selectedCityIndex == 1 ? nil : 1
                                    self.runVisit(lo: "0", la: "0", year: "", sid: "09029200011609281004462427O")
                                    self.reverseManager.videoUrl = "洪崖洞"
                                }
                            }
                            .padding(.horizontal, 10)
                            HStack(spacing: 15) {
                                
                                CityImageCard(
                                    imageName: "beijing",
                                    cityName: "北京",
                                    gradientColors: [.orange, .yellow, .green],
                                    isSelected: selectedCityIndex == 2
                                ) {
                                    selectedCityIndex = selectedCityIndex == 2 ? nil : 2
                                    self.runVisit(lo: "0", la: "0", year: "", sid: "09002200122212301028307801C")
                                    self.reverseManager.videoUrl = "天安门"
                                }
                                
                                CityImageCard(
                                    imageName: "quanzhou",
                                    cityName: "泉州",
                                    gradientColors: [.mint, .green, .teal],
                                    isSelected: selectedCityIndex == 3
                                ) {
                                    selectedCityIndex = selectedCityIndex == 3 ? nil : 3
                                    self.runVisit(lo: "0", la: "0", year: "", sid: "0900170012210329154439467GR")
                                    self.reverseManager.videoUrl = "钟楼"
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    
                    Button {
    //                    self.runVisit(lo: "116.313393", la: "40.047783", year: "2023", sid: "")
    //                    self.runEffect()
                        
                    } label: {
                        ZStack {
                            LiquidGlassView()
                            
                            Text("推荐")
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .purple.opacity(0.9)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    }
                    .frame(width: 160, height: 50)
                    .opacity(0)
                    
                    NavigationLink {
                        TapMapView(tappedCoordinate: $tappedCoordinate)
                            .environmentObject(reverseManager)
                    } label: {
                        ZStack {
                            LiquidGlassView()
                            
                            if let coordinate = tappedCoordinate {
                                Text("选点跃迁")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .purple.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            } else {
                                Text("选点跃迁")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .purple.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                        }
                    }
                    .frame(width: 160, height: 50)
                    .onChange(of: valueMonitor.locationChangeTrigger) { oldValue, newValue in
                        longitude = String(tappedCoordinate!.longitude)
                        latitude = String(tappedCoordinate!.latitude)
                        print("经度: \(longitude), 纬度: \(latitude)")
                        self.runVisit(lo: longitude, la: latitude, year: "", sid: "-1")
                        self.runEffect()
                    }

                    
                    NavigationLink(destination: CustomPanoramaView()) {
                        ZStack {
                            LiquidGlassView()
                            
                            Text("创建全景图")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .purple.opacity(0.9)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        .frame(width: 160, height: 50)
                        .scaleEffect(isPanoramaPressed ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPanoramaPressed)
                    }
                    .padding()
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        isPanoramaPressed = pressing
                    }, perform: {})
                    
                    NavigationLink {
                        VStack {
                            // 经度输入框
                            VStack(alignment: .leading, spacing: 8) {
                                Text("经度 (Longitude)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 4)
                                
                                TextField("116.313393", text: $longitude)
                                    .focused($longitudeFocused)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: longitudeFocused ?
                                                                [.blue, .purple, .cyan] :
                                                                [.gray.opacity(0.5), .gray.opacity(0.3)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: longitudeFocused ? 2 : 1
                                                    )
                                            )
                                            .shadow(
                                                color: longitudeFocused ? .blue.opacity(0.5) : .clear,
                                                radius: longitudeFocused ? 8 : 0
                                            )
                                    )
                                    .scaleEffect(longitudeFocused ? 1.02 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: longitudeFocused)
                            }
                            .padding(.horizontal, 20)
                            
                            // 纬度输入框
                            VStack(alignment: .leading, spacing: 8) {
                                Text("纬度 (Latitude)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 4)
                                
                                TextField("40.047783", text: $latitude)
                                    .focused($latitudeFocused)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: latitudeFocused ?
                                                                [.green, .mint, .teal] :
                                                                [.gray.opacity(0.5), .gray.opacity(0.3)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: latitudeFocused ? 2 : 1
                                                    )
                                            )
                                            .shadow(
                                                color: latitudeFocused ? .green.opacity(0.5) : .clear,
                                                radius: latitudeFocused ? 8 : 0
                                            )
                                    )
                                    .scaleEffect(latitudeFocused ? 1.02 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: latitudeFocused)
                            }
                            .padding(.horizontal, 20)
                            
                            // 年份输入框
                            VStack(alignment: .leading, spacing: 8) {
                                Text("年份 (Year)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 4)
                                
                                TextField("2023", text: $year)
                                    .focused($yearFocused)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: yearFocused ?
                                                                [.orange, .red, .pink] :
                                                                [.gray.opacity(0.5), .gray.opacity(0.3)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: yearFocused ? 2 : 1
                                                    )
                                            )
                                            .shadow(
                                                color: yearFocused ? .orange.opacity(0.5) : .clear,
                                                radius: yearFocused ? 8 : 0
                                            )
                                    )
                                    .scaleEffect(yearFocused ? 1.02 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: yearFocused)
                            }
                            .padding(.horizontal, 20)
                        }
                        .background(Color("BackgroundColor"))
                    } label: {
                        ZStack {
                            LiquidGlassView()
                            Text("高级模式")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .purple.opacity(0.9)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            .padding()
                        }
                        .frame(width: 160)
                    }
                    .opacity(0)
                    

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color("BackgroundColor"))
                .navigationDestination(isPresented: $startStory, destination: {
                    PanoramaView()
                        .environmentObject(reverseManager)
                        .ignoresSafeArea(.all)
                        .navigationBarBackButtonHidden()
                })
                .onTapGesture {
                    self.longitudeFocused = false
                    self.latitudeFocused = false
                    self.yearFocused = false
                }
            }
            
        }
//        .background(Color("BackgroundColor"))
    
    }
    
    func runVisit(lo: String, la: String, year: String, sid: String) {
        self.reverseManager.panoramaViewModel.isLoading = true
        reverseManager.panoramaViewModel.fetchPanoramaYearSync(request: PanoramaRequest(
            x: lo,
            y: la,
            year: year,
            sid: sid
        ))
        self.startStory = true
    }
    
    func runEffect() {
        if #available(iOS 18.2, *) {
            effectManager.startRainbowFlashEffect()
        } else {
            print("iOS version too low, skipping execution.")
        }
    }
}

// 炫酷城市图片卡片组件
struct CityImageCard: View {
    let imageName: String
    let cityName: String
    let gradientColors: [Color]
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var glowOffset: CGFloat = -100
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 主图片
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                
                // 光泽覆盖层
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: 120)
                    .rotationEffect(.degrees(15))
                    .offset(x: glowOffset)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: false),
                        value: glowOffset
                    )
                    .onAppear {
                        glowOffset = 120
                    }
                
                // 渐变遮罩（选中状态）
                if isSelected {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // 城市名称标签
                VStack {
                    Spacer()
                    Text(cityName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: gradientColors,
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .offset(y: -8)
                }
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            // 边框光效
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: isSelected ?
                            gradientColors + [gradientColors[0]] :
                            [Color.white.opacity(0.3), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .shadow(
            color: isSelected ?
                gradientColors[1].opacity(0.4) :
                Color.black.opacity(0.3),
            radius: isSelected ? 12 : 6,
            x: 0,
            y: isSelected ? 6 : 3
        )
        .shadow(
            color: isSelected ? gradientColors[0].opacity(0.2) : Color.clear,
            radius: isSelected ? 20 : 0,
            x: 0,
            y: isSelected ? 10 : 0
        )
        .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
        .rotation3DEffect(
            .degrees(isPressed ? 8 : 0),
            axis: (x: 1, y: 1, z: 0)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSelected)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    ContentView()
        .environmentObject(ReverseManager())
}
