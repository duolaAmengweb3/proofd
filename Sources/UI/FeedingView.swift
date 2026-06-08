import SwiftUI
import UserNotifications

struct FeedingView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    private let ratios = ["1:1:1", "1:2:2", "1:3:3", "1:5:5"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(text: "Feeding ratio")
                        Picker("", selection: $store.feedRatio) { ForEach(ratios, id: \.self) { Text($0).tag($0) } }.pickerStyle(.segmented)
                        Text("starter : flour : water (by weight)").font(.caption).foregroundStyle(Theme.inkLow)
                    }.card(20)

                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(text: "Feed every")
                        Stepper(value: $store.feedIntervalH, in: 4...24, step: 1) {
                            Text("\(store.feedIntervalH) hours").font(.callout.weight(.semibold)).foregroundStyle(Theme.ink)
                        }
                        Text("Warmer kitchens ferment faster — feed more often.").font(.caption).foregroundStyle(Theme.inkLow)
                    }.card(20)

                    if let next = store.nextFeed {
                        HStack(spacing: 10) {
                            Image(systemName: "clock.badge.checkmark").foregroundStyle(Theme.active)
                            Text(nextText(next)).font(.subheadline.weight(.medium)).foregroundStyle(Theme.ink)
                            Spacer()
                        }.card(16)
                    }

                    Button { fedNow() } label: { Label("I fed it just now", systemImage: "drop.fill") }.buttonStyle(CrustButton())
                    Text("We'll send one gentle reminder when it's time for the next feed.")
                        .font(.caption).foregroundStyle(Theme.inkLow).frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
            }
            .screenBackground()
            .navigationTitle("Feeding rhythm").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { store.persist(); dismiss() }.foregroundStyle(Theme.crust) } }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
        }
    }

    private func nextText(_ d: Date) -> String {
        let h = Int(d.timeIntervalSinceNow / 3600)
        return h <= 0 ? "It's time to feed your starter" : "Next feed in about \(h) hours"
    }
    private func fedNow() {
        store.markFed()
        let c = UNUserNotificationCenter.current()
        c.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            c.removePendingNotificationRequests(withIdentifiers: ["proofd.feed"])
            let content = UNMutableNotificationContent()
            content.title = "Time to feed your starter 🍞"
            content.body = "It's been \(store.feedIntervalH)h — give it a \(store.feedRatio) feed."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(store.feedIntervalH) * 3600, repeats: false)
            c.add(UNNotificationRequest(identifier: "proofd.feed", content: content, trigger: trigger))
        }
    }
}
