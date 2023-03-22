@_spi(Internals) import ComposableArchitecture

public struct RelayState<RelayedState, MainState> {
	public let relayedState: RelayedState
	public var mainState: MainState

	public static func relayed(
		_ relayedState: RelayedState,
		with mainState: MainState
	) -> Self {
		Self(relayedState: relayedState, mainState: mainState)
	}
}

extension RelayState: Sendable where RelayedState: Sendable, MainState: Sendable {}
extension RelayState: Equatable where RelayedState: Equatable, MainState: Equatable {}
extension RelayState: Hashable where RelayedState: Hashable, MainState: Hashable {}

public enum RelayAction<RelayedState, MainAction> {
	case relay(RelayedState, MainAction)
}

extension RelayAction: Sendable where RelayedState: Sendable, MainAction: Sendable {}

extension RelayAction: Equatable where RelayedState: Equatable, MainAction: Equatable {}

extension RelayAction: Hashable where RelayedState: Hashable, MainAction: Hashable {}

public struct Relay<
	RelayedState,
	MainState,
	MainAction,
	MainReducer
>: ReducerProtocol where MainReducer: ReducerProtocol<MainState, MainAction> {
	public typealias State = RelayState<RelayedState, MainState>
	public typealias Action = RelayAction<RelayedState, MainAction>

	public let mainReducer: MainReducer

	public init(
		@ReducerBuilder<MainState, MainAction> _ mainReducer: () -> MainReducer
	) {
		self.mainReducer = mainReducer()
	}

	public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		switch action {
		case let .relay(relayedState, mainAction):
			return mainReducer.reduce(into: &state.mainState, action: mainAction).map {
				Action.relay(relayedState, $0)
			}
		}
	}
}

public extension Store {
	func relay<RelayedState, MainState, MainAction>() -> Store<MainState, MainAction> where
		State == RelayState<RelayedState, MainState>,
		Action == RelayAction<RelayedState, MainAction>
	{
		self
			.scope(state: { $0 }, action: { .relay($0.relayedState, $1) })
			.scope(state: { $0.mainState })
	}
}
