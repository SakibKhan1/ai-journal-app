# Journal.ly – AI-Powered Daily Journal App

**Journal.ly** is a SwiftUI iOS app designed to help users reflect and document their day through a clean, calming interface powered by AI. The app allows users to record thoughts, chat with a therapist-like assistant, and browse their past journal entries via an intuitive calendar interface.

Built for users who want private, intelligent journaling without cloud dependency as all data is stored locally.

---

## 🛠️ Built With

- **SwiftUI** – Modern declarative UI framework for building iOS interfaces
- **Combine** – Reactive state updates using `@Published`, `@ObservedObject`, and `@AppStorage`
- **MVVM Architecture** – Clean separation of views, view models, and models
- **UserDefaults & Codable** – Lightweight and persistent local data storage
- **Date-based Journal Model** – Entries are automatically sorted and saved per day

---

## ✅ User Stories

The following **required** functionality is completed:

- ✅ Users can **type messages** and receive AI-powered journal prompts or replies
- ✅ Users can **add new daily entries** that are automatically grouped by date
- ✅ Users can **revisit and edit past entries** from a **calendar view**
- ✅ Users can **clear all history** via the Settings tab
- ✅ Entries are **persisted locally** and automatically restored on app launch

---

## Optional Features Implemented

- ✅ **Calendar view UI** with tap-to-view journal history
- ✅ **Settings page** with a destructive option to clear saved journal history
- ✅ **Multi-tab navigation** between Chat, Calendar, and Settings
- ✅ Local storage using `UserDefaults` for lightweight persistence
- ✅ Modular architecture using `ViewModel` for state and logic handling

---

## Navigation Structure

- **Chat Tab** – Type journal messages, receive AI prompts
- **Calendar Tab** – Tap on a past date to revisit that day's journal
- **Settings Tab** – Clear entire journal history

---

> This app is local-only and designed with privacy in mind. No journal data leaves the user’s device.


## 📱 App Demo

> ⚠️ The demo GIF may take up to **20 seconds** to load due to file size, thank you for your patience!

<img src="App_Demo.gif" width="400"/>
