import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
				MainView(
					store: .init(
						initialState: .init(),
						reducer: Main()
					) {
						$0.context = .preview
					}
				)
        }
    }
}
