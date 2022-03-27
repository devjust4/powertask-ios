//
//  ProgressCircleSessions.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 9/3/22.
//

import SwiftUI
import Combine

let lineWith: CGFloat = 20
let radius: CGFloat = 80

struct ContentView: View {
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.2), style: StrokeStyle(lineWidth: lineWith, lineCap: .round))
            }.frame(width: radius * 4, height: radius * 4)
        }
    }
}

class ContentView_Previews: ObservableObject {
    @Published var text: String

    init(text: String) {
        self.text = text
    }
}
