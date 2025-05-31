// chatser_helperApp.swift
import SwiftUI

@main
struct chatser_helperApp: App {
    // If you need to manage app state or have a delegate for more complex lifecycle events
    // you might introduce one here, e.g.:
    // @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // MenuBarExtra defines an item in the system menu bar.
        MenuBarExtra {
            // This is the content that appears when the user clicks your menu bar icon.
            // You'll likely want to put your main input UI here.
            // Let's create a dedicated view for this, e.g., MenuBarContentView()
            MenuBarContentView()
                .frame(width: 500, height: 400) // Adjust size as needed
        } label: {
            // This is what the user sees in the menu bar itself.
            // It can be text, an SF Symbol, or a custom image.
            Image(systemName: "bubble.middle.bottom.fill") // Example icon
            // Text("Chatser") // Or Text
        }
        .menuBarExtraStyle(.window) // Use .window for a popover-like behavior
                                    // Use .menu for a traditional menu dropdown
                                    // For a UI like Substage, .window is more appropriate
    }
}

// Optional: If you want to prevent the app from appearing in the Dock
// and having a main window by default, you might need an AppDelegate.
// class AppDelegate: NSObject, NSApplicationDelegate {
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        // To hide the Dock icon, you might need to set LSUIElement in Info.plist
//        // or manage window activation carefully.
//        // If MenuBarExtra is your *only* scene, it often handles this well.
//    }
// }
