//
//  LiquidGlassView.swift
//  Reverse
//
//  Created by Damien on 2025/7/26.
//

import SwiftUI

struct LiquidGlassView: View {
    var body: some View {
        // 背景玻璃效果
        RoundedRectangle(cornerRadius: 25)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.pink.opacity(0.2),
                                Color.orange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                // 内部光泽
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.purple.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: -5)
    }
}

#Preview {
    LiquidGlassView()
}
