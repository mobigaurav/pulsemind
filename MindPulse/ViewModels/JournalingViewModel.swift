//
//  JournalingViewModel.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import Foundation
import CoreData

extension JournalingViewModel {
    func fetchRecentMoods(limit: Int = 5) {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit

        if let result = try? context.fetch(request) {
            self.recentMoods = result.map {
                MoodEntry(date: $0.date, mood: $0.mood)
            }
        }
    }
}

class JournalingViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var selectedMood: String = ""
    @Published var entries: [JournalEntry] = []
    @Published var recentMoods: [MoodEntry] = []
    
    private let context = CoreDataManager.shared.container.viewContext

    let moods = ["😊", "😐", "😔", "😡", "😴", "😇"]

    func saveEntry() {
        guard !text.isEmpty else { return }

        let newEntry = JournalEntry(context: context)
        newEntry.id = UUID()
        newEntry.date = Date()
        newEntry.text = text
        newEntry.mood = selectedMood

        CoreDataManager.shared.saveContext()
        text = ""
        selectedMood = ""

        fetchEntries()
    }
    
    func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            let context = CoreDataManager.shared.container.viewContext
            context.delete(entry)
        }
        CoreDataManager.shared.saveContext()
        fetchEntries()
    }
    
    func moodFrequencySorted() -> [(key: String, value: Int)] {
        let freq = Dictionary(grouping: entries.map { $0.mood }) { $0 }
            .mapValues { $0.count }
        return freq.sorted { $0.value > $1.value }
    }

    func fetchEntries() {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        if let result = try? context.fetch(request) {
            self.entries = result
        }
    }
}

