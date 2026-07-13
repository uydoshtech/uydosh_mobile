import SwiftUI

@main
struct UyDoshAppClipApp: App {
    @StateObject private var router = AppClipRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    guard let url = activity.webpageURL else { return }
                    router.handleInvocationURL(url)
                }
                .task {
                    #if DEBUG
                    // Xcode's debugger turns the _XCAppClipURL scheme variable
                    // into a real NSUserActivity, but `simctl launch` does not.
                    // Reading it directly keeps command-line testing possible.
                    if let raw = ProcessInfo.processInfo.environment["_XCAppClipURL"],
                       let url = URL(string: raw) {
                        router.handleInvocationURL(url)
                        return
                    }
                    #endif
                    // The invocation NSUserActivity is not guaranteed to be
                    // delivered immediately (or at all, e.g. when the clip is
                    // launched directly). Give it a moment before showing the
                    // invalid-session screen.
                    try? await Task.sleep(for: .seconds(2))
                    router.invocationTimedOut()
                }
        }
    }
}
