import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var userInput: String = ""
    @State private var isLoading = false
    @State private var starterOptions: [String] = []
    @AppStorage("gptCallCount") private var gptCallCount = 0
    @AppStorage("lastCallDate") private var lastCallDate = Date()
    @AppStorage("cachedStarterOptions") private var cachedStarterOptions: String = ""
    @State private var selectedTab: String = "chat"
    @StateObject private var storage = JournalStorageViewModel()

    private let maxDailyCalls = 10

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 230/255, green: 240/255, blue: 255/255).ignoresSafeArea()

                VStack(spacing: 0) {
                    if selectedTab == "chat" {
                        VStack(spacing: 0) {
                            headerView
                            Divider()
                            chatScrollArea
                            Divider()
                            inputBar
                        }
                    } else if selectedTab == "calendar" {
                        CalendarPage(storage: storage)
                    } else if selectedTab == "settings" {
                        SettingsView()
                    }

                    BottomHUDBar(selectedTab: $selectedTab)
                }
            }
            .onAppear {
                _ = canCallAPI()
                let storedMessages = storage.messages(for: Date())

                if messages.isEmpty && storedMessages.isEmpty {
                    loadStarterOptions()
                } else if messages.isEmpty {
                    messages = storedMessages
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        messages = []
                        storage.updateMessages(for: Date(), messages: [])
                        cachedStarterOptions = ""
                        starterOptions = []
                        loadStarterOptions()
                    }) {
                        Text("Reset")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    var headerView: some View {
        VStack(spacing: 4) {
            Text("Journal.ly - AI Journal")
                .font(.title2).bold()
                .foregroundColor(.white)
                .padding(.top)
                .padding(.bottom, 6)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
        }
        .background(Color.white)
    }

    var chatScrollArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if messages.isEmpty && !starterOptions.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(starterOptions, id: \.self) { option in
                                Button(action: {
                                    messages.append(ChatMessage(role: .assistant, content: option))
                                    starterOptions = []
                                }) {
                                    Text(option)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .multilineTextAlignment(.center)
                        .alignmentGuide(.top) { _ in UIScreen.main.bounds.height / 4 }
                    } else {
                        ForEach(messages.indices, id: \.self) { index in
                            ChatBubble(message: messages[index])
                                .id(index)
                        }

                        if isLoading {
                            LoadingIndicatorView()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .onChange(of: messages) { _ in
                withAnimation {
                    proxy.scrollTo(messages.count - 1, anchor: .bottom)
                }
                storage.updateMessages(for: Date(), messages: messages)
            }
        }
    }

    var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Type your reply...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
            Button("Send") {
                sendMessage()
            }
            .padding(.trailing)
        }
        .padding(.vertical)
        .background(Color.white)
    }

    func canCallAPI() -> Bool {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastCallDate) {
            gptCallCount = 0
            lastCallDate = Date()
        }
        return gptCallCount < maxDailyCalls
    }

    func incrementUsage() {
        gptCallCount += 1
        lastCallDate = Date()
    }

    func loadStarterOptions() {
        let calendar = Calendar.current
        if calendar.isDateInToday(lastCallDate), !cachedStarterOptions.isEmpty {
            let lines = cachedStarterOptions.components(separatedBy: "\n")
            starterOptions = lines
            return
        }

        let prompt = "Give me 3 short, creative journaling questions to start someone's daily reflection. Return them as a plain numbered list, one per line."

        callGPT(with: [ChatMessage(role: .user, content: prompt)]) { response in
            DispatchQueue.main.async {
                guard let response = response else { return }
                let lines = response.components(separatedBy: "\n").compactMap { line in
                    line.components(separatedBy: ". ").last
                }
                starterOptions = lines
                cachedStarterOptions = lines.joined(separator: "\n")
            }
        }
        incrementUsage()
    }

    func sendMessage() {
        let input = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: input)
        messages.append(userMessage)
        userInput = ""
        isLoading = true
        incrementUsage()

        callGPT(with: messages) { response in
            DispatchQueue.main.async {
                if var response = response {
                    let followUps = [
                        " Would you like to reflect more on that?",
                        " How did that impact your mindset moving forward?",
                        " Is there anything else you’d like to share about that?",
                        " What did that experience teach you about yourself?",
                        " Would you like to explore that a bit more?"
                    ]
                    if let followUp = followUps.randomElement() {
                        response += followUp
                    }

                    messages.append(ChatMessage(role: .assistant, content: response))
                }
                isLoading = false
            }
        }
    }

    func loadAPIKey() -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OpenAI_API_Key"] as? String else {
            fatalError("API Key not found in Secrets.plist")
        }
        return key
    }

    func callGPT(with history: [ChatMessage], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        let apiKey = loadAPIKey()

        let systemPrompt: [String: String] = [
            "role": "system",
            "content": "You are a helpful AI journaling assistant. Keep things personal and encouraging."
        ]

        let userMessages = history.map {
            ["role": $0.role.rawValue, "content": $0.content]
        }

        let messagesPayload = [systemPrompt] + userMessages

        let jsonBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messagesPayload,
            "temperature": 0.7
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: jsonBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completion(nil)
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let decoded = try JSONDecoder().decode(GPTResponse.self, from: data)
                completion(decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines))
            } catch {
                completion(nil)
            }
        }.resume()
    }
}

struct BottomHUDBar: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack {
            Spacer()

            Button(action: { selectedTab = "chat" }) {
                VStack {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .foregroundColor(selectedTab == "chat" ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)

            Button(action: { selectedTab = "calendar" }) {
                VStack {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .foregroundColor(selectedTab == "calendar" ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)

            Button(action: { selectedTab = "settings" }) {
                VStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .foregroundColor(selectedTab == "settings" ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(Divider(), alignment: .top)
    }
}

struct LoadingIndicatorView: View {
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .opacity(Double(i + 1) / 3.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                        value: i
                    )
            }
        }
        .padding(.leading)
        .id("loading-indicator")
    }
}

struct GPTResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
