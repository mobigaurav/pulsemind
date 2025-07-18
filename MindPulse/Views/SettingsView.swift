//
//  SettingsView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import SwiftUI
import CoreData
import AVFoundation

struct SettingsView: View {
    @State private var remindersEnabled = false
    @State private var reminderTime = Date()
    @State private var permissionGranted = false
    @State private var showTimePicker = false
    
    let kReminderEnabledKey = "remindersEnabled"
    let kReminderTimeKey = "reminderTime"
    @State private var selectedSound: BreathingSound = .bird
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Journal Reminder")) {
                    Toggle(isOn: $remindersEnabled) {
                        Text("Enable Reminder")
                    }
                    .onChange(of: remindersEnabled) { _ in
                        persistState()
                        scheduleOrRemoveReminder()
                    }

                    if remindersEnabled {
                        Button(action: {
                            showTimePicker.toggle()
                        }) {
                            HStack {
                                Text("Selected Time:")
                                Spacer()
                                Text(timeString(from: reminderTime))
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $showTimePicker) {
                            VStack {
                                DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .padding()
                                Button("Done") {
                                    persistState()
                                    scheduleOrRemoveReminder()
                                    showTimePicker = false
                                }
                                .padding()
                            }
                        }
                    }
                }
                
                Section(header: Text("Breathing Preferences")) {
                    Picker("Select Sound", selection: $selectedSound) {
                        ForEach(BreathingSound.allCases) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    .pickerStyle(.menu) // Better UX than wheel on settings

                    Text("Selected: \(selectedSound.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    .onChange(of: selectedSound) { newSound in
                        UserDefaults.standard.set(newSound.rawValue, forKey: "selectedBreathingSound")
                        playSoundPreview(for: newSound)
                    }
                }

                
                Section(header: Text("About")) {
                    Text("MindPulse v1.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button("About Us") {
                        openLink("https://yourdomain.com/about")
                    }
                    
                    Button("Terms of Service") {
                        openLink("https://yourdomain.com/about")
                    }
                    
                    Button("Privacy Policy") {
                        openLink("https://yourdomain.com/privacy")
                    }

                    Button("Contact Support") {
                        sendSupportEmail()
                    }
                }

                Section {
                    Button(role: .destructive) {
                        resetAllData()
                    } label: {
                        Text("Reset All Data")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadInitialState()
         
                if let stored = UserDefaults.standard.string(forKey: "selectedBreathingSound"),
                   let sound = BreathingSound(rawValue: stored) {
                    selectedSound = sound
                }
                
            }
            .onDisappear {
                audioPlayer?.stop()
                audioPlayer = nil
            }
        }
    }

    // MARK: - Helpers
    
    func playSoundPreview(for sound: BreathingSound) {
        
        audioPlayer?.stop()
        audioPlayer = nil
        
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.play()
        } catch {
            print("Error playing preview: \(error)")
        }
    }


    func openLink(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }

    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func sendSupportEmail() {
        let email = "choti2792@gmail.com"
        let subject = "MindPulse Support"
        let urlString = "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    func resetAllData() {
        let context = CoreDataManager.shared.container.viewContext

        let journalRequest: NSFetchRequest<NSFetchRequestResult> = JournalEntry.fetchRequest()
        let stressRequest: NSFetchRequest<NSFetchRequestResult> = StressRecord.fetchRequest()

        let batchDelete1 = NSBatchDeleteRequest(fetchRequest: journalRequest)
        let batchDelete2 = NSBatchDeleteRequest(fetchRequest: stressRequest)

        do {
            try context.execute(batchDelete1)
            try context.execute(batchDelete2)
            try context.save()
            print("Reset completed.")
        } catch {
            print("Failed to reset:", error)
        }
    }

    func scheduleOrRemoveReminder() {
        Task {
            if remindersEnabled {
                permissionGranted = await NotificationManager.shared.requestAuthorization()
                if permissionGranted {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                    NotificationManager.shared.scheduleDailyReminder(
                        title: "Time to Journal 📝",
                        body: "Reflect on your day with MindPulse",
                        hour: components.hour ?? 20,
                        minute: components.minute ?? 0
                    )
                }
            } else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: ["mindpulse.journal.reminder"]
                )
            }
        }
    }

    func loadInitialState() {
        remindersEnabled = UserDefaults.standard.bool(forKey: kReminderEnabledKey)
        if let storedTime = UserDefaults.standard.object(forKey: kReminderTimeKey) as? Date {
            reminderTime = storedTime
        } else {
            reminderTime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date()
        }
    }

    func persistState() {
        UserDefaults.standard.set(remindersEnabled, forKey: kReminderEnabledKey)
        UserDefaults.standard.set(reminderTime, forKey: kReminderTimeKey)
    }
}

#Preview {
    SettingsView()
}

