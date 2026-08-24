import SwiftUI
import SwiftData

struct ClientsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.name) private var clients: [Client]

    @State private var showingAddSheet = false
    @State private var clientToEdit: Client?

    var body: some View {
        List {
            if clients.isEmpty {
                EmptyStateView(
                    systemImage: "person.2",
                    title: "No Clients Yet",
                    message: "Add a client so you can attach them to invoices."
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(clients) { client in
                    Button {
                        clientToEdit = client
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(client.name).font(.body.weight(.medium)).foregroundStyle(.primary)
                            if !client.email.isEmpty {
                                Text(client.email).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteClients)
            }
        }
        .navigationTitle("Clients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Client", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditClientView(client: nil)
        }
        .sheet(item: $clientToEdit) { client in
            AddEditClientView(client: client)
        }
    }

    private func deleteClients(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(clients[index])
        }
    }
}

#Preview {
    NavigationStack {
        ClientsListView()
    }
    .modelContainer(for: [Client.self], inMemory: true)
}
