import SwiftUI

// The money screen — an editorial "verdict" rather than a sterile AI readout.
struct DiagnosisView: View {
    let d: Diagnosis
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            StatusPill(text: d.state.label, icon: d.state.icon, color: d.state.color)
                            Spacer()
                            HStack(spacing: 5) { Image(systemName: "checkmark.shield.fill").font(.caption)
                                Text("\(d.confidence) confidence").font(.caption.weight(.semibold)) }.foregroundStyle(Theme.inkLow)
                        }
                        Text(d.verdict).font(Theme.serif(.title2, .bold)).foregroundStyle(Theme.ink).fixedSize(horizontal: false, vertical: true).lineSpacing(3)
                    }.frame(maxWidth: .infinity, alignment: .leading).card(20)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "What Proofd sees")
                        Text(d.detail).font(.callout).foregroundStyle(Theme.inkMid).lineSpacing(5)
                    }.frame(maxWidth: .infinity, alignment: .leading).card(18)

                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(text: "Do this next")
                        VStack(alignment: .leading, spacing: 12) { ForEach(d.actions, id: \.self) { ActionChip(text: $0) } }
                    }.frame(maxWidth: .infinity, alignment: .leading).card(18)

                    if d.state == .mold {
                        HStack(alignment: .top, spacing: 9) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Theme.alert)
                            Text("If you see fuzzy or colored spots, discard and start a fresh starter — don't risk it.").font(.footnote).foregroundStyle(Theme.ink)
                        }.padding(14).background(Theme.alert.opacity(0.08), in: RoundedRectangle(cornerRadius: 14)).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // crumb before/after — a Pro perk
                    if d.kind == "Crumb" {
                        Button { if !store.isPro { showPaywall = true } } label: {
                            HStack(spacing: 10) {
                                Image(systemName: store.isPro ? "rectangle.on.rectangle" : "lock.fill").foregroundStyle(Theme.crust)
                                Text(store.isPro ? "Compare with a previous bake" : "Compare before / after — Pro").font(.subheadline.weight(.medium)).foregroundStyle(Theme.ink)
                                Spacer(); Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Theme.inkLow)
                            }.padding(16).background(Theme.surface, in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.hairline, lineWidth: 1))
                        }.buttonStyle(.plain)
                    }

                    HStack(spacing: 12) {
                        Button { store.saveDiagnosisAsBake(d); saved = true; dismiss() } label: {
                            Label(saved ? "Saved" : "Save to journal", systemImage: saved ? "checkmark" : "tray.and.arrow.down")
                        }.buttonStyle(CrustButton())
                        ShareLink(item: shareText) {
                            Image(systemName: "square.and.arrow.up").frame(width: 54, height: 54)
                                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16)).foregroundStyle(Theme.ink)
                                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.hairline, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 36)
            }
            .screenBackground()
            .navigationTitle("\(d.kind) diagnosis").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { dismiss() } label: { Image(systemName: "xmark").foregroundStyle(Theme.inkMid) } } }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }
    private var shareText: String { "Proofd — \(d.kind): \(d.verdict)\n\n\(d.detail)" }
}
