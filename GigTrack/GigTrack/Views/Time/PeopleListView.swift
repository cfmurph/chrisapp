import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]

    @State private var showingAddSheet = false
    @State private var personToEdit: Person?

    var body: some View {
        List {
            if people.isEmpty {
                EmptyStateView(
                    systemImage: "person.2.badge.gearshape",
                    title: "No People Yet",
                    message: "Add band members or crew so they can log hours."
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(people) { person in
                    Button {
                        personToEdit = person
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(person.name).foregroundStyle(.primary)
                                if !person.role.isEmpty {
                                    Text(person.role).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if person.hourlyRate > 0 {
                                Text("$\(person.hourlyRate.formatted())/hr")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deletePeople)
            }
        }
        .navigationTitle("People")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Person", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditPersonView(person: nil)
        }
        .sheet(item: $personToEdit) { person in
            AddEditPersonView(person: person)
        }
    }

    private func deletePeople(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(people[index])
        }
    }
}

#Preview {
    NavigationStack {
        PeopleListView()
    }
    .modelContainer(for: [Person.self], inMemory: true)
}
