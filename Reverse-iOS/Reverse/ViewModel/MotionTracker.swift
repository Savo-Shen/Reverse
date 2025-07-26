//
//  MotionTracker.swift
//  Reverse
//
//  Created by Damien on 2025/7/25.
//

import CoreMotion

class MotionTracker: ObservableObject {
    // 无法解决的欧卡角问题
    private let motionManager = CMMotionManager()
    @Published var pitch: Float = 0
    @Published var yaw: Float = 0

    init() {
        start()
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { data, _ in
            guard let attitude = data?.attitude else { return }

            self.pitch = Float(attitude.pitch.radiansToDegrees)
            self.yaw = Float(attitude.yaw.radiansToDegrees)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}

extension Double {
    var radiansToDegrees: Double { self * 180 / .pi }
}
