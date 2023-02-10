import ComposableArchitecture
import NavigationTransitions
import NonEmpty
import SwiftUI

struct P2PRequestFlow: ReducerProtocol {
	struct State: Hashable {
		let requests: NonEmpty<[P2PRequest]>

		let root: Destinations.State
		@NavigationStateOf<Destinations>
		var path

		var responses: [P2PRequest: P2PResponse] = [:]

		init(requestPack: P2PRequestPack) {
			self.requests = requestPack.requests
			self.root = .init(for: requestPack.requests.first)
		}
	}

	enum Action: Equatable {
		case root(Destinations.Action)
		case path(NavigationActionOf<Destinations>)
	}

	struct Destinations: ReducerProtocol {
		typealias State = RelayState<P2PRequest, MainState>
		typealias Action = RelayAction<P2PRequest, MainAction>

		enum MainState: Hashable {
			case nameInput(NameInput.State)
			case quoteInput(QuoteInput.State)
			case numberInput(NumberInput.State)
		}

		enum MainAction: Equatable {
			case nameInput(NameInput.Action)
			case quoteInput(QuoteInput.Action)
			case numberInput(NumberInput.Action)
		}

		var body: some ReducerProtocolOf<Self> {
			Relay {
				Scope(state: /MainState.nameInput, action: /MainAction.nameInput) {
					NameInput()
				}
				Scope(state: /MainState.quoteInput, action: /MainAction.quoteInput) {
					QuoteInput()
				}
				Scope(state: /MainState.numberInput, action: /MainAction.numberInput) {
					NumberInput()
				}
			}
		}
	}

	var body: some ReducerProtocolOf<Self> {
		Reduce<State, Action> { state, action in
			switch action {
			case
				let .root(.relay(request, .nameInput(.continueButtonTapped(output: name)))),
				let .path(.element(_, .relay(request, .nameInput(.continueButtonTapped(output: name))))):
				state.responses[request] = .name(.init(id: request.id, name: name))
				return .none
			case
				let .root(.relay(request, .quoteInput(.continueButtonTapped(output: quote)))),
				let .path(.element(_, .relay(request, .quoteInput(.continueButtonTapped(output: quote))))):
				state.responses[request] = .quote(.init(id: request.id, quote: quote))
				return .none
			case
				let .root(.relay(request, .numberInput(.continueButtonTapped(output: number)))),
				let .path(.element(_, .relay(request, .numberInput(.continueButtonTapped(output: number))))):
				state.responses[request] = .number(.init(id: request.id, number: number))
				return .none
			default:
				return .none
			}
		}
		.navigationDestination(\.$path, action: /Action.path) {
			Destinations()
		}
	}
}

extension P2PRequestFlow.Destinations.State {
	init(for anyRequest: P2PRequest) {
		switch anyRequest {
		case .name(let request):
			self = .relayed(anyRequest, with: .nameInput(.init(
				validCharacters: request.validCharacters
			)))
		case .quote(let request):
			self = .relayed(anyRequest, with: .quoteInput(.init(
				minimumLength: request.minimumLength
			)))
		case .number(let request):
			self = .relayed(anyRequest, with: .numberInput(.init(
				validNumbers: request.validNumbers
			)))
		}
	}
}

struct P2PRequestFlowView: View {
	let store: StoreOf<P2PRequestFlow>

	var body: some View {
		NavigationStackStore(store.scope(state: \.$path, action: { .path($0) })) {
			view(for: store.scope(state: \.root, action: { .root($0) }))
				.navigationDestination(
					store: store.scope(state: \.$path, action: { .path($0) }),
					destination: view(for:)
				)
		}
		.navigationTransition(.slide)
	}

	func view(for store: StoreOf<P2PRequestFlow.Destinations>) -> some View {
		SwitchStore(store.relay()) {
			CaseLet(
				state: /P2PRequestFlow.Destinations.MainState.nameInput,
				action: P2PRequestFlow.Destinations.MainAction.nameInput,
				then: NameInputView.init(store:)
			)
			CaseLet(
				state: /P2PRequestFlow.Destinations.MainState.quoteInput,
				action: P2PRequestFlow.Destinations.MainAction.quoteInput,
				then: QuoteInputView.init(store:)
			)
			CaseLet(
				state: /P2PRequestFlow.Destinations.MainState.numberInput,
				action: P2PRequestFlow.Destinations.MainAction.numberInput,
				then: NumberInputView.init(store:)
			)
		}
	}
}
