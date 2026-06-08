import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var pro: ProStore
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if store.isPro {
                        Label("Proofd Pro — unlocked", systemImage: "crown.fill").foregroundStyle(Theme.crust)
                    } else {
                        Button { showPaywall = true } label: { Label("Unlock Proofd Pro", systemImage: "crown.fill").foregroundStyle(Theme.crust) }
                        Button { Task { await pro.restore() } } label: { Label("Restore purchase", systemImage: "arrow.clockwise").foregroundStyle(Theme.ink) }
                    }
                }
                Section("Preferences") {
                    Toggle(isOn: $store.useCups) { Label("Show cups (US)", systemImage: "cup.and.saucer") }.tint(Theme.crust)
                }
                Section {
                    Link(destination: URL(string: "https://duolaamengweb3.github.io/proofd/privacy.html")!) { Label("Privacy", systemImage: "hand.raised") }
                    Link(destination: URL(string: "https://duolaamengweb3.github.io/proofd/support.html")!) { Label("Support", systemImage: "envelope") }
                } footer: { Text("Your starter photos are sent only to diagnose them, never stored or shared. Your journal stays on your device.") }
            }
            .scrollContentBackground(.hidden).background(Theme.canvas)
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { store.persist(); dismiss() }.foregroundStyle(Theme.crust) } }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .onChange(of: store.useCups) { _, _ in store.persist() }
        }
    }
}
