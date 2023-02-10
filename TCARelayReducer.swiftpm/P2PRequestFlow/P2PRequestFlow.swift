import ComposableArchitecture
import SwiftUI

struct P2PRequestFlow: ReducerProtocol {
	struct State: Hashable {
		var requestPack: P2PRequestPack

		var responses: [P2PRequest: P2PResponse] = [:]

		init(requestPack: P2PRequestPack) {
			self.requestPack = requestPack
		}
	}

	struct Action: Equatable {
//		case name()
	}
}

struct P2PRequestFlowView: View {
	let store: StoreOf<Flow>

	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundColor(.accentColor)
			Text("Hello, world!")
		}
	}
}
