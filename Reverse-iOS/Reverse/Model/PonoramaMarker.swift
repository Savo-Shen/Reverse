//
//  PonoramaMarker.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import SwiftUI
import Foundation
import SwiftUIPanoramaViewer

struct PonoramaMarker {
    
}

struct Marker: Identifiable {
    let id = UUID()
    let label: String
    let color: SwiftUI.Color
    let pitchCenter: Float
    let yawCenter: Float
    let pitchRange: Float
    let yawRange: Float
    let action: () -> Void
}

//pitch max is 90 ,yaw max is 360 :10-50 60-100 110-150 160-200 210-250 260-300 310-350
let markers: [Marker] = [
    Marker(label: "A",
           color: Color("appRed"),
           pitchCenter: 60,
           yawCenter: 30,
           pitchRange: 60,
           yawRange: 20) {
        print("Clicked A")
    },
    Marker(label: "B",
           color: Color("appGreen"),
           pitchCenter: 60,
           yawCenter: 60,
           pitchRange: 60,
           yawRange: 20) {
        print("Clicked B")
    },
    Marker(label: "C",
           color: Color("appBlue"),
           pitchCenter: 60,
           yawCenter: 90,
           pitchRange: 60,
           yawRange: 20) {
        print("Clicked C")
    },
    Marker(label: "D",
           color: Color("appYellow"),
           pitchCenter: 60,
           yawCenter: 120,
           pitchRange: 60,
           yawRange: 20) {
        print("Clicked D")
    },
]

func fixedTargetHit(pitch: Float, yaw: Float,
                    pitchLeading: Float, pitchTrailing: Float,
                    yawLeading: Float, yawTrailing: Float) -> Bool {
    let p = normalizeTo360(pitch)
    let y = normalizeTo360(yaw)
    
    let pitchHit = isInRange(point: p, leading: pitchLeading, trailing: pitchTrailing)
    let yawHit   = isInRange(point: y, leading: yawLeading, trailing: yawTrailing)
    
    // Debugging output
    print("Pitch: \(p), Yaw: \(y)")
    print("Pitch Range: \(pitchLeading) to \(pitchTrailing), Yaw Range: \(yawLeading) to \(yawTrailing)")
    print("Pitch Hit: \(pitchHit), Yaw Hit: \(yawHit)")
    
    return pitchHit && yawHit
}

func isInRange(point: Float, leading: Float, trailing: Float) -> Bool {
    if trailing <= leading {
        return point >= trailing && point <= leading
    } else {
        return (point >= trailing && point <= 360) || (point >= 0 && point <= leading)
    }
}

func normalizeTo360(_ angle: Float) -> Float {
    var normalized = angle.truncatingRemainder(dividingBy: 360)
    if normalized < 0 { normalized += 360 }
    return normalized
}
