import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddEditReceiptView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode

    let receipt: Receipt?

    @State private var vendor: String = ""
    @State private var amount: Double = 0
    @State private var date: Date = .now
    @State private var category: String = ReceiptCategory.other.rawValue
    @State private var notes: String = ""
    @State private var imageData: Data?

    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?

    private var isEditing: Bool { receipt != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    photoSection
                }

                Section("Details") {
                    TextField("Vendor", text: $vendor)
                    TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Category", selection: $category) {
                        ForEach(ReceiptCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.systemImage).tag(cat.rawValue)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Receipt" : "New Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(vendor.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: populateIfEditing)
            .onChange(of: photoPickerItem) { _, newItem in
                Task {
                    if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .onChange(of: capturedImage) { _, newImage in
                if let newImage {
                    imageData = newImage.jpegData(compressionQuality: 0.8)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPicker(image: $capturedImage)
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private var photoSection: some View {
        if let data = imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(maxWidth: .infinity)
            Button(role: .destructive) {
                imageData = nil
                photoPickerItem = nil
                capturedImage = nil
            } label: {
                Label("Remove Photo", systemImage: "trash")
            }
        }

        HStack {
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
            }
            Spacer()
            Button {
                showingCamera = true
            } label: {
                Label("Take Photo", systemImage: "camera")
            }
        }
    }

    private func populateIfEditing() {
        guard let receipt else { return }
        vendor = receipt.vendor
        amount = receipt.amount
        date = receipt.date
        category = receipt.category
        notes = receipt.notes
        imageData = receipt.imageData
    }

    private func save() {
        if let receipt {
            receipt.vendor = vendor
            receipt.amount = amount
            receipt.date = date
            receipt.category = category
            receipt.notes = notes
            receipt.imageData = imageData
        } else {
            let newReceipt = Receipt(
                date: date,
                vendor: vendor,
                amount: amount,
                category: category,
                notes: notes,
                imageData: imageData
            )
            modelContext.insert(newReceipt)
        }
        dismiss()
    }
}

#Preview {
    AddEditReceiptView(receipt: nil)
        .modelContainer(for: [Receipt.self], inMemory: true)
}
