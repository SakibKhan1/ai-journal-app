import SwiftUI

class JournalStorageViewModel: ObservableObject {
    @Published var journalEntries: [Date: [ChatMessage]] = [:]

    init() {
        load()
    }

    func stripTime(from date: Date) -> Date {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: comps) ?? date
    }

    func save() {
        if let data = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(data, forKey: "journalEntries")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let decoded = try? JSONDecoder().decode([Date: [ChatMessage]].self, from: data) {
            journalEntries = decoded
        }
    }

    func updateMessages(for date: Date, messages: [ChatMessage]) {
        let strippedDate = stripTime(from: date)
        journalEntries[strippedDate] = messages
        save()
    }

    func messages(for date: Date) -> [ChatMessage] {
        let strippedDate = stripTime(from: date)
        return journalEntries[strippedDate] ?? []
    }
    func clearAllMessages() {
        journalEntries = [:]
        UserDefaults.standard.removeObject(forKey: "journalEntries")
        save()
    }

}
