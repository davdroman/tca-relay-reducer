import ComposableArchitecture
import SwiftUI

struct NumberInput: ReducerProtocol {
	struct State: Hashable {
		let validNumbers: ClosedRange<Int>
		var output: Int = 0

		init(validNumbers: ClosedRange<Int>) {
			self.validNumbers = validNumbers
		}
	}

	enum Action: Equatable {
		case numberFieldChanged(Int)
		case continueButtonTapped(output: Int)
	}

	func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		switch action {
		case .numberFieldChanged(let number):
			state.output = number
			return .none
		case .continueButtonTapped:
			return .none
		}
	}
}

struct NumberInputView: View {
	struct ViewState: Equatable {
		let output: Int
		let canContinue: Bool

		init(state: NumberInput.State) {
			self.output = state.output
			self.canContinue = state.validNumbers.contains(state.output)
		}
	}

	let store: StoreOf<NumberInput>

	var body: some View {
		WithViewStore(store, observe: ViewState.init(state:)) { viewStore in
			ScrollView {
				TextField(
					"Number",
					value: viewStore.binding(get: \.output, send: { .numberFieldChanged($0) }),
					format: .number,
					prompt: Text("Enter a number you like...")
				)
			}
			.safeAreaInset(edge: .bottom, spacing: 0) {
				Button("Continue", action: { viewStore.send(.continueButtonTapped(output: viewStore.output)) })
					.buttonStyle(.borderedProminent)
			}
		}
	}
}

//struct NumberInputView_Previews: PreviewProvider {
//
//}
