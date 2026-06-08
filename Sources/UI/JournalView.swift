import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: Store
    @State private var showPaywall = false
    private var seeded: Bool { ProcessInfo.processInfo.arguments.contains("-seed") }
    private var bakes: [Bake] { store.bakes.isEmpty && seeded ? Sample.bakes : store.bakes }

    var body: some View {
        NavigationStack {
            ScrollView {
                if bakes.isEmpty {
                    EmptyState(icon: "book.closed", title: "No bakes yet",
                               message: "Save a diagnosis after your next bake and it lands here — so you can watch your loaves get better over time.",
                               cta: "Diagnose a bake") { store.showScan = true }
                        .padding(.top, 80).padding(.horizontal, 4)
                } else { populated }
            }
            .screenBackground().navigationTitle("Journal")
            .toolbar { ToolbarItem(placement: .topBarTrailing) {
                Button { store.showScan = true } label: { Image(systemName: "camera.aperture").foregroundStyle(Theme.crust) }.accessibilityLabel("Scan") } }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 20) {
                statBlock("\(bakes.count)", "bakes logged", Theme.crust)
                Divider().frame(height: 44).overlay(Theme.hairline)
                statBlock(String(format: "%.1f", avg), "avg score", Theme.ink)
                Spacer()
            }.card(20)

            HStack {
                SectionLabel(text: "Your bakes"); Spacer()
                if store.isPro {
                    ShareLink(item: exportPDF()) { Label("PDF", systemImage: "square.and.arrow.up").font(.footnote.weight(.medium)).foregroundStyle(Theme.crust) }
                } else {
                    Button { showPaywall = true } label: { Label("Export PDF", systemImage: "lock.fill").font(.footnote.weight(.medium)).foregroundStyle(Theme.inkLow) }
                }
            }

            VStack(spacing: 16) {
                ForEach(Array(bakes.enumerated()), id: \.element.id) { i, b in
                    BakeRow(bake: b)
                    if i != bakes.count - 1 { Divider().overlay(Theme.hairline) }
                }
            }.card(18)
        }
        .padding(.horizontal, 20).padding(.bottom, 40)
    }

    private var avg: Double { bakes.isEmpty ? 0 : Double(bakes.map(\.score).reduce(0,+)) / Double(bakes.count) }

    private func statBlock(_ n: String, _ label: String, _ c: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(n).font(.system(size: 44, weight: .bold, design: .rounded)).foregroundStyle(c).monospacedDigit().minimumScaleFactor(0.6)
            Text(label).font(.footnote).foregroundStyle(Theme.inkMid)
        }
    }

    // Pro: printable PDF of the bake journal
    private func exportPDF() -> URL {
        let pageW: CGFloat = 612, pageH: CGFloat = 792, m: CGFloat = 48
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Proofd-Journal.pdf")
        let df = DateFormatter(); df.dateStyle = .long
        try? UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageW, height: pageH)).writePDF(to: url) { ctx in
            ctx.beginPage(); var y: CGFloat = m
            func line(_ s: String, _ f: UIFont, _ col: UIColor = .black, _ gap: CGFloat = 18) {
                if y > pageH - m { ctx.beginPage(); y = m }
                (s as NSString).draw(at: CGPoint(x: m, y: y), withAttributes: [.font: f, .foregroundColor: col]); y += gap
            }
            line("Proofd — Bake Journal", .systemFont(ofSize: 22, weight: .bold), .black, 30)
            line("\(bakes.count) bakes · avg score \(String(format: "%.1f", avg))", .systemFont(ofSize: 12), .gray, 24)
            for b in bakes {
                line(b.title, .systemFont(ofSize: 14, weight: .semibold), .black, 17)
                line("\(b.dateLabel) · score \(b.score)/5", .systemFont(ofSize: 11), .gray, 15)
                if !b.note.isEmpty { line(b.note, .systemFont(ofSize: 12), .darkGray, 16) }
                y += 8
            }
        }
        return url
    }
}
