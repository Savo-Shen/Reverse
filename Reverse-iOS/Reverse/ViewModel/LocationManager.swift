//
//  LocationManager.swift
//  Reverse
//
//  Created by Damien on 2025/7/26.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    
    private var hasGotInitialLocation = false // 标记是否已获取初始位置

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("授权状态:", status.rawValue)
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // 只在首次授权时启动定位
            if !hasGotInitialLocation {
                manager.startUpdatingLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 当前定位:", location)
        
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            // 获取到位置后立即停止定位
            if !self.hasGotInitialLocation {
                self.hasGotInitialLocation = true
                self.manager.stopUpdatingLocation()
                print("⏹️ 初始定位完成，停止持续定位")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 定位失败:", error.localizedDescription)
        manager.stopUpdatingLocation()
    }
}
