import SwiftUI
import UIKit

/// Thin wrapper around `UIActivityViewController` for sharing files (e.g. an invoice PDF)
/// through Mail, Messages, AirDrop, Save to Files, etc.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
