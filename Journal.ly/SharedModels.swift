import Foundation
import SwiftUI
//funcs that are used in more than one file 
struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let role: Role
    let content: String
    
    enum ChatRole: String, Codable {
        case user, assistant
    }
    
    init(id: UUID = UUID(), role: Role, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id && lhs.role == rhs.role && lhs.content == rhs.content
    }
}

enum Role: String, Codable {
    case user
    case assistant
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text(message.role == .user ? "🧍‍♂️" : "👩‍⚕️")
                .font(.system(size: 34))
                .baselineOffset(-4)

            Text(message.content)
                .padding(10)
                .background(message.role == .user ? Color.blue.opacity(0.2) : Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .id(message.id)
    }
}

extension Date: Identifiable {
    public var id: Date { self }
}
