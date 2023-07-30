import ComposableArchitecture
import SwiftUI

@main
struct MyApp: App {
	var body: some Scene {
		WindowGroup {
			MainView(
				store: Store(initialState: Main.State()) {
					Main()
				} withDependencies: {
					$0.context = .preview
				}
			)
		}
	}
}
