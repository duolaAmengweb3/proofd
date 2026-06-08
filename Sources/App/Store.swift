import SwiftUI

@MainActor
final class Store: ObservableObject {
    // nav
    @Published var showScan = false
    @AppStorage("proofd.onboarded") var onboarded = false

    // data (persisted)
    @Published var bakes: [Bake] = []
    @Published var lastStarter: Diagnosis?
    @Published var recipes: [Recipe] = []
    @Published var isPro = false
    @Published var useCups = false
    @Published var feedRatio = "1:1:1"
    @Published var feedIntervalH = 12
    @Published var lastFedAt: Date? = nil

    // usage limits
    @Published var scanDate = ""; @Published var scansToday = 0
    @Published var askDate = "";  @Published var asksToday = 0

    static let freePerDay = 3        // diagnoses/day for free
    static let proDailyCap = 40      // anti-abuse cap for Pro
    static let freeAsksPerDay = 2

    private let key = "proofd.store.v1"
    init() {
        load()
        let a = ProcessInfo.processInfo.arguments
        if a.contains("-pro") { isPro = true }
        if a.contains("-seed") && bakes.isEmpty {
            lastStarter = Sample.todayStarter
            bakes = [
                Bake(title: "Country sourdough", dateLabel: "Yesterday", score: 4, note: "Best ear yet. Crumb a little tight.", tint: 0xC9A876, verdict: "Nice spring with a slightly tight crumb near the base.", stateRaw: "peak"),
                Bake(title: "Seeded batard", dateLabel: "3 days ago", score: 3, note: "Underproofed, gummy near base.", tint: 0xB98A55, verdict: "Under-proofed — a faint dense band just above the bottom crust.", stateRaw: "sluggish")
            ]
        }
    }

    var hasStarter: Bool { lastStarter != nil || !bakes.isEmpty }
    private func today() -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: Date()) }

    var scansLeftToday: Int { let n = scanDate == today() ? scansToday : 0; return max(0, Self.freePerDay - n) }
    var canDiagnose: Bool {
        let n = scanDate == today() ? scansToday : 0
        return isPro ? n < Self.proDailyCap : n < Self.freePerDay
    }
    func recordDiagnose() {
        if scanDate != today() { scanDate = today(); scansToday = 0 }
        scansToday += 1; save()
    }
    var canAsk: Bool {
        let n = askDate == today() ? asksToday : 0
        return isPro || n < Self.freeAsksPerDay
    }
    func recordAsk() {
        if askDate != today() { askDate = today(); asksToday = 0 }
        asksToday += 1; save()
    }

    func setStarter(_ d: Diagnosis) { lastStarter = d; save() }
    func addBake(_ b: Bake) { bakes.insert(b, at: 0); save() }
    func saveDiagnosisAsBake(_ d: Diagnosis) {
        if d.kind == "Starter" { setStarter(d) }
        else {
            let f = DateFormatter(); f.dateFormat = "MMM d"
            addBake(Bake(title: "Sourdough — \(f.string(from: Date()))", dateLabel: "Today",
                         score: d.state == .peak ? 5 : (d.state == .sluggish ? 3 : 2),
                         note: d.verdict, tint: 0xC9A876, verdict: d.verdict, stateRaw: d.state.rawValue))
        }
    }
    var crumbBakes: [Bake] { bakes.filter { $0.verdict != nil } }
    func addRecipe(_ r: Recipe) { recipes.insert(r, at: 0); save() }
    func deleteRecipe(_ r: Recipe) { recipes.removeAll { $0.id == r.id }; save() }
    func markFed() { lastFedAt = Date(); save() }
    var nextFeed: Date? { lastFedAt.map { $0.addingTimeInterval(Double(feedIntervalH) * 3600) } }

    var totalBakes: Int { bakes.count }
    var avgScore: Double { bakes.isEmpty ? 0 : Double(bakes.map(\.score).reduce(0,+)) / Double(bakes.count) }

    // MARK: persistence
    private struct Snap: Codable {
        var bakes: [Bake]; var lastStarter: Diagnosis?; var recipes: [Recipe]
        var isPro: Bool; var useCups: Bool; var feedRatio: String; var feedIntervalH: Int; var lastFedAt: Date?
        var scanDate: String; var scansToday: Int; var askDate: String; var asksToday: Int
    }
    private func save() {
        let s = Snap(bakes: bakes, lastStarter: lastStarter, recipes: recipes, isPro: isPro, useCups: useCups,
                     feedRatio: feedRatio, feedIntervalH: feedIntervalH, lastFedAt: lastFedAt,
                     scanDate: scanDate, scansToday: scansToday, askDate: askDate, asksToday: asksToday)
        if let d = try? JSONEncoder().encode(s) { UserDefaults.standard.set(d, forKey: key) }
    }
    private func load() {
        guard let d = UserDefaults.standard.data(forKey: key), let s = try? JSONDecoder().decode(Snap.self, from: d) else { return }
        bakes = s.bakes; lastStarter = s.lastStarter; recipes = s.recipes; isPro = s.isPro; useCups = s.useCups
        feedRatio = s.feedRatio; feedIntervalH = s.feedIntervalH; lastFedAt = s.lastFedAt
        scanDate = s.scanDate; scansToday = s.scansToday; askDate = s.askDate; asksToday = s.asksToday
    }
    func persist() { save() }
}
