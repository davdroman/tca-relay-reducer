import ComposableArchitecture
import SwiftUI

@Reducer
struct NameInput {
	struct State: Equatable {
		let validCharacters: CharacterSet
		var output: String = ""

		init(validCharacters: CharacterSet) {
			self.validCharacters = validCharacters
		}
	}

	enum Action {
		case nameFieldChanged(String)
		case continueButtonTapped(output: String)
	}

	func reduce(into state: inout State, action: Action) -> Effect<Action> {
		switch action {
		case .nameFieldChanged(let name):
			state.output = name
			return .none
		case .continueButtonTapped:
			return .none
		}
	}
}

struct NameInputView: View {
	struct ViewState: Equatable {
		let prompt: String
		let output: String
		let canContinue: Bool

		init(state: NameInput.State) {
			self.prompt = "Enter your name (letters only)"
			self.output = state.output
			self.canContinue = CharacterSet(charactersIn: state.output).isSubset(of: state.validCharacters)
		}
	}

	let store: StoreOf<NameInput>

	var body: some View {
		WithViewStore(store, observe: ViewState.init(state:)) { viewStore in
			ScrollView {
				TextField(
					"Name",
					text: viewStore.binding(get: \.output, send: { .nameFieldChanged($0) }),
					prompt: Text(viewStore.prompt)
				)
				.textFieldStyle(.roundedBorder)
			}
			.safeAreaInset(edge: .bottom, spacing: 0) {
				Button(
					action: { viewStore.send(.continueButtonTapped(output: viewStore.output)) }
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
		.navigationTitle("Name")
	}
}

struct NameInputView_Previews: PreviewProvider {
	static var previews: some View {
		NameInputView(
			store: Store(initialState: .init(validCharacters: .letters)) {
				NameInput()
			}
		)
	}
}
