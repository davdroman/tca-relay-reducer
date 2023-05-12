import ComposableArchitecture
import NavigationTransitions
import NonEmpty
import OrderedCollections
import SwiftUI

struct P2PRequestFlow: ReducerProtocol {
	struct State: Hashable {
		let requests: NonEmpty<[P2PRequest]>

		var root: Path.State
		var path = StackState<Path.State>()

		var responses: OrderedDictionary<P2PRequest, P2PResponse> = [:]

		init(requestPack: P2PRequestPack) {
			self.requests = requestPack.requests
			self.root = .init(for: requestPack.requests.first)
		}
	}

	enum Action: Equatable {
		case root(Path.Action)
		case path(StackAction<Path.State, Path.Action>)
		case dismiss
	}

	struct Path: ReducerProtocol {
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
		Scope(state: \.root, action: /Action.root) {
			Path()
		}
		.forEach(\.path, action: /Action.path) {
			Path()
		}

		Reduce<State, Action> { state, action in
			switch action {
			case .path(.popFrom):
				state.responses.removeLast()
				return .none
			case
				let .root(.relay(request, .nameInput(.continueButtonTapped(output: name)))),
				let .path(.element(_, .relay(request, .nameInput(.continueButtonTapped(output: name))))):
				state.responses[request] = .name(.init(id: request.id, name: name))
				return continueEffect(for: &state)
			case
				let .root(.relay(request, .quoteInput(.continueButtonTapped(output: quote)))),
				let .path(.element(_, .relay(request, .quoteInput(.continueButtonTapped(output: quote))))):
				state.responses[request] = .quote(.init(id: request.id, quote: quote))
				return continueEffect(for: &state)
			case
				let .root(.relay(request, .numberInput(.continueButtonTapped(output: number)))),
				let .path(.element(_, .relay(request, .numberInput(.continueButtonTapped(output: number))))):
				state.responses[request] = .number(.init(id: request.id, number: number))
				return continueEffect(for: &state)
			default:
				return .none
			}
		}
	}

	func continueEffect(for state: inout State) -> EffectTask<Action> {
		if let nextRequest = state.requests.first(where: { state.responses[$0] == nil }) {
			let nextDestination = Path.State(for: nextRequest)
			if state.path.last != nextDestination {
				state.path.append(nextDestination)
			}
			return .none
		} else {
			return .run { [responses = state.responses.values] send in
				@Dependency(\.p2pClient) var p2pClient: P2PClient
				await p2pClient.sendResponse(P2PResponsePack(responses: Array(responses)))
				await send(.dismiss)
			}
		}
	}
}

extension P2PRequestFlow.Path.State {
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
	@Environment(\.dismiss) private var dismiss

	let store: StoreOf<P2PRequestFlow>

	var body: some View {
		NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
			view(for: store.scope(state: \.root, action: { .root($0) }))
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button(action: { dismiss() }) {
							Image(systemName: "xmark").fontWeight(.semibold)
						}
					}
				}
		} destination: { store in
			view(for: store)
		}
		.navigationTransition(.slide)
	}

	func view(for store: StoreOf<P2PRequestFlow.Path>) -> some View {
		SwitchStore(store.relay()) {
			CaseLet(
				state: /P2PRequestFlow.Path.MainState.nameInput,
				action: P2PRequestFlow.Path.MainAction.nameInput,
				then: NameInputView.init(store:)
			)
			CaseLet(
				state: /P2PRequestFlow.Path.MainState.quoteInput,
				action: P2PRequestFlow.Path.MainAction.quoteInput,
				then: QuoteInputView.init(store:)
			)
			CaseLet(
				state: /P2PRequestFlow.Path.MainState.numberInput,
				action: P2PRequestFlow.Path.MainAction.numberInput,
				then: NumberInputView.init(store:)
			)
		}
	}
}
