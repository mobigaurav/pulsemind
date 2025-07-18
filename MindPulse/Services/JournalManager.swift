//
//  JournalManager.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import Foundation
import CoreData

class JournalManager {
    static let shared = JournalManager()
    private let context = CoreDataManager.shared.container.viewContext

    func saveMoodOnlyEntry(_ mood: String) {
        let entry = JournalEntry(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.text = ""
        entry.mood = mood
        CoreDataManager.shared.saveContext()
    }
}

