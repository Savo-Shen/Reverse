import RealityKit
import UIKit

let baseUrl = "http://30.201。217.9:5001"

struct SkyboxLoader {
    static let coordinates: [Coordinate] = [
        Coordinate(id: "co0", SceneryID: "s0", title: "前门" , x: 118.598973, y: 24.907501, sid: "09001700011610041517586316G"),
        Coordinate(id: "co1", SceneryID: "s0", title: "后门" , x: 0, y: 0, sid: "09001700001407250948508836V"),
        Coordinate(id: "co2", SceneryID: "s0", title: "北门" , x: 0, y: 0, sid: "09001700011610031017160686G"),
        Coordinate(id: "co3", SceneryID: "s0", title: "南门" , x: 0, y: 0, sid: "0900170012210329154439467GR"),
        Coordinate(id: "co4", SceneryID: "s0", title: "东门" , x: 118.58818842959329, y: 24.904446405155213, sid: "-1"),
        Coordinate(id: "co5", SceneryID: "s1", title: "南cccccc门" , x: 0, y: 0, sid: "0900170012210329154439467GR"),
        Coordinate(id: "co6", SceneryID: "s1", title: "东aaaaa门" , x: 118.58818842959329, y: 24.904446405155213, sid: "-1")
    ]
    
    static let scenery: [Scenery] = [
        Scenery(id: "s0", cityID: "c1", title: "QuanZhou_Alarm"),
        Scenery(id: "s1", cityID: "c2", title: "HangZhou_Alarm")
    ]
//    static let coordinates: [String: Coordinate] = [
//        "Quanzhou_Zhonglou_1": Coordinate(x: 118.598973, y: 24.907501, sid: "09001700011610041517586316G"),
//        "Quanzhou_Zhonglou_2": Coordinate(x: 0, y: 0, sid: "09001700001407250948508836V"),
//        "Quanzhou_Zhonglou_3": Coordinate(x: 0, y: 0, sid: "09001700011610031017160686G"),
//        "Quanzhou_Zhonglou_4": Coordinate(x: 0, y: 0, sid: "0900170012210329154439467GR"),
//        "Test": Coordinate(x: 118.58818842959329, y: 24.904446405155213, sid: "-1")
//    ]
    
    static let cityList: [City] = [
        City(id: "c1", title: "QuanZhou"),
        City(id: "c2", title: "HangZhou")
    ]
    
    static let yearList:  [year] = []
//    static let cityList: [String: [String]] = [
//        "Quanzhou_Zhonglou": [
//            "Quanzhou_Zhonglou_1",
//            "Quanzhou_Zhonglou_2"
//        ]
//    ]
    static let city = "c1"
    static func loadImageYear(city: String = "\(city)", year: Int = 2013) async -> ([String], String) {
        let coord  = coordinates.first { item in
            return item.sid == city
        }!
        
        var request = URLRequest(url: URL(string: "\(baseUrl)/baidu_map_jailbreak")!)
        request.httpMethod = "POST"
        let params: [String: Any] = ["X": coord.x, "Y": coord.y, "sid": coord.sid!]
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let arr = try? JSONSerialization.jsonObject(with: data) as? [Any],
               let years = arr.first as? [String],
               let sid = arr.last as? String {
                return (years, sid)
            } else {
                if let rawString = String(data: data, encoding: .utf8) {
                    print("返回数据不是 [[String], String]：\(rawString)")
                }
            }
        } catch {
            print("获取图片年份list失败: \(error)")
        }
        return ([], "")
    }
    
    static func loadLocalTexture(bgUrl: String) async -> TextureResource? {
        if let image = UIImage(named: bgUrl), let cgImage = image.cgImage {
            return try? await TextureResource(image: cgImage, options: .init(semantic: .color))
        }
        return nil
    }
    
    static func loadTexture(city: String = "\(city)", year: Int = 2013, fallbackName: String = "bg1") async -> TextureResource? {
        let (years, sid) = await loadImageYear(city: city, year: year)
        DispatchQueue.main.async {
            ReverseManager.shared.yearList = years
            ReverseManager.shared.sid = sid
        }
        var components = URLComponents(string: "\(baseUrl)/get_image")
        components?.queryItems = [
            URLQueryItem(name: "year", value: years.first ?? "2013"),
            URLQueryItem(name: "sid", value: sid)
        ]
        if let url = components?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let image = UIImage(data: data), let cgImage = image.cgImage {
                    return try? await TextureResource(image: cgImage, options: .init(semantic: .color))
                }
            } catch {
                print("网络图片下载失败: \(error)")
            }
        }
        // fallback to local asset
        return try? await TextureResource(named: fallbackName, options: .init(semantic: .color))
    }
    
    static func changeTexture(item: String) async -> TextureResource?  {
        var components = URLComponents(string: "\(baseUrl)/get_image")
        components?.queryItems = [
            URLQueryItem(name: "year", value: "\(item)"),
            URLQueryItem(name: "sid", value: ReverseManager.shared.sid)
        ]
        if let url = components?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let image = UIImage(data: data), let cgImage = image.cgImage {
                    return try? await TextureResource(image: cgImage, options: .init(semantic: .color))
                }
            } catch {
                print("网络图片下载失败: \(error)")
            }
        }
        // fallback to local asset
        return try? await TextureResource(named: "bg2", options: .init(semantic: .color))
    }
}
