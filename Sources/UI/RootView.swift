import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store
    @State private var tab: Int
    @State private var showSettings = false
    @State private var demoDiag: Bool
    @State private var demoPaywall: Bool
    @State private var demoFeed: Bool

    init() {
        let a = ProcessInfo.processInfo.arguments
        var t = 0
        if let i = a.firstIndex(of: "-tab"), a.indices.contains(i+1), let n = Int(a[i+1]) { t = n }
        _tab = State(initialValue: t)
        _demoDiag = State(initialValue: a.contains("-diag"))
        _demoPaywall = State(initialValue: a.contains("-paywall"))
        _demoFeed = State(initialValue: a.contains("-feed"))
    }

    var body: some View {
        TabView(selection: $tab) {
            TodayView(showSettings: $showSettings).tabItem { Label("Today", systemImage: "sun.haze") }.tag(0)
            JournalView().tabItem { Label("Journal", systemImage: "book.closed") }.tag(1)
            ToolsView().tabItem { Label("Tools", systemImage: "slider.horizontal.3") }.tag(2)
        }
        .fullScreenCover(isPresented: $store.showScan) { ScanView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .fullScreenCover(isPresented: $demoDiag) { DiagnosisView(d: Sample.crumbDiag) }
        .sheet(isPresented: $demoPaywall) { PaywallView() }
        .sheet(isPresented: $demoFeed) { FeedingView() }
        .onAppear {
            let a = ProcessInfo.processInfo.arguments
            if a.contains("-scan") { store.showScan = true }
            if a.contains("-settings") { showSettings = true }
        }
    }
}
