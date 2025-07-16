import SwiftUI

struct SettingsView: View {
    @AppStorage("userEmoji") private var userEmoji = "🧍‍♂️"
    @AppStorage("botEmoji") private var botEmoji = "👩‍⚕️"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customize Emojis")) {
                    VStack(alignment: .leading) {
                        Text("Your Emoji")
                        EmojiPicker(selectedEmoji: $userEmoji)
                    }

                    VStack(alignment: .leading) {
                        Text("Bot Emoji")
                        EmojiPicker(selectedEmoji: $botEmoji)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct EmojiPicker: View {
    @Binding var selectedEmoji: String

    private let emojiOptions = [
        "🧍‍♂️", "👩‍⚕️", "🙂", "🤖", "😎", "👩‍💻", "🔬", "🧠", "👽", "🐶"
    ]

    var body: some View {
        Menu(content: {
            ForEach(emojiOptions, id: \.self) { emoji in
                Button(action: {
                    selectedEmoji = emoji
                }) {
                    Text(emoji)
                        .font(.largeTitle)
                }
            }
        }, label: {
            HStack {
                Text(selectedEmoji)
                    .font(.largeTitle)
                Image(systemName: "chevron.down.circle")
                    .font(.title2)
                    .padding(.leading, 8)
            }
        })
    }
}
