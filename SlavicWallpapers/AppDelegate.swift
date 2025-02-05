import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let popoverWidth: CGFloat = 300
    private let popoverHeight: CGFloat = 400

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        startBackgroundService()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopBackgroundService()
    }

    // MARK: - Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            configureStatusButton(button)
        }
    }

    private func configureStatusButton(_ button: NSStatusBarButton) {
        button.image = NSImage(named: "MenuBarIcon")
        button.action = #selector(togglePopover)
        button.target = self

        // Добавляем всплывающую подсказку
        button.toolTip = "Slavic Wallpapers"
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: popoverWidth, height: popoverHeight)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView()
                .frame(width: popoverWidth)
        )

        // Добавляем наблюдатель для закрытия при клике вне попапа
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, self.popover.isShown else { return }

            let clickLocation = event.window?.convertPoint(toScreen: event.locationInWindow) ?? .zero
            if !self.isClickInPopover(clickLocation) {
                self.popover.performClose(nil)
            }
        }
    }

    // MARK: - Background Service

    private func startBackgroundService() {
        Task {
            await BackgroundService.shared.startBackgroundUpdates()
        }
    }

    private func stopBackgroundService() {
        Task {
            await BackgroundService.shared.stopBackgroundUpdates()
        }
    }

    // MARK: - Actions

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover(button)
        }
    }

    // MARK: - Helper Methods

    private func showPopover(_ button: NSStatusBarButton) {
        // Позиционируем попап под кнопкой статус бара
        popover.show(relativeTo: button.bounds,
                     of: button,
                     preferredEdge: .minY)

        // Делаем попап активным окном
        if let window = popover.contentViewController?.view.window {
            window.makeKey()
        }
    }

    private func isClickInPopover(_ clickLocation: NSPoint) -> Bool {
        guard let frame = popover.contentViewController?.view.window?.frame else { return false }
        return frame.contains(clickLocation)
    }
}
