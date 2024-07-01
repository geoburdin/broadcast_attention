import SwiftUI

@main
struct broadcast_attentionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Use Settings or another window group for secondary windows if needed
        Settings {
            EmptyView()
        }
    }
}
