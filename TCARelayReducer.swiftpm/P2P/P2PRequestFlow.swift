import ComposableArchitecture
import NavigationTransitions
import NonEmpty
import OrderedCollections
import SwiftUI

struct P2PRequestFlow: Reducer {
	struct State: Equatable {
		let requests: NonEmpty<[P2PRequest]>

		var root: Path.State
		var path = StackState<Path.State>()

		var currentRequest: P2PRequest {
			switch path.last ?? root {
			case .nameInput:
				return requests.first(where: { $0.is(\.name) })!
			case .quoteInput:
				return requests.first(where: { $0.is(\.quote) })!
			case .numberInput:
				return requests.first(where: { $0.is(\.number) })!
			}
		}

		var responses: OrderedDictionary<P2PRequest, P2PResponse> = [:]

		init(requestPack: P2PRequestPack) {
			self.requests = requestPack.requests
			self.root = .init(for: requestPack.requests.first)
		}
	}

	@CasePathable
	enum Action {
		case root(Path.Action)
		case path(StackAction<Path.State, Path.Action>)
		case dismiss
	}

	struct Path: Reducer {
		@CasePathable
		enum State: Equatable {
			case nameInput(NameInput.State)
			case quoteInput(QuoteInput.State)
			case numberInput(NumberInput.State)
		}

		@CasePathable
		enum Action {
			case nameInput(NameInput.Action)
			case quoteInput(QuoteInput.Action)
			case numberInput(NumberInput.Action)
		}

		var body: some ReducerOf<Self> {
			Scope(state: \.nameInput, action: \.nameInput) {
				NameInput()
			}
			Scope(state: \.quoteInput, action: \.quoteInput) {
				QuoteInput()
			}
			Scope(state: \.numberInput, action: \.numberInput) {
				NumberInput()
			}
		}
	}

	var body: some ReducerOf<Self> {
		Scope(state: \.root, action: \.root) {
			Path()
		}
		.forEach(\.path, action: \.path) {
			Path()
		}

		Reduce { state, action in
			switch action {
			case .path(.popFrom):
				state.responses.removeLast()
				return .none
			case
				let .root(.nameInput(.continueButtonTapped(output: name))),
				let .path(.element(_, .nameInput(.continueButtonTapped(output: name)))):
				let request = state.currentRequest
				state.responses[request] = .name(.init(id: request.id, name: name))
				return continueEffect(for: &state)
			case
				let .root(.quoteInput(.continueButtonTapped(output: quote))),
				let .path(.element(_, .quoteInput(.continueButtonTapped(output: quote)))):
				let request = state.currentRequest
				state.responses[request] = .quote(.init(id: request.id, quote: quote))
				return continueEffect(for: &state)
			case
				let .root(.numberInput(.continueButtonTapped(output: number))),
				let .path(.element(_, .numberInput(.continueButtonTapped(output: number)))):
				let request = state.currentRequest
				state.responses[request] = .number(.init(id: request.id, number: number))
				return continueEffect(for: &state)
			default:
				return .none
			}
		}
	}

	func continueEffect(for state: inout State) -> Effect<Action> {
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
			self = .nameInput(.init(
				validCharacters: request.validCharacters
			))
		case .quote(let request):
			self = .quoteInput(.init(
				minimumLength: request.minimumLength
			))
		case .number(let request):
			self = .numberInput(.init(
				validNumbers: request.validNumbers
			))
		}
	}
}

struct P2PRequestFlowView: View {
	@Environment(\.dismiss) private var dismiss

	let store: StoreOf<P2PRequestFlow>

	var body: some View {
		NavigationStackStore(store.scope(state: \.path, action: \.path)) {
			view(for: store.scope(state: \.root, action: \.root))
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
		SwitchStore(store) { state in
			switch state {
			case .nameInput:
				CaseLet(
					/P2PRequestFlow.Path.State.nameInput,
					action: P2PRequestFlow.Path.Action.nameInput,
					then: NameInputView.init(store:)
				)
			case .quoteInput:
				CaseLet(
					/P2PRequestFlow.Path.State.quoteInput,
					action: P2PRequestFlow.Path.Action.quoteInput,
					then: QuoteInputView.init(store:)
				)
			case .numberInput:
				CaseLet(
					/P2PRequestFlow.Path.State.numberInput,
					action: P2PRequestFlow.Path.Action.numberInput,
					then: NumberInputView.init(store:)
				)
			}
		}
	}
}
