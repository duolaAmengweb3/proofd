import SwiftUI

enum StarterState: String, Codable { case rising, peak, hungry, sluggish, fresh, mold
    var label: String { ["rising":"Rising","peak":"At peak","hungry":"Hungry","sluggish":"Sluggish","fresh":"Just fed","mold":"Possible mold"][rawValue] ?? "Rising" }
    var icon: String { ["rising":"arrow.up.right","peak":"checkmark.seal.fill","hungry":"fork.knife","sluggish":"tortoise.fill","fresh":"drop.fill","mold":"exclamationmark.triangle.fill"][rawValue] ?? "arrow.up.right" }
    var color: Color { switch self { case .rising,.peak,.fresh: return Theme.active; case .hungry,.sluggish: return Theme.hungry; case .mold: return Theme.alert } }
    var rise: Double { ["rising":0.7,"peak":1.0,"hungry":0.25,"sluggish":0.4,"fresh":0.1,"mold":0.5][rawValue] ?? 0.5 }
}

struct Diagnosis: Identifiable, Codable, Hashable {
    var id = UUID()
    var kind: String            // "Starter" / "Crumb"
    var state: StarterState
    var verdict: String
    var detail: String
    var actions: [String]
    var confidence: String
    var date: Date = Date()
}

struct Bake: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var dateLabel: String
    var score: Int
    var note: String
    var tint: UInt
    var date: Date = Date()
    var verdict: String? = nil          // the diagnosis it was saved from (for before/after compare)
    var stateRaw: String? = nil
    var state: StarterState { stateRaw.flatMap { StarterState(rawValue: $0) } ?? .peak }
}

struct Recipe: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var flour: Int
    var hydration: Int
    var note: String
}

enum Sample {
    static let todayStarter = Diagnosis(
        kind: "Starter", state: .rising,
        verdict: "Almost there — give it about 3 more hours.",
        detail: "Your starter has roughly doubled with an even, domed surface and a web of medium bubbles. It's active and climbing, but hasn't peaked yet. Hold off on mixing your dough until it crests and just begins to flatten on top.",
        actions: ["Wait ~3h, then check for a domed peak", "Do a float test before mixing", "Room looks cool — peak may run a little late"],
        confidence: "High")

    static let crumbDiag = Diagnosis(
        kind: "Crumb", state: .sluggish,
        verdict: "Slightly under-proofed — close, but push it further.",
        detail: "The crumb is a touch tight near the base with a faint dense band just above the bottom crust. Holes are uneven and the spring is good but not open. This reads as under-fermentation rather than a shaping issue.",
        actions: ["Add 45–60 min to your bulk ferment", "Watch for ~50% rise + jiggle, not the clock", "Keep dough at 76°F if you can"],
        confidence: "Medium")

    static let bakes: [Bake] = [
        Bake(title: "Country sourdough", dateLabel: "Yesterday", score: 4, note: "Best ear yet. Crumb a little tight.", tint: 0xC9A876),
        Bake(title: "Seeded batard", dateLabel: "3 days ago", score: 3, note: "Underproofed, gummy near base.", tint: 0xB98A55),
        Bake(title: "Rosemary boule", dateLabel: "Last week", score: 5, note: "Open crumb, blistered crust 🔥", tint: 0xCBB68C)
    ]
}
