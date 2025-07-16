import SwiftUI

struct CalendarPage: View {
    @State private var selectedDate: Date? = nil
    @ObservedObject var storage: JournalStorageViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("Your Journal History")
                .font(.title2).bold()
                .padding()

            CalendarView(selectedDate: $selectedDate)
                .padding(.bottom)

            Spacer()
        }
        .sheet(item: $selectedDate) { date in
            JournalDetailView(
                date: date,
                messages: storage.messages(for: date),
                onSave: { updatedMessages in
                    storage.updateMessages(for: date, messages: updatedMessages)
                }
            )
        }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date?
    private let calendar = Calendar.current
    private let monthDates: [Date] = generateMonthDates()

    private var headerTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack {
            Text(headerTitle)
                .font(.headline)

            HStack {
                ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(monthDates, id: \.self) { date in
                    Button(action: {
                        selectedDate = date
                    }) {
                        Text("\(calendar.component(.day, from: date))")
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(
                                calendar.isDateInToday(date) ? Color.blue.opacity(0.2) : Color.clear
                            )
                            .clipShape(Circle())
                    }
                    .disabled(!calendar.isDate(date, equalTo: Date(), toGranularity: .month))
                }
            }
        }
        .padding(.horizontal)
    }

    private static func generateMonthDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: today),
              let startWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let endWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1)) else {
            return []
        }

        let totalDays = calendar.dateComponents([.day], from: startWeek.start, to: endWeek.end).day ?? 0
        return (0...totalDays).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startWeek.start)
        }
    }
}
