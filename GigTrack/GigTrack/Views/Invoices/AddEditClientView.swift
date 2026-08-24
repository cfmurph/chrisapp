import SwiftUI
import SwiftData

struct AddEditClientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let client: Client?

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""

    private var isEditing: Bool { client != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle(isEditing ? "Edit Client" : "New Client")
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
                guard let client else { return }
                name = client.name
                email = client.email
                phone = client.phone
                address = client.address
            }
        }
    }

    private func save() {
        if let client {
            client.name = name
            client.email = email
            client.phone = phone
            client.address = address
        } else {
            modelContext.insert(Client(name: name, email: email, phone: phone, address: address))
        }
        dismiss()
    }
}

#Preview {
    AddEditClientView(client: nil)
        .modelContainer(for: [Client.self], inMemory: true)
}
