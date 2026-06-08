import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store
    @State private var tab = 0
    @State private var showSettings = false

    var body: some View {
        TabView(selection: $tab) {
            TodayView(showSettings: $showSettings).tabItem { Label("Today", systemImage: "sun.haze") }.tag(0)
            JournalView().tabItem { Label("Journal", systemImage: "book.closed") }.tag(1)
            ToolsView().tabItem { Label("Tools", systemImage: "slider.horizontal.3") }.tag(2)
        }
        .fullScreenCover(isPresented: $store.showScan) { ScanView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }
}
