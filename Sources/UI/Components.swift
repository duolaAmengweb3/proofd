import SwiftUI

// The product's hero metaphor: a proofing jar showing how far the starter has risen
// from its fed line toward peak. Solid surfaces, hand-drawn warmth — no glass.
struct RiseGauge: View {
    let level: Double               // 0...1 (current height in jar)
    let color: Color
    var fedLine: Double = 0.18      // where it sat right after feeding
    var height: CGFloat = 150

    // deterministic bubble field (no Math.random — keeps screenshots stable)
    private let bubbles: [(CGFloat, CGFloat, CGFloat)] = [
        (0.28,0.18,7),(0.62,0.30,5),(0.45,0.55,9),(0.74,0.62,6),
        (0.22,0.70,5),(0.55,0.82,7),(0.38,0.36,4),(0.70,0.88,4)
    ]

    var body: some View {
        let w = height * 0.64
        let innerH = height - 18
        let fillH = max(16, innerH * level)
        ZStack {
            // jar lid rim
            Capsule().fill(Theme.surface).overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1.5))
                .frame(width: w + 12, height: 12)
                .frame(maxHeight: .infinity, alignment: .top)
            // jar body
            VStack(spacing: 0) {
                Spacer(minLength: 14)
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.elevated)
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.hairline, lineWidth: 1.5))
                    // gradation ticks (right inside edge)
                    VStack(spacing: innerH/5) {
                        ForEach(0..<4, id: \.self) { _ in
                            HStack { Spacer(); Rectangle().fill(Theme.hairline).frame(width: 9, height: 1) }
                        }
                    }.padding(.vertical, 14).padding(.trailing, 6)

                    // the starter fill, with a domed top + bubbles
                    ZStack(alignment: .top) {
                        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 22, bottomLeading: 13, bottomTrailing: 13, topTrailing: 22), style: .continuous)
                            .fill(LinearGradient(colors: [color.opacity(0.92), color.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                        ForEach(bubbles.indices, id: \.self) { i in
                            Circle().fill(Theme.canvas.opacity(0.45))
                                .frame(width: bubbles[i].2, height: bubbles[i].2)
                                .position(x: bubbles[i].0 * (w-10), y: 14 + bubbles[i].1 * (fillH-18))
                        }
                    }
                    .frame(width: w - 8, height: fillH)
                    .padding(.bottom, 4)

                    // fed line (dashed) — baseline after feeding
                    Rectangle().fill(Theme.inkLow).frame(height: 1)
                        .frame(width: w - 4).overlay(alignment: .leading) { Text("FED").font(.system(size: 7, weight: .bold)).foregroundStyle(Theme.inkLow).offset(x: 2, y: -7) }
                        .padding(.bottom, max(8, innerH * fedLine))
                }
                .frame(width: w, height: innerH)
                .overlay(alignment: .top) {
                    // peak target line
                    VStack(spacing: 1) {
                        Rectangle().fill(Theme.crust).frame(height: 1.5).overlay(GeometryReader { _ in })
                        Text("PEAK").font(.system(size: 7.5, weight: .bold)).tracking(1).foregroundStyle(Theme.crust)
                    }.frame(width: w).padding(.top, 6)
                }
            }
        }
        .frame(width: w + 18, height: height)
    }
}

struct BakeRow: View {
    let bake: Bake
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: bake.tint), Color(hex: bake.tint).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: "fork.knife").font(.system(size: 18)).foregroundStyle(Theme.canvas.opacity(0.85)))
            VStack(alignment: .leading, spacing: 3) {
                Text(bake.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                Text(bake.note).font(.footnote).foregroundStyle(Theme.inkMid).lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 1) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < bake.score ? "circle.fill" : "circle")
                            .font(.system(size: 6)).foregroundStyle(i < bake.score ? Theme.crust : Theme.inkLow.opacity(0.4))
                    }
                }
                Text(bake.dateLabel).font(.caption).foregroundStyle(Theme.inkLow)
            }
        }
    }
}

struct ActionChip: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "arrow.turn.down.right").font(.footnote.weight(.semibold)).foregroundStyle(Theme.crust).padding(.top, 2)
            Text(text).font(.subheadline).foregroundStyle(Theme.ink).lineSpacing(2)
            Spacer(minLength: 0)
        }
    }
}

// Reusable empty state per house spec (symbol + why + CTA).
struct EmptyState: View {
    let icon: String; let title: String; let message: String; let cta: String?; var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 14) {
            ZStack { Circle().fill(Theme.crustSoft).frame(width: 96, height: 96)
                Image(systemName: icon).font(.system(size: 38)).foregroundStyle(Theme.crust) }
            Text(title).font(Theme.serif(.title3, .bold)).foregroundStyle(Theme.ink).multilineTextAlignment(.center)
            Text(message).font(.subheadline).foregroundStyle(Theme.inkMid).multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
            if let cta, let action {
                Button(action: action) { Text(cta) }.buttonStyle(CrustButton()).padding(.horizontal, 40).padding(.top, 4)
            }
        }
    }
}
