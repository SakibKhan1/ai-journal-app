import SwiftUI

struct JournalDetailView: View {
    let date: Date
    @State var messages: [ChatMessage]
    var onSave: (([ChatMessage]) -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }

                //JUST FOR TESTING, REMOVE FOR FINAL DEPLOYMENT *reminder* 
                Button("Add Entry (for testing)") {
                    messages.append(ChatMessage(role: .user, content: "Test entry at \(Date())"))
                }
                .padding(.bottom)
            }
            .navigationTitle(formattedDate(date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onSave?(messages) // Save the updated messages back to CalendarPage
                        dismiss()
                    }
                }
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}


