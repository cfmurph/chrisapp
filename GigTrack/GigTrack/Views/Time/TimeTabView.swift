import SwiftUI
import SwiftData

struct TimeTabView: View {
    @Query(sort: \TimeEntry.startTime, order: .reverse) private var entries: [TimeEntry]

    private var recentEntries: [TimeEntry] {
        Array(entries.prefix(5))
    }

    var body: some View {
        List {
            Section {
                TimerView()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            if !recentEntries.isEmpty {
                Section("Recent") {
                    ForEach(recentEntries) { entry in
                        NavigationLink {
                            AddEditTimeEntryView(entry: entry)
                        } label: {
                            TimeEntryRowView(entry: entry)
                        }
                    }
                }
            }

            Section {
                NavigationLink {
                    TimeEntriesListView()
                } label: {
                    Label("All Time Entries", systemImage: "list.bullet")
                }
                NavigationLink {
                    PeopleListView()
                } label: {
                    Label("People", systemImage: "person.2")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Time")
    }
}

#Preview {
    NavigationStack {
        TimeTabView()
    }
    .modelContainer(for: [Person.self, TimeEntry.self], inMemory: true)
}
