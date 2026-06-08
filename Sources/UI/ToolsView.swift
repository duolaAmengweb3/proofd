import SwiftUI

struct ToolsView: View {
    @EnvironmentObject var store: Store
    @State private var flour: Double = 500
    @State private var hydration: Double = 75
    @State private var grams: Double = 500
    @State private var ingredient = 0
    @State private var showPaywall = false
    @State private var showAsk = false
    @State private var showRecipes = false

    private let ings = ["Flour", "Water", "Sugar", "Starter"]
    private let gPerCup: [Double] = [120, 237, 200, 227]
    private var cups: Double { grams / gPerCup[ingredient] }
    private var water: Int { Int(flour * hydration / 100) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionLabel(text: "Hydration calculator")
                        sliderRow("Flour", "\(Int(flour)) g", $flour, 200...1200, 25, Theme.ink)
                        sliderRow("Hydration", "\(Int(hydration))%", $hydration, 60...95, 1, Theme.crust)
                        Divider().overlay(Theme.hairline).padding(.vertical, 2)
                        recipeRow("Water", amt(water, 237))
                        recipeRow("Starter (20%)", amt(Int(flour*0.20), 227))
                        recipeRow("Salt (2%)", "\(Int(flour*0.02)) g")
                        if store.useCups { Text("Cups shown — toggle in Settings.").font(.caption2).foregroundStyle(Theme.inkLow) }
                    }.card(20)

                    VStack(alignment: .leading, spacing: 16) {
                        SectionLabel(text: "Grams → cups")
                        Picker("", selection: $ingredient) { ForEach(ings.indices, id: \.self) { Text(ings[$0]).tag($0) } }.pickerStyle(.segmented)
                        sliderRow("Grams", "\(Int(grams)) g", $grams, 10...1000, 5, Theme.ink)
                        HStack { Text("≈").font(.title3).foregroundStyle(Theme.inkLow)
                            Text(fmtCups(cups)).font(.system(.title, design: .rounded).weight(.bold)).foregroundStyle(Theme.crust).monospacedDigit()
                            Text("cups").font(.callout).foregroundStyle(Theme.inkMid); Spacer() }
                    }.card(20)

                    // Ask a sourdough expert (AI Q&A)
                    Button { showAsk = true } label: {
                        toolRow(icon: "bubble.left.and.text.bubble.right", title: "Ask a sourdough question", sub: store.isPro ? "Unlimited" : "\(max(0, Store.freeAsksPerDay - (store.askDate == todayStr() ? store.asksToday : 0))) free today")
                    }.buttonStyle(.plain)

                    // Custom recipes (Pro)
                    Button { store.isPro ? (showRecipes = true) : (showPaywall = true) } label: {
                        toolRow(icon: store.isPro ? "book" : "lock.fill", title: "My recipes", sub: store.isPro ? "\(store.recipes.count) saved" : "Save your own — Pro")
                    }.buttonStyle(.plain)

                    if !store.isPro {
                        Button { showPaywall = true } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "crown.fill").foregroundStyle(Theme.crust)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Unlock Proofd Pro").font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                                    Text("Unlimited diagnoses · feeding schedule · one-time, no subscription").font(.caption).foregroundStyle(Theme.inkMid).multilineTextAlignment(.leading)
                                }
                                Spacer(); Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Theme.inkLow)
                            }.card(18)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 40)
            }
            .screenBackground().navigationTitle("Tools")
            .toolbar { ToolbarItem(placement: .topBarTrailing) {
                Button { store.showScan = true } label: { Image(systemName: "camera.aperture").foregroundStyle(Theme.crust) }.accessibilityLabel("Scan") } }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showAsk) { AskView() }
            .sheet(isPresented: $showRecipes) { RecipesView() }
            .onAppear {
                let a = ProcessInfo.processInfo.arguments
                if a.contains("-ask") { showAsk = true }
                if a.contains("-recipes") { showRecipes = true }
            }
        }
    }

    private func todayStr() -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: Date()) }
    private func toolRow(icon: String, title: String, sub: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(Theme.crust).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                Text(sub).font(.caption).foregroundStyle(Theme.inkMid)
            }
            Spacer(); Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Theme.inkLow)
        }.card(18)
    }
    private func sliderRow(_ k: String, _ v: String, _ b: Binding<Double>, _ r: ClosedRange<Double>, _ step: Double, _ vc: Color) -> some View {
        VStack(spacing: 8) {
            HStack { Text(k).font(.callout).foregroundStyle(Theme.ink); Spacer()
                Text(v).font(.system(.headline, design: .rounded)).foregroundStyle(vc).monospacedDigit() }
            Slider(value: b, in: r, step: step).tint(Theme.crust)
        }
    }
    private func recipeRow(_ k: String, _ v: String) -> some View {
        HStack { Text(k).font(.callout).foregroundStyle(Theme.inkMid); Spacer()
            Text(v).font(.system(.headline, design: .rounded)).foregroundStyle(Theme.ink).monospacedDigit() }
    }
    private func fmtCups(_ c: Double) -> String { let q = (c*4).rounded()/4; return q == q.rounded() ? String(Int(q)) : String(format: "%.2f", q) }
    private func amt(_ g: Int, _ perCup: Double) -> String { store.useCups ? "\(g) g · ≈\(fmtCups(Double(g)/perCup)) c" : "\(g) g" }
}
