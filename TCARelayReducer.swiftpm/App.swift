import ComposableArchitecture
import SwiftUI

@main
struct MyApp: App {
	var body: some Scene {
		WindowGroup {
			MainView(
				store: Store(
					initialState: Main.State(),
					reducer: Main()
				) {
					$0.context = .preview
				}
			)
		}
	}
}
