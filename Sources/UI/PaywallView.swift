import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var pro: ProStore
    @Environment(\.dismiss) private var dismiss
    private let perks: [(String, String)] = [
        ("infinity", "Unlimited starter & crumb diagnoses"),
        ("chart.line.uptrend.xyaxis", "Crumb diagnosis with before / after"),
        ("bell.badge", "Smart feeding schedule & reminders"),
        ("doc.richtext", "Export your bake journal as PDF"),
        ("book", "Save your own recipes & unlimited Q&A")
    ]
    var body: some View {
        VStack(spacing: 0) {
            HStack { Spacer(); Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.inkMid).padding(8) } }
                .padding(.horizontal, 12).padding(.top, 8)
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        ZStack { Circle().fill(Theme.crustSoft).frame(width: 84, height: 84)
                            Image(systemName: "crown.fill").font(.system(size: 34)).foregroundStyle(Theme.crust) }
                        Text("Proofd Pro").font(Theme.serif(.title, .bold)).foregroundStyle(Theme.ink)
                        Text("Bake better, every loaf.").font(.subheadline).foregroundStyle(Theme.inkMid)
                    }.padding(.top, 4)
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(perks, id: \.1) { p in
                            HStack(spacing: 12) {
                                Image(systemName: p.0).font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.crust).frame(width: 26)
                                Text(p.1).font(.subheadline).foregroundStyle(Theme.ink); Spacer()
                            }
                        }
                    }.card(18)
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.shield.fill").font(.caption).foregroundStyle(Theme.active)
                        Text("Other sourdough apps charge every month. Proofd is one-time — pay once, own it forever. No timer pop-ups, no trial traps, no surprise charges.")
                            .font(.caption).foregroundStyle(Theme.inkMid).lineSpacing(2)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.padding(16).padding(.bottom, 120)
            }
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Button { Task { if await pro.purchase() { dismiss() } } } label: {
                    if pro.purchasing { ProgressView().tint(Theme.canvas) }
                    else { Text("Unlock Proofd Pro — \(pro.priceText) once") }
                }.buttonStyle(CrustButton()).disabled(pro.purchasing)
                HStack(spacing: 16) {
                    Button("Restore") { Task { await pro.restore(); if pro.isPro { dismiss() } } }
                    Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Link("Privacy", destination: URL(string: "https://duolaamengweb3.github.io/proofd/privacy.html")!)
                }.font(.caption).foregroundStyle(Theme.inkLow)
            }.padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 8).background(Theme.canvas)
        }
    }
}
