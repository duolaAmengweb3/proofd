import SwiftUI
import PhotosUI

struct ScanView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var mode = 0          // 0 starter, 1 crumb
    @State private var analyzing = false
    @State private var result: Diagnosis?
    @State private var error: String?
    @State private var showCamera = false
    @State private var pick: PhotosPickerItem?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Picker("", selection: $mode) { Text("Starter").tag(0); Text("Crumb / loaf").tag(1) }
                    .pickerStyle(.segmented).padding(.top, 6)

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.elevated)
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [9,7])).foregroundStyle(Theme.crust.opacity(0.5)))
                    if analyzing {
                        VStack(spacing: 14) { ProgressView().controlSize(.large).tint(Theme.crust)
                            Text("Reading your \(mode == 0 ? "starter" : "crumb")…").font(.callout).foregroundStyle(Theme.inkMid) }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: mode == 0 ? "waterbottle.fill" : "birthday.cake").font(.system(size: 46)).foregroundStyle(Theme.crust.opacity(0.85))
                            Text(mode == 0 ? "Side-on photo of your jar\nworks best" : "Photo of the cut crumb")
                                .font(.subheadline).foregroundStyle(Theme.inkMid).multilineTextAlignment(.center)
                        }
                    }
                }.frame(height: 300)

                if let error { Text(error).font(.footnote).foregroundStyle(Theme.alert).multilineTextAlignment(.center) }
                if !store.isPro { Text("\(store.scansLeftToday) free diagnoses left today").font(.caption).foregroundStyle(Theme.inkLow) }

                VStack(spacing: 12) {
                    Button { start { showCamera = true } } label: {
                        HStack(spacing: 9) { Image(systemName: "camera.fill"); Text("Take photo") }
                    }.buttonStyle(CrustButton()).disabled(analyzing)
                    PhotosPicker(selection: $pick, matching: .images) {
                        Label("Choose from library", systemImage: "photo.on.rectangle").font(.subheadline.weight(.medium)).foregroundStyle(Theme.ink)
                    }.disabled(analyzing)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .screenBackground()
            .navigationTitle("Diagnose").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { dismiss() } label: { Image(systemName: "xmark").foregroundStyle(Theme.inkMid) } } }
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .fullScreenCover(isPresented: $showCamera) { CameraPicker { img in run(img) }.ignoresSafeArea() }
            .fullScreenCover(item: $result) { d in DiagnosisView(d: d) }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .onChange(of: pick) { _, v in if v != nil { start { Task { await loadPick(v) } } } }
        }
    }

    private func start(_ go: () -> Void) {
        error = nil
        guard store.canDiagnose else { showPaywall = true; return }
        go()
    }
    private func loadPick(_ item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) else { return }
        run(img)
    }
    private func run(_ img: UIImage) {
        guard let data = img.jpegForUpload() else { return }
        analyzing = true; error = nil
        Task {
            do {
                let d = try await ProofdAPI.diagnose(image: data, mode: mode == 0 ? "starter" : "crumb")
                store.recordDiagnose()
                analyzing = false; result = d
            } catch {
                analyzing = false; self.error = (error as? LocalizedError)?.errorDescription ?? "Couldn't read that photo. Try again."
            }
        }
    }
}
