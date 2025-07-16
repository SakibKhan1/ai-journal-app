import SwiftUI

struct SettingsView: View {
    @StateObject private var storage = JournalStorageViewModel()
    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(role: .destructive) {
                        storage.clearAllMessages()
                        showConfirmation = true
                    } label: {
                        Label("Delete All Journal History", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("History Deleted"),
                    message: Text("All journal entries have been cleared."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
