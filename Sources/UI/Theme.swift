import SwiftUI

// Warm Artisan — flour cream canvas + crust-brown ink + a single caramel-crust accent.
// Editorial bakery character via serif display headers. Solid surfaces only (no glass), per house style.
enum Theme {
    static let canvas   = Color(hex: 0xF4EEE1)   // warm flour cream
    static let surface  = Color(hex: 0xFBF7EE)    // lighter card cream
    static let elevated = Color(hex: 0xFFFFFF)
    static let ink      = Color(hex: 0x2C2016)    // deep crust brown (warm, not gray)
    static let inkMid   = Color(hex: 0x6E5E4C)    // warm taupe
    static let inkLow   = Color(hex: 0xA1907B)
    static let crust    = Color(hex: 0xBE6A37)    // THE accent — caramel crust
    static let crustSoft = Color(hex: 0xBE6A37).opacity(0.12)
    static let hairline = Color(hex: 0x2C2016).opacity(0.10)

    // status (always paired with symbol + text, never color-only)
    static let active  = Color(hex: 0x6E7A4B)     // sage — starter healthy/rising
    static let hungry  = Color(hex: 0xC79A3E)     // amber — needs feeding
    static let alert   = Color(hex: 0xA8472F)     // brick — mold/over-fermented

    // semantic — scales with Dynamic Type (was hardcoded sizes before)
    static func serif(_ style: Font.TextStyle, _ w: Font.Weight = .semibold) -> Font {
        .system(style, design: .serif).weight(w)
    }
}

extension Color {
    init(hex: UInt) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xff)/255, green: Double((hex >> 8) & 0xff)/255, blue: Double(hex & 0xff)/255)
    }
}

// MARK: - Surface modifiers (solid, hairline, restrained shadow — no glass)
extension View {
    func screenBackground() -> some View { background(Theme.canvas.ignoresSafeArea()) }
    func card(_ pad: CGFloat = 18) -> some View {
        self.padding(pad)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Theme.hairline, lineWidth: 1))
            .shadow(color: Color(hex: 0x3A2A1E).opacity(0.06), radius: 14, x: 0, y: 5)
    }
}

struct CrustButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Theme.canvas)
            .frame(maxWidth: .infinity).frame(height: 54)
            .background(Theme.crust, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// small reusable bits
struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.system(size: 11, weight: .semibold)).tracking(1.5).foregroundStyle(Theme.inkLow)
    }
}

struct StatusPill: View {
    let text: String; let icon: String; let color: Color
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 11, weight: .bold))
            Text(text).font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(color.opacity(0.12), in: Capsule())
    }
}
