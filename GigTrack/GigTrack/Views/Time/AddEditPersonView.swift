import SwiftUI
import SwiftData

struct AddEditPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode

    let person: Person?

    @State private var name = ""
    @State private var role = ""
    @State private var hourlyRate: Double = 0

    private var isEditing: Bool { person != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Role (e.g. Guitarist, Sound Tech)", text: $role)
                    TextField("Hourly Rate", value: $hourlyRate, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(isEditing ? "Edit Person" : "New Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                guard let person else { return }
                name = person.name
                role = person.role
                hourlyRate = person.hourlyRate
            }
        }
    }

    private func save() {
        if let person {
            person.name = name
            person.role = role
            person.hourlyRate = hourlyRate
        } else {
            modelContext.insert(Person(name: name, role: role, hourlyRate: hourlyRate))
        }
        dismiss()
    }
}

#Preview {
    AddEditPersonView(person: nil)
        .modelContainer(for: [Person.self], inMemory: true)
}
