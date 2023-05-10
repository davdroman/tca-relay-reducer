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
		let prompt: String
		let output: String
		let canContinue: Bool
		
		init(state: QuoteInput.State) {
			self.prompt = "Enter your favorite movie quote\n\n\(state.minimumLength) characters min."
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
					prompt: Text(viewStore.prompt),
					axis: .vertical
				)
				.lineLimit(4, reservesSpace: true)
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
			}
			.padding()
		}
		.navigationTitle("Quote")
	}
}

struct QuoteInputView_Previews: PreviewProvider {
	static var previews: some View {
		QuoteInputView(
			store: .init(
				initialState: .init(minimumLength: 10),
				reducer: QuoteInput()
			)
		)
	}
}
