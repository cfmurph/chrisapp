import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableIfSupported(systemImage: systemImage, title: title, message: message)
    }
}

/// `ContentUnavailableView` is iOS 17+. Since this app targets iOS 17, we can use it
/// directly, but wrap it so the empty state is defined once and styled consistently.
private struct ContentUnavailableIfSupported: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(message)
        )
    }
}
