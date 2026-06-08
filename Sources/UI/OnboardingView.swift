import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: Store
    private let points: [(String, String, String)] = [
        ("camera.aperture", "Read your starter", "Snap it and Proofd tells you if it's ready, hungry, or off — and what to do next."),
        ("birthday.cake", "Diagnose your crumb", "Cut a loaf, take a photo, and find out exactly what went wrong this time."),
        ("checkmark.shield", "One-time, honest", "Pay once if you love it. No monthly fees, no timer pop-ups, no trial traps.")
    ]
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 30)
            VStack(spacing: 10) {
                ZStack { Circle().fill(Theme.crustSoft).frame(width: 96, height: 96)
                    Image(systemName: "waterbottle.fill").font(.system(size: 42)).foregroundStyle(Theme.crust) }
                Text("Proofd").font(Theme.serif(.largeTitle, .bold)).foregroundStyle(Theme.ink)
                Text("Your sourdough, finally figured out.").font(.callout).foregroundStyle(Theme.inkMid)
            }
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 22) {
                ForEach(points, id: \.1) { p in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: p.0).font(.title3).foregroundStyle(Theme.crust).frame(width: 30)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(p.1).font(.headline).foregroundStyle(Theme.ink)
                            Text(p.2).font(.subheadline).foregroundStyle(Theme.inkMid).lineSpacing(2)
                        }
                    }
                }
            }.padding(.horizontal, 28)
            Spacer()
            VStack(spacing: 10) {
                Button { store.onboarded = true; store.showScan = true } label: { Text("Scan my starter") }.buttonStyle(CrustButton())
                Button { store.onboarded = true } label: { Text("I'll explore first").font(.subheadline.weight(.medium)).foregroundStyle(Theme.inkMid) }
            }.padding(.horizontal, 24).padding(.bottom, 16)
        }
        .screenBackground()
    }
}
