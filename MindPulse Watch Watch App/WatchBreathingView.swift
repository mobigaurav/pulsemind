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
    @State private var totalTime = 60
    @State private var timer: Timer?
    @State private var showCompletion = false
    @State private var selectedDuration = 1

    let durations = [1, 2, 5]

    var body: some View {
        List {
            VStack(spacing: 10) {
                if showCompletion {
                    Text("Completed")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Button("Done") {
                        resetState()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Breathing")
                        .font(.headline)
                    
                    if !isBreathing {
                        Picker("Duration", selection: $selectedDuration) {
                            ForEach(durations, id: \.self) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .labelsHidden()
                        .frame(height: 30)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(scale)
                            .frame(width: 100, height: 100)
                            .animation(.easeInOut(duration: 3), value: scale)
                        
                        Text("\(timeRemaining)s")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    Text(phase)
                        .font(.subheadline)
                        .foregroundColor(phase == "Inhale" ? .green : .blue)
                    
                    Button(action: {
                        isBreathing ? stopBreathing() : startBreathing()
                    }) {
                        Text(isBreathing ? "Stop" : "Start")
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(isBreathing ? Color.red : Color.green)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .onDisappear {
                stopBreathing()
            }
        }
    }

    // MARK: - Logic

    func startBreathing() {
        totalTime = selectedDuration * 60
        timeRemaining = totalTime
        isBreathing = true
        phase = "Inhale"
        scale = 1.0
        triggerHaptic()

        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            timeRemaining -= 3
            if timeRemaining <= 0 {
                stopBreathing()
                showCompletion = true
                WKInterfaceDevice.current().play(.success)
                return
            }
            togglePhase()
        }
    }

    func stopBreathing() {
        isBreathing = false
        timer?.invalidate()
        timer = nil
    }

    func resetState() {
        stopBreathing()
        timeRemaining = selectedDuration * 60
        phase = "Inhale"
        scale = 0.6
        showCompletion = false
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
