import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: Store
    @Binding var showSettings: Bool
    @State private var showFeeding = false

    private var starter: Diagnosis { store.lastStarter ?? Sample.todayStarter }
    private var seeded: Bool { ProcessInfo.processInfo.arguments.contains("-seed") }

    var body: some View {
        NavigationStack {
            ScrollView {
                if store.hasStarter || seeded { populated }
                else {
                    EmptyState(icon: "waterbottle.fill", title: "Let's meet your starter",
                               message: "Take a photo of your starter and Proofd will read where it's at — and exactly what to do next.",
                               cta: "Scan my starter") { store.showScan = true }
                        .padding(.top, 80).padding(.horizontal, 4)
                }
            }
            .screenBackground().navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Text("Proofd").font(Theme.serif(.title3, .bold)).foregroundStyle(Theme.crust) }
                ToolbarItem(placement: .topBarTrailing) { Button { showSettings = true } label: { Image(systemName: "gearshape").foregroundStyle(Theme.inkMid) }.accessibilityLabel("Settings") }
            }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .sheet(isPresented: $showFeeding) { FeedingView() }
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning, baker").font(.subheadline.weight(.medium)).foregroundStyle(Theme.inkMid)
                Text("Today's rise").font(Theme.serif(.largeTitle, .bold)).foregroundStyle(Theme.ink)
            }.padding(.top, 4)

            Button { store.showScan = true } label: {
                HStack(spacing: 18) {
                    RiseGauge(level: starter.state.rise, color: starter.state.color)
                    VStack(alignment: .leading, spacing: 10) {
                        StatusPill(text: starter.state.label, icon: starter.state.icon, color: starter.state.color)
                        Text(starter.verdict).font(Theme.serif(.title3, .semibold)).foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true).lineSpacing(2).multilineTextAlignment(.leading)
                        HStack(spacing: 5) { Image(systemName: "arrow.clockwise").font(.caption2)
                            Text("Re-scan").font(.caption.weight(.semibold)) }.foregroundStyle(Theme.crust)
                    }
                    Spacer(minLength: 0)
                }.card(20)
            }.buttonStyle(.plain)

            Button { store.showScan = true } label: {
                HStack(spacing: 9) { Image(systemName: "camera.aperture"); Text("Scan my starter") }
            }.buttonStyle(CrustButton())

            Button { showFeeding = true } label: { feedCard }.buttonStyle(.plain)

            if !store.bakes.isEmpty {
                bakesSection(Array(store.bakes.prefix(3)))
            } else if seeded {
                bakesSection(Sample.bakes)
            }
        }
        .padding(.horizontal, 20).padding(.bottom, 40)
    }

    private func bakesSection(_ items: [Bake]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { SectionLabel(text: "Recent bakes"); Spacer() }
            VStack(spacing: 16) { ForEach(items) { BakeRow(bake: $0) } }.card(18)
        }
    }

    private var feedCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "bell.badge").font(.title3).foregroundStyle(Theme.crust).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                if let next = store.nextFeed {
                    Text(nextFeedText(next)).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                    Text("Ratio \(store.feedRatio) · every \(store.feedIntervalH)h").font(.caption).foregroundStyle(Theme.inkMid)
                } else {
                    Text("Set your feeding rhythm").font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                    Text("Get reminded when it's time to feed").font(.caption).foregroundStyle(Theme.inkMid)
                }
            }
            Spacer(); Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Theme.inkLow)
        }.card(18)
    }
    private func nextFeedText(_ d: Date) -> String {
        let h = Int(d.timeIntervalSinceNow / 3600)
        if h <= 0 { return "Time to feed your starter" }
        return "Next feed in about \(h)h"
    }
}
