//
//  Breathing.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import SwiftUI
import AVFoundation

enum BreathingSound: String, CaseIterable, Identifiable {
    case bird, forest, rain, wave, om, flute, ney, piano, harmonica,  none

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bird: return "Bird"
        case .forest: return "Forest"
        case .rain: return "Rain"
        case .wave: return "Waves"
        case .om: return "Om"
        case .flute: return "Flute"
        case .ney: return "Ney"
        case .piano: return "Piano"
        case .harmonica: return "Harmonica"
        case .none: return "None"
        }
    }
}


struct BreathingView: View {
    @State private var isBreathing = false
    @State private var countdown: Int = 60
    @State private var selectedDuration: Int = 60
    @State private var animateBreath = false
    @State private var isInhale = true
    @State private var elapsedTime: Double = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playSound = false
    @State private var selectedSound: BreathingSound = .bird
    
    private var progress: Double {
        selectedDuration > 0 ? elapsedTime / Double(selectedDuration) : 0
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("AccentColor"), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            VStack(spacing: 24) {
                Text("Breathing Session")
                    .font(.largeTitle)
                    .bold()
                
                // Timer Selector
                Picker("Duration", selection: $selectedDuration) {
                    Text("60 sec").tag(60)
                    Text("120 sec").tag(120)
                    Text("180 sec").tag(180)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedDuration) { newValue in
                    stopBreathing()
                    selectedDuration = newValue
                }
                .padding(.horizontal)
                
                // Breathing Ring + Circle + Text
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.2)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.green, .blue]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: animateBreath ? 300 : 1.5, height: animateBreath ? 300 : 1.5)
                        .scaleEffect(animateBreath ? 1.2 : 0.2)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateBreath)
                    
                    Text(isInhale ? "Inhale" : "Exhale")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                }
                .frame(height: 365)
                
                // Remaining Time
                if isBreathing {
                    Text("Remaining: \(countdown) sec")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                // Sound Toggle
                Toggle("Play Background Sound", isOn: $playSound)
                    .onChange(of: playSound) { newValue in
                        if newValue {
                            if let stored = UserDefaults.standard.string(forKey: "selectedBreathingSound"),
                               let sound = BreathingSound(rawValue: stored) {
                                selectedSound = sound
                            }
                            playBackgroundAudio()
                        } else {
                            audioPlayer?.stop()
                        }
                    }
                    .padding(.horizontal)
                
                // Start/Stop Button
                Button(action: {
                    isBreathing.toggle()
                    isBreathing ? startBreathing() : stopBreathing()
                }) {
                    Text(isBreathing ? "Stop" : "Start")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isBreathing ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .scaleEffect(isBreathing ? 1.1 : 1.0)
                        .animation(.spring(), value: isBreathing)
                }
                .padding(.horizontal)
            }
            .padding()
            .onAppear() {
                UIApplication.shared.isIdleTimerDisabled = true
                if let stored = UserDefaults.standard.string(forKey: "selectedBreathingSound"),
                   let sound = BreathingSound(rawValue: stored) {
                    selectedSound = sound
                }
            }
            .onDisappear(){
                UIApplication.shared.isIdleTimerDisabled = false
                isBreathing = false
                animateBreath = false
                countdown = selectedDuration
                elapsedTime = 0
                isInhale = true
                audioPlayer?.stop()
            }
        }
    }
        

    // MARK: - Breathing Logic

    func startBreathing() {
        countdown = selectedDuration
        elapsedTime = 0
        animateBreath = true
        toggleInhaleExhale()

        if playSound {
            playBackgroundAudio()
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 && isBreathing {
                countdown -= 1
                elapsedTime += 1
            } else {
                timer.invalidate()
                stopBreathing()
            }
        }
    }

    func stopBreathing() {
          isBreathing = false
          animateBreath = false
          countdown = selectedDuration
          elapsedTime = 0
          isInhale = true
          audioPlayer?.stop()
    }

    func toggleInhaleExhale() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { timer in
            if !isBreathing {
                timer.invalidate()
            } else {
                isInhale.toggle()
            }
        }
    }

    func playBackgroundAudio() {
        guard selectedSound != .none else { return }

        guard let soundURL = Bundle.main.url(forResource: selectedSound.rawValue, withExtension: "wav") else {
            print("Sound file not found: \(selectedSound.rawValue).wav")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop forever, manually stop when session ends
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }

}


#Preview {
    BreathingView()
}
