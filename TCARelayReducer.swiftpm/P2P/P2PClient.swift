import AsyncAlgorithms
import Dependencies

struct P2PClient {
	var requests: @Sendable () async -> AsyncChannel<P2PRequestPack>
	var sendResponse: @Sendable (P2PResponsePack) async -> Void
}

extension P2PClient: TestDependencyKey {
	// in order to simulate incoming requests from a P2P client
	static let requestChannel = AsyncChannel<P2PRequestPack>()
	
	static let testValue = Self(
		requests: { requestChannel },
		sendResponse: { response in
			// always succeeds, for simplicity
		}
	)
}

extension DependencyValues {
	var p2pClient: P2PClient {
		get { self[P2PClient.self] }
		set { self[P2PClient.self] = newValue }
	}
}
