import SwiftUI

// Pro: before/after — compare this crumb diagnosis with a previous saved bake.
struct CompareView: View {
    let current: Diagnosis
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var picked: Bake?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if picked == nil {
                        SectionLabel(text: "Compare with")
                        if store.crumbBakes.isEmpty {
                            Text("Save another crumb diagnosis first, then come back to see what changed bake to bake.")
                                .font(.callout).foregroundStyle(Theme.inkMid).lineSpacing(4).padding(.top, 6)
                        } else {
                            ForEach(store.crumbBakes) { b in
                                Button { picked = b } label: {
                                    HStack { VStack(alignment: .leading, spacing: 3) {
                                        Text(b.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                                        Text(b.verdict ?? "").font(.caption).foregroundStyle(Theme.inkMid).lineLimit(1) }
                                        Spacer(); Image(systemName: "chevron.right").font(.footnote).foregroundStyle(Theme.inkLow)
                                    }.card(16)
                                }.buttonStyle(.plain)
                            }
                        }
                    } else if let p = picked {
                        HStack(alignment: .top, spacing: 12) {
                            compareCol("Then", p.state, p.verdict ?? "", p.title)
                            compareCol("Now", current.state, current.verdict, "This bake")
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            SectionLabel(text: "What changed")
                            Text(changeText(from: p.state, to: current.state)).font(.callout).foregroundStyle(Theme.ink).lineSpacing(4)
                        }.frame(maxWidth: .infinity, alignment: .leading).card(18)
                        Button { picked = nil } label: { Text("Pick a different bake").font(.subheadline.weight(.medium)).foregroundStyle(Theme.crust) }
                    }
                }.padding(.horizontal, 20).padding(.top, 10)
            }
            .screenBackground()
            .navigationTitle("Before / after").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() }.foregroundStyle(Theme.crust) } }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
        }
    }

    private func compareCol(_ when: String, _ st: StarterState, _ verdict: String, _ title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(when.uppercased()).font(.caption2.weight(.bold)).tracking(1).foregroundStyle(Theme.inkLow)
            StatusPill(text: st.label, icon: st.icon, color: st.color)
            Text(verdict).font(.footnote).foregroundStyle(Theme.ink).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            Text(title).font(.caption2).foregroundStyle(Theme.inkLow)
        }.frame(maxWidth: .infinity, alignment: .leading).card(16)
    }
    private func changeText(from: StarterState, to: StarterState) -> String {
        if from == to { return "Same read as last time — keep the variable you changed and push a little further in that direction." }
        if to == .peak { return "Big improvement — whatever you adjusted is working. Lock in this routine." }
        if from == .sluggish && to == .hungry { return "You went from under to over — ease back: shorten the bulk ferment a touch from this bake." }
        if from == .hungry && to == .sluggish { return "You went from over to under — give it a little more bulk time next round." }
        return "The read shifted — note what you changed (time, temp, flour) so you can repeat or undo it."
    }
}
