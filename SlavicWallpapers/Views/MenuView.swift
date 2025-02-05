import SwiftUI

struct MenuView: View {
    @StateObject private var appState = AppState.shared
    @Namespace private var animation

    var body: some View {
        VStack(spacing: 12) {
            Header()

            if let error = appState.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
            }

            if let lastUpdate = appState.lastUpdate {
                TimelineView(.periodic(from: .now, by: 20)) { _ in
                    Text(String(format: Localizable.Menu.lastUpdate,
                                lastUpdate.formatted(.relative(presentation: .named))))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }

            Divider()
                .padding(.vertical, 4)

            VStack(spacing: 8) {
                MenuButton(
                    title: Localizable.Menu.updateWallpaper,
                    icon: "arrow.clockwise"
                ) {
                    withAnimation {
                        appState.updateWallpaper()
                    }
                }
                .accessibilityIdentifier("updateWallpaperButton")
                .disabled(appState.isUpdating)
                .overlay {
                    if appState.isUpdating {
                        HStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.small)
                                .padding(.trailing, 8)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                Group {
                    MenuButton(title: Localizable.Menu.openFolder, icon: "folder") {
                        Task {
                            await appState.openWallpapersFolder()
                        }
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.openFolderButton)

                    MenuButton(
                        title: Localizable.Menu.backgroundUpdate,
                        icon: appState.isBackgroundEnabled ? "clock.fill" : "clock"
                    ) {
                        withAnimation {
                            appState.toggleBackgroundUpdates()
                        }
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.backgroundUpdateButton)

                    if appState.isBackgroundEnabled {
                        MenuButton(
                            title: "\(Localizable.Time.updateInterval): " +
                                "\(appState.updateInterval.localizedDescription)",
                            icon: "clock.arrow.2.circlepath"
                        ) {
                            appState.showingIntervalPicker = true
                        }
                        .accessibilityIdentifier(AccessibilityIdentifiers.updateIntervalButton)
                        .popover(isPresented: $appState.showingIntervalPicker) {
                            UpdateIntervalView(
                                interval: .init(
                                    get: { appState.updateInterval },
                                    set: { interval in
                                        Task {
                                            await appState.setUpdateInterval(interval)
                                        }
                                    }
                                ),
                                onDismiss: { appState.showingIntervalPicker = false }
                            )
                        }
                    }
                }
                .transition(.scale.combined(with: .opacity))

                Divider()
                    .padding(.vertical, 4)

                WallpaperModeMenu(appState: appState, animation: animation)

                MenuButton(title: Localizable.Menu.quit, icon: "power") {
                    NSApplication.shared.terminate(nil)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.quitButton)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .frame(width: 300)
        .animation(.spring(duration: 0.3), value: appState.isUpdating)
        .animation(.spring(duration: 0.3), value: appState.error)
        .animation(.spring(duration: 0.3), value: appState.isBackgroundEnabled)
    }
}

// Создадим отдельное view для меню режима обоев
struct WallpaperModeMenu: View {
    @ObservedObject var appState: AppState
    var animation: Namespace.ID

    var body: some View {
        Menu {
            ForEach(WallpaperMode.allCases, id: \.self) { mode in
                Button(
                    action: {
                        Task {
                            await appState.setWallpaperMode(mode)
                        }
                    },
                    label: {
                        HStack {
                            Text(mode.localizedName)
                            if appState.wallpaperMode == mode {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .matchedGeometryEffect(id: "checkmark", in: animation)
                            }
                        }
                    }
                )
                .accessibilityIdentifier("wallpaperMode.\(mode.rawValue)")
                .disabled(appState.isUpdating)
            }
        } label: {
            MenuButton(
                title: "\(Localizable.Menu.wallpaperMode): \(appState.wallpaperMode.localizedName)",
                icon: "rectangle.split.2x1"
            ) {
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.wallpaperModeButton)
        }
    }
}

#Preview {
    MenuView()
}
