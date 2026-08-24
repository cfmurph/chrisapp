import SwiftUI
import SwiftData

struct TimeEntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimeEntry.startTime, order: .reverse) private var entries: [TimeEntry]

    @State private var showingAddSheet = false
    @State private var entryToEdit: TimeEntry?

    private var totalHours: Double {
        entries.reduce(0) { $0 + $1.durationHours }
    }

    var body: some View {
        List {
            if !entries.isEmpty {
                StatCardRow(cards: [
                    ("Total Hours", String(format: "%.1f", totalHours), .accentColor),
                    ("Entries", "\(entries.count)", .secondary)
                ])
            }

            if entries.isEmpty {
                EmptyStateView(
                    systemImage: "clock",
                    title: "No Time Logged Yet",
                    message: "Start the timer or log hours manually."
                )
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(entries) { entry in
                        Button {
                            entryToEdit = entry
                        } label: {
                            TimeEntryRowView(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("All Time Entries")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Log Hours", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditTimeEntryView(entry: nil)
        }
        .sheet(item: $entryToEdit) { entry in
            AddEditTimeEntryView(entry: entry)
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

struct TimeEntryRowView: View {
    let entry: TimeEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.person?.name ?? "Unassigned")
                    .font(.body.weight(.medium))
                if !entry.project.isEmpty {
                    Text(entry.project)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(Formatters.mediumDate.string(from: entry.startTime))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                if entry.isRunning {
                    Label("Running", systemImage: "record.circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                } else {
                    Text(Formatters.hours(entry.duration))
                        .font(.body.weight(.semibold))
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        TimeEntriesListView()
    }
    .modelContainer(for: [Person.self, TimeEntry.self], inMemory: true)
}
