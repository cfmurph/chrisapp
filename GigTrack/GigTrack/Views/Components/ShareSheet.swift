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

/// `.sheet(item:)`-friendly wrapper around one or more file URLs to share
/// (e.g. an invoice PDF, or a batch of CSV exports).
struct ShareItem: Identifiable {
    let id = UUID()
    let urls: [URL]

    init(url: URL) { self.urls = [url] }
    init(urls: [URL]) { self.urls = urls }
}
