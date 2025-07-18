//
//  WatchBreathingView.swift
//  MindPulse Watch Watch App
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI
import WatchKit

struct WatchBreathingView: View {
    @State private var isBreathing = false
    @State private var phase = "Inhale"
    @State private var scale: CGFloat = 0.5
    @State private var timeRemaining = 60
    @State private var timer: Timer?

    let totalTime = 60 // default breathing session duration in seconds

    var body: some View {
        VStack(spacing: 10) {
            Text(phase)
                .font(.headline)
                .foregroundColor(.white)

            Circle()
                .fill(phase == "Inhale" ? Color.green : Color.blue)
                .frame(width: 100 * scale, height: 100 * scale)
                .animation(.easeInOut(duration: 3), value: scale)

            Text("\(timeRemaining)s")
                .font(.caption2)
                .foregroundColor(.gray)

            Button(action: {
                isBreathing ? stopBreathing() : startBreathing()
            }) {
                Text(isBreathing ? "Stop" : "Start")
                    .font(.footnote)
                    .padding(8)
                    .frame(width: 80)
                    .background(isBreathing ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.black)
        .cornerRadius(16)
        .onDisappear {
            stopBreathing()
        }
    }

    // MARK: - Logic

    func startBreathing() {
        isBreathing = true
        timeRemaining = totalTime
        phase = "Inhale"
        scale = 1.0
        triggerHaptic()

        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            timeRemaining -= 3
            if timeRemaining <= 0 {
                stopBreathing()
                return
            }

            togglePhase()
        }
    }

    func stopBreathing() {
        isBreathing = false
        timer?.invalidate()
        timer = nil
        timeRemaining = totalTime
        scale = 0.5
        phase = "Inhale"
    }

    func togglePhase() {
        if phase == "Inhale" {
            phase = "Exhale"
            scale = 0.5
        } else {
            phase = "Inhale"
            scale = 1.0
        }
        triggerHaptic()
    }

    func triggerHaptic() {
        WKInterfaceDevice.current().play(.directionUp) // simple vibration
    }
}

