import ComposableArchitecture
import SwiftUI

struct Main: ReducerProtocol {
	struct State: Hashable {
		@PresentationState var p2pRequestFlow: Flow.State?
	}

	enum Action: Equatable {
		case task
		case p2pRequestReceived(P2PRequestPack)
		case p2pRequestFlow(PresentationActionOf<Flow>)
	}

	@Dependency(\.p2pClient) var p2pClient

	var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
			case .task:
				return .run { send in
					for await requestPack in await p2pClient.requests() {
						await send(.p2pRequestReceived(requestPack))
					}
				}

			case .p2pRequestReceived(let requestPack):
				state.p2pRequestFlow = .init(requestPack: requestPack)
				return .none
				
			case .p2pRequestFlow:
				return .none
			}
		}
		.presentationDestination(\.$p2pRequestFlow, action: /Action.p2pRequestFlow) {
			Flow()
		}
	}
}

struct MainView: View {
	let store: StoreOf<Main>

	var body: some View {
		ZStack {
			Button("Simulate incoming P2P request") {
				Task {
					await P2PClient.requestChannel.send(.init(
						requests: [
							.name(.init(id: UUID(), metadata: P2PMetadata(), validCharacters: .letters)),
							.quote(.init(id: UUID(), metadata: P2PMetadata(), minimumLength: .random(in: 0..<15))),
							.number(.init(id: UUID(), metadata: P2PMetadata(), validNumbers: 1...10))
						]
					))
				}
			}
		}
		.sheet(
			store: store.scope(
				state: \.$p2pRequestFlow,
				action: { .p2pRequestFlow($0) }
			),
			content: FlowView.init(store:)
		)
		.task {
			await ViewStore(store).send(.task).finish()
		}
	}
}
