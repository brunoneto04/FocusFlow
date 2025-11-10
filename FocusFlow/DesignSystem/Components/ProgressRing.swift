//
//  File.swift
//  		
//
//  Created by formando on 06/11/2025.
//

import Foundation

import SwiftUI

public struct ProgressRing: View {
    // Progresso 0...1
    public var progress: Double
    public var lineWidth: CGFloat = 14
    public var label: () -> AnyView

    public init(progress: Double, lineWidth: CGFloat = 14, label: @escaping () -> AnyView) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.label = label
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
            label()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

