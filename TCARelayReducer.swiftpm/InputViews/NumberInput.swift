import ComposableArchitecture
import SwiftUI

struct NumberInput: ReducerProtocol {
	struct State: Equatable {
		let validNumbers: ClosedRange<Int>
		var output: Int? = nil
		
		init(validNumbers: ClosedRange<Int>) {
			self.validNumbers = validNumbers
		}
	}
	
	enum Action: Equatable {
		case numberFieldChanged(Int?)
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
		let prompt: String
		let output: Int?
		let canContinue: Bool
		
		init(state: NumberInput.State) {
			self.prompt = "Enter a number from \(state.validNumbers.lowerBound) to \(state.validNumbers.upperBound)"
			self.output = state.output
			if let output = state.output {
				self.canContinue = state.validNumbers.contains(output)
			} else {
				self.canContinue = false
			}
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
					prompt: Text(viewStore.prompt)
				)
				.textFieldStyle(.roundedBorder)
			}
			.safeAreaInset(edge: .bottom, spacing: 0) {
				Button(
					action: { viewStore.send(.continueButtonTapped(output: viewStore.output!)) }
				) {
					Text("Continue")
						.bold()
						.frame(maxWidth: .infinity)
						.frame(height: 40)
				}
				.buttonStyle(.borderedProminent)
				.disabled(!viewStore.canContinue)
			}
			.padding()
		}
		.navigationTitle("Number")
	}
}

struct NumberInputView_Previews: PreviewProvider {
	static var previews: some View {
		NumberInputView(
			store: .init(
				initialState: .init(validNumbers: 1...5),
				reducer: NumberInput()
			)
		)
	}
}
