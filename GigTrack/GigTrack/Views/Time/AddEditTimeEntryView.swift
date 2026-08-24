import SwiftUI
import SwiftData

struct AddEditTimeEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode

    let entry: TimeEntry?

    @Query(sort: \Person.name) private var people: [Person]

    @State private var selectedPerson: Person?
    @State private var project = ""
    @State private var startTime: Date = .now
    @State private var endTime: Date = .now
    @State private var isOngoing = false
    @State private var notes = ""

    private var isEditing: Bool { entry != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Person", selection: $selectedPerson) {
                        Text("Select person").tag(Person?.none)
                        ForEach(people) { person in
                            Text(person.name).tag(Person?.some(person))
                        }
                    }
                    TextField("Project / Gig name", text: $project)
                }

                Section("Time") {
                    DatePicker("Start", selection: $startTime)
                    Toggle("Still running", isOn: $isOngoing)
                    if !isOngoing {
                        DatePicker("End", selection: $endTime, in: startTime...)
                    }
                }

                if !isOngoing {
                    Section("Summary") {
                        LabeledContent("Duration", value: Formatters.duration(max(0, endTime.timeIntervalSince(startTime))))
                        if let rate = selectedPerson?.hourlyRate, rate > 0 {
                            LabeledContent("Est. Earnings") {
                                Text(Formatters.currency(max(0, endTime.timeIntervalSince(startTime)) / 3600 * rate, code: currencyCode))
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Time Entry" : "Log Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(selectedPerson == nil)
                }
            }
            .onAppear(perform: populateIfEditing)
        }
    }

    private func populateIfEditing() {
        guard let entry else { return }
        selectedPerson = entry.person
        project = entry.project
        startTime = entry.startTime
        isOngoing = entry.isRunning
        endTime = entry.endTime ?? .now
        notes = entry.notes
    }

    private func save() {
        if let entry {
            entry.person = selectedPerson
            entry.project = project
            entry.startTime = startTime
            entry.endTime = isOngoing ? nil : endTime
            entry.notes = notes
        } else {
            let newEntry = TimeEntry(
                project: project,
                startTime: startTime,
                endTime: isOngoing ? nil : endTime,
                notes: notes,
                person: selectedPerson
            )
            modelContext.insert(newEntry)
        }
        dismiss()
    }
}

#Preview {
    AddEditTimeEntryView(entry: nil)
        .modelContainer(for: [Person.self, TimeEntry.self], inMemory: true)
}
