import SwiftUI

@main
struct ProofdApp: App {
    @StateObject private var store = Store()
    @StateObject private var pro = ProStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if store.onboarded || ProcessInfo.processInfo.arguments.contains("-skipOnboard") {
                    RootView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
            .environmentObject(pro)
            .tint(Theme.crust)
            .preferredColorScheme(.light)
            .task { await pro.load(); store.isPro = pro.isPro; store.persist() }
            .onChange(of: pro.isPro) { _, v in store.isPro = v; store.persist() }
        }
    }
}
