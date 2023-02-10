import ComposableArchitecture
import SwiftUI

struct QuoteInput: ReducerProtocol {
	struct State: Hashable {
		let minimumLength: Int
		var output: String = ""

		init(minimumLength: Int) {
			self.minimumLength = minimumLength
		}
	}

	enum Action: Equatable {
		case quoteFieldChanged(String)
		case continueButtonTapped(output: String)
	}

	func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		switch action {
		case .quoteFieldChanged(let quote):
			state.output = quote
			return .none
		case .continueButtonTapped:
			return .none
		}
	}
}

struct QuoteInputView: View {
	struct ViewState: Equatable {
		let output: String
		let canContinue: Bool

		init(state: QuoteInput.State) {
			self.output = state.output
			self.canContinue = state.output.count >= state.minimumLength
		}
	}

	let store: StoreOf<QuoteInput>

	var body: some View {
		WithViewStore(store, observe: ViewState.init(state:)) { viewStore in
			ScrollView {
				TextField(
					"Quote",
					text: viewStore.binding(get: \.output, send: { .quoteFieldChanged($0) }),
					prompt: Text("Enter your favorite movie quote...")
				)
			}
			.safeAreaInset(edge: .bottom, spacing: 0) {
				Button("Continue", action: { viewStore.send(.continueButtonTapped(output: viewStore.output)) })
					.buttonStyle(.borderedProminent)
			}
		}
	}
}
