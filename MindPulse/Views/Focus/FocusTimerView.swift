//
//  FocusTimerView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct FocusTimerView: View {
    @State private var timeRemaining: Int = 300 // 5 minutes
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 30) {
            Text("Focus Timer")
                .font(.largeTitle)
                .bold()

            Text(timeFormatted(timeRemaining))
                .font(.system(size: 60, weight: .medium, design: .monospaced))
                .padding()

            HStack(spacing: 20) {
                Button(action: startTimer) {
                    Label("Start", systemImage: "play.fill")
                        .padding()
                        .frame(width: 120)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: resetTimer) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .padding()
                        .frame(width: 120)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTimer() {
        if isRunning { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                isRunning = false
                // Optional: Trigger haptic or notification
            }
        }
    }

    private func resetTimer() {
        timer?.invalidate()
        timeRemaining = 300
        isRunning = false
    }

    private func timeFormatted(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}


