import SwiftUI

struct AskView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var q = ""
    @State private var answer = ""
    @State private var loading = false
    @State private var error: String?
    @State private var showPaywall = false
    private let suggestions = ["Why is my crumb gummy?", "How do I get a more open crumb?", "My starter isn't rising — help?", "When is my dough done proofing?"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if answer.isEmpty && !loading {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(text: "Try asking")
                            ForEach(suggestions, id: \.self) { s in
                                Button { q = s } label: {
                                    HStack { Text(s).font(.subheadline).foregroundStyle(Theme.ink); Spacer()
                                        Image(systemName: "arrow.up.left").font(.caption).foregroundStyle(Theme.inkLow) }
                                        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    if loading { HStack { ProgressView().tint(Theme.crust); Text("Thinking…").font(.callout).foregroundStyle(Theme.inkMid) }.padding(.top, 8) }
                    if let error { Text(error).font(.footnote).foregroundStyle(Theme.alert) }
                    if !answer.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel(text: "Proofd says")
                            Text(answer).font(.callout).foregroundStyle(Theme.ink).lineSpacing(5)
                        }.frame(maxWidth: .infinity, alignment: .leading).card(18)
                    }
                }.padding(.horizontal, 20).padding(.top, 8)
            }
            .screenBackground()
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 10) {
                    TextField("Ask anything sourdough…", text: $q, axis: .vertical).lineLimit(1...3)
                        .padding(12).background(Theme.surface, in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.hairline, lineWidth: 1))
                    Button { ask() } label: { Image(systemName: "arrow.up.circle.fill").font(.system(size: 32)).foregroundStyle(q.isEmpty ? Theme.inkLow : Theme.crust) }
                        .disabled(q.isEmpty || loading)
                }.padding(.horizontal, 16).padding(.vertical, 10).background(Theme.canvas)
            }
            .navigationTitle("Ask").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() }.foregroundStyle(Theme.crust) } }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }
    private func ask() {
        guard store.canAsk else { showPaywall = true; return }
        let question = q; loading = true; error = nil; answer = ""
        Task {
            do { let a = try await ProofdAPI.ask(question); store.recordAsk(); answer = a; loading = false; q = "" }
            catch { loading = false; self.error = (error as? LocalizedError)?.errorDescription ?? "Couldn't get an answer. Try again." }
        }
    }
}

struct RecipesView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var showAdd = false
    @State private var name = ""; @State private var flour = 500; @State private var hydration = 75; @State private var note = ""

    var body: some View {
        NavigationStack {
            Group {
                if store.recipes.isEmpty && !showAdd {
                    EmptyState(icon: "book", title: "No recipes yet", message: "Save your go-to formulas so you can reuse them in a tap.", cta: "Add a recipe") { showAdd = true }
                        .padding(.top, 80)
                } else {
                    List {
                        ForEach(store.recipes) { r in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(r.name).font(.headline).foregroundStyle(Theme.ink)
                                Text("\(r.flour)g flour · \(r.hydration)% hydration").font(.subheadline).foregroundStyle(Theme.inkMid)
                                if !r.note.isEmpty { Text(r.note).font(.footnote).foregroundStyle(Theme.inkLow) }
                            }.listRowBackground(Theme.surface)
                        }.onDelete { idx in idx.map { store.recipes[$0] }.forEach(store.deleteRecipe) }
                    }.scrollContentBackground(.hidden).background(Theme.canvas)
                }
            }
            .screenBackground()
            .navigationTitle("My recipes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() }.foregroundStyle(Theme.crust) }
                ToolbarItem(placement: .topBarTrailing) { Button { showAdd = true } label: { Image(systemName: "plus") }.foregroundStyle(Theme.crust) }
            }
            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    Form {
                        TextField("Name (e.g. Country loaf)", text: $name)
                        Stepper("Flour: \(flour) g", value: $flour, in: 200...2000, step: 50)
                        Stepper("Hydration: \(hydration)%", value: $hydration, in: 50...100)
                        TextField("Notes", text: $note, axis: .vertical).lineLimit(2...4)
                    }
                    .scrollContentBackground(.hidden).background(Theme.canvas)
                    .navigationTitle("New recipe").navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) { Button("Cancel") { showAdd = false } }
                        ToolbarItem(placement: .topBarTrailing) { Button("Save") {
                            store.addRecipe(Recipe(name: name.isEmpty ? "Untitled" : name, flour: flour, hydration: hydration, note: note))
                            name = ""; note = ""; showAdd = false
                        }.foregroundStyle(Theme.crust) }
                    }
                }
            }
        }
    }
}
