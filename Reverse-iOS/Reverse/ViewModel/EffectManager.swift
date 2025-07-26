//
//  EffectManager.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import Foundation
import AVFoundation
import UIKit

class EffectManager: ObservableObject {
    static let shared = EffectManager()
    
    private var flashTimer: Timer?
    private var vibrateTimer: Timer?
    private var device: AVCaptureDevice?
    
    @Published var isFlashActive = false
    @Published var isVibrateActive = false
    
    private init() {
        setupFlashlight()
    }
    
    // MARK: - 闪光灯设置
    private func setupFlashlight() {
        device = AVCaptureDevice.default(for: .video)
    }
    
    // MARK: - 闪光灯控制
    func toggleFlash(_ isOn: Bool) {
        guard let device = device, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
            isFlashActive = isOn
        } catch {
            print("闪光灯控制失败: \(error)")
        }
    }
    
    // MARK: - 震动控制
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    func triggerNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    func triggerSelectionHaptic() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    func startRainbowFlashEffect() {
        stopAllEffects()
        isFlashActive = true
        
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.toggleFlash(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.toggleFlash(false)
            }
            
            self.triggerHaptic(.light)
        }
    }
    
    func startIntenseEffect() {
        stopAllEffects()
        
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                self.triggerHaptic(.heavy)
            }
        }
        
        toggleFlash(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.toggleFlash(false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.toggleFlash(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.toggleFlash(false)
        }
    }
    
    func startPulseEffect() {
        stopAllEffects()
        isFlashActive = true
        isVibrateActive = true
        
        var pulseCount = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            pulseCount += 1
            if pulseCount > 10 {
                timer.invalidate()
                self.stopAllEffects()
                return
            }
            
            self.toggleFlash(true)
            self.triggerHaptic(.medium)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.toggleFlash(false)
            }
        }
    }
    
    func startTimeWarpEffect() {
        stopAllEffects()
        isFlashActive = true
        isVibrateActive = true
        
        let hapticStyles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .light, .medium, .medium, .heavy, .heavy]
        let intervals: [Double] = [0.5, 0.4, 0.3, 0.25, 0.2, 0.15]
        
        for (index, style) in hapticStyles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                self.triggerHaptic(style)
                
                self.toggleFlash(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + intervals[index] / 2) {
                    self.toggleFlash(false)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.startIntenseEffect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.stopAllEffects()
            }
        }
    }

    func stopAllEffects() {
        flashTimer?.invalidate()
        vibrateTimer?.invalidate()
        flashTimer = nil
        vibrateTimer = nil
        
        toggleFlash(false)
        isFlashActive = false
        isVibrateActive = false
    }
    
    deinit {
        stopAllEffects()
    }
}

extension EffectManager {
    func playSuccessEffect() {
        triggerNotificationHaptic(.success)
        toggleFlash(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.toggleFlash(false)
        }
    }

    func playErrorEffect() {
        triggerNotificationHaptic(.error)
        for i in 0..<2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.toggleFlash(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.toggleFlash(false)
                }
            }
        }
    }
    
    func playWarningEffect() {
        triggerNotificationHaptic(.warning)
        toggleFlash(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.toggleFlash(false)
        }
    }
}
