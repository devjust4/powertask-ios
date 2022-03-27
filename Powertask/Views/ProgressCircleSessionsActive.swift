//
//  ProgressCircleSessionsActive.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 27/3/22.
//

import SwiftUI
import Combine

public var defaultTimeRemainingActive: CGFloat = 40
let lineWithActive: CGFloat = 20
let radiusActive: CGFloat = 80

struct SessionActive: View {
    @State private var isActive = true
    @State private var timeRemaining: CGFloat = defaultTimeRemainingActive
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: lineWith, lineCap: .round))
                Circle()
                    .trim(from: 0, to: 1 - ((defaultTimeRemainingActive - timeRemaining) / defaultTimeRemainingActive))
                    .stroke(timeRemaining > 6 ? Color.green : timeRemaining > 3 ? Color.yellow : Color.red, style: StrokeStyle(lineWidth: lineWith, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut)
                Text("\(Int(timeRemaining))").font(.system(size: 50))
            }.frame(width: radius * 4, height: radius * 4)
        }.onReceive(timer, perform: { _ in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isActive = false
                UserDefaults.standard.set(false, forKey: "taskSelected")
                timeRemaining = defaultTimeRemainingActive
            }
        })
        
        
    }
}

class SessionActive_Previews: ObservableObject {
    @Published var text: String

    init(text: String) {
        self.text = text
    }
}
