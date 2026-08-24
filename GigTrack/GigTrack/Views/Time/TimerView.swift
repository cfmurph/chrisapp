import SwiftUI
import SwiftData

/// Live start/stop timer. Only one entry runs at a time; starting a new one
/// while another is running is prevented by only showing the start form when
/// nothing is currently running.
struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]
    @Query(sort: \TimeEntry.startTime, order: .reverse) private var allEntries: [TimeEntry]

    @State private var selectedPerson: Person?
    @State private var project: String = ""

    private var runningEntry: TimeEntry? {
        allEntries.first { $0.isRunning }
    }

    var body: some View {
        if let runningEntry {
            runningTimerCard(for: runningEntry)
        } else {
            startTimerCard
        }
    }

    private var startTimerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start a Timer")
                .font(.headline)

            if people.isEmpty {
                Text("Add a person first to start logging hours.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Picker("Person", selection: $selectedPerson) {
                    Text("Select person").tag(Person?.none)
                    ForEach(people) { person in
                        Text(person.name).tag(Person?.some(person))
                    }
                }
                .pickerStyle(.menu)

                TextField("Project / Gig name", text: $project)
                    .textFieldStyle(.roundedBorder)

                Button {
                    startTimer()
                } label: {
                    Label("Start Timer", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedPerson == nil)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
    }

    private func runningTimerCard(for entry: TimeEntry) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle().fill(Color.red).frame(width: 8, height: 8)
                    Text("Timer Running").font(.headline)
                }
                Text(entry.person?.name ?? "Unknown")
                    .font(.subheadline.weight(.medium))
                if !entry.project.isEmpty {
                    Text(entry.project)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(Formatters.duration(entry.duration))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Button(role: .destructive) {
                    stopTimer(entry)
                } label: {
                    Label("Stop Timer", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
        }
    }

    private func startTimer() {
        guard let selectedPerson else { return }
        let entry = TimeEntry(project: project, startTime: .now, endTime: nil, person: selectedPerson)
        modelContext.insert(entry)
        project = ""
    }

    private func stopTimer(_ entry: TimeEntry) {
        entry.endTime = .now
    }
}

#Preview {
    List {
        TimerView()
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
    }
    .modelContainer(for: [Person.self, TimeEntry.self], inMemory: true)
}
