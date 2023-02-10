import ComposableArchitecture
import SwiftUI

struct NameInput: ReducerProtocol {
	struct State: Hashable {
		let validCharacters: CharacterSet
		var output: String = ""

		init(validCharacters: CharacterSet) {
			self.validCharacters = validCharacters
		}
	}

	enum Action: Equatable {
		case nameFieldChanged(String)
		case continueButtonTapped(output: String)
	}

	func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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
		let output: String
		let canContinue: Bool

		init(state: NameInput.State) {
			self.output = state.output
			self.canContinue = state.output.rangeOfCharacter(from: state.validCharacters) == state.output.startIndex..<state.output.endIndex
		}
	}

	let store: StoreOf<NameInput>

	var body: some View {
		WithViewStore(store, observe: ViewState.init(state:)) { viewStore in
			ScrollView {
				TextField(
					"Name",
					text: viewStore.binding(get: \.output, send: { .nameFieldChanged($0) }),
					prompt: Text("Enter your name...")
				)
			}
			.safeAreaInset(edge: .bottom, spacing: 0) {
				Button("Continue", action: { viewStore.send(.continueButtonTapped(output: viewStore.output)) })
					.buttonStyle(.borderedProminent)
			}
		}
	}
}
