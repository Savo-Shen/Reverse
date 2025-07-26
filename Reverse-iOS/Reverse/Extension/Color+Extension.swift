//
//  Color+Extension.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import SwiftUI

extension Color {
    static func rainbow(index: Int, total: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .cyan, .blue, .indigo, .purple, .pink]
        let colorIndex = index % colors.count
        return colors[colorIndex]
    }
}