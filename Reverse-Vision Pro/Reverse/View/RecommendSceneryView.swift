//
//  RecommendSceneryView.swift
//  Reverse
//
//  Created by 沈逸帆 on 2025/7/25.
//

import SwiftUI

struct RecommendSceneryView: View {
    @ObservedObject var manager = ReverseManager.shared
    @State var selectedStatue: SelectedStatue = .city
    @State var selectedCityID: String = ""
    @State var selectedSceneryID: String = ""
    @State var selectedCoordinateID: String = ""
    @State var selectedCityList: [City] = []
    @State var selectedSceneryList: [Scenery] = []
    @State var selectedCoordinateList: [Coordinate] = []
    
    @Environment(AppModel.self) private var appModel

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some View {
        VStack {
            switch selectedStatue {
            case .city:
                HStack {
                    ForEach(SkyboxLoader.cityList) { city in
                        Button {
                            self.selectedCityID = city.id
                            self.findScenery()
                            self.selectedStatue = .scenery
                        } label: {
                            Text(city.title)
                                .padding(10)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                    }
                    Button {
                        self.selectedStatue = .city
                        Task {
                                appModel.immersiveSpaceState = .inTransition
                                await dismissImmersiveSpace()
                                // 不在这里设置为 `.closed`，让 ImmersiveView.onDisappear() 去设置
                            }
                        
                        
                    } label: {
                        Image(systemName: "arrow.backward.circle")
                            .padding(10)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            case .scenery:
                HStack {
                    ForEach(self.selectedSceneryList) { scenery in
                        Button {
                            self.selectedSceneryID = scenery.id
                            self.findCoordinate()
                            self.selectedStatue = .coordinate
                        } label: {
                            Text(scenery.title)
                                .padding(10)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }

                    }
                    
                    Button {
                        self.selectedStatue = .city
                    } label: {
                        Image(systemName: "arrow.backward.circle")
                            .padding(10)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            case .coordinate:
                HStack {
                    ForEach(self.selectedCoordinateList) { coor in
                        Button {
                            self.selectedCoordinateID = coor.sid!
                            self.manager.getYear(sid: coor.sid!, year: "2019")
                            self.selectedStatue = .year
                        } label: {
                            Text(coor.title)
                                .padding(10)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }

                    }
                    
                    Button {
                        self.selectedStatue = .scenery
                    } label: {
                        Image(systemName: "arrow.backward.circle")
                            .padding(10)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
            case .year:
                if self.manager.loadingYear || self.manager.yearList.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    HStack {
                        ForEach(self.manager.yearList, id: \.self) { year in
                            Button {
                                Task {
                                    await self.updateTexture(item: year)
                                }
                            } label: {
                                Text(year)
                                    .padding(10)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }

                        }
                        
                        Button {
                            self.selectedStatue = .coordinate
                            self.manager.yearList = []
                        } label: {
                            Image(systemName: "arrow.backward.circle")
                                .padding(10)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.default, value: self.selectedStatue)
    }
    
    enum SelectedStatue: String {
        case city
        case scenery
        case coordinate
        case year
    }
    
    func findScenery() {
        self.selectedSceneryList = SkyboxLoader.scenery.filter { scenery in
            return scenery.cityID == self.selectedCityID
        }
    }
    
    func findCoordinate() {
        self.selectedCoordinateList = SkyboxLoader.coordinates.filter { coordinate in
            return coordinate.SceneryID == self.selectedSceneryID
        }
        
    }
    
    func updateTexture(item: String) async {
        let texture = await SkyboxLoader.changeTexture(item: item)!
        manager.entity.updateSkyboxImage(from: texture)
    }
}

#Preview {
    RecommendSceneryView()
}
