import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        
        // Запускаем фоновое обновление
        Task {
            await BackgroundService.shared.startBackgroundUpdates()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Останавливаем фоновые обновления при выходе
        Task {
            await BackgroundService.shared.stopBackgroundUpdates()
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "photo.circle", accessibilityDescription: "Slavic Wallpaper")
            statusButton.action = #selector(togglePopover)
            statusButton.target = self
        }
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }
    
    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
} 