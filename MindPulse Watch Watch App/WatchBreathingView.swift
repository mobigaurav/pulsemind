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
    @State private var scale: CGFloat = 0.6
    @State private var timeRemaining = 60
    @State private var timer: Timer?

    let totalTime = 60

    var body: some View {
        VStack() {
            ScrollView {
                Text("Breathing")
                    .font(.headline)
                
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
                        .scaleEffect(scale)
                        .frame(width: 90, height: 90)
                        .animation(.easeInOut(duration: 3), value: scale)
                    
                    Text("\(timeRemaining)s")
                        .font(.footnote)
                        .foregroundColor(.white)
                }
                
                Text(phase)
                    .font(.subheadline)
                    .foregroundColor(phase == "Inhale" ? .green : .blue)
                
                Button(action: {
                    isBreathing ? stopBreathing() : startBreathing()
                }) {
                    Text(isBreathing ? "Stop" : "Start")
                        .font(.footnote.bold())
                        .padding(.horizontal, 40)
                        .padding(.vertical, 6)
                        .background(isBreathing ? Color.red : Color.green)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .onDisappear {
                stopBreathing()
            }
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
        scale = 0.6
        phase = "Inhale"
    }

    func togglePhase() {
        if phase == "Inhale" {
            phase = "Exhale"
            scale = 0.6
        } else {
            phase = "Inhale"
            scale = 1.0
        }
        triggerHaptic()
    }

    func triggerHaptic() {
        WKInterfaceDevice.current().play(.directionUp)
    }
}

#Preview {
    WatchBreathingView()
}
