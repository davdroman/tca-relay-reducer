import Foundation
import NonEmpty

// MARK: Requests

struct P2PRequestPack: Hashable {
	var requests: NonEmpty<[P2PRequest]>
}

enum P2PRequest: Hashable {
	case name(P2PNameRequest)
	case quote(P2PQuoteRequest)
	case number(P2PNumberRequest)

	var id: UUID {
		switch self {
		case .name(let request): return request.id
		case .quote(let request): return request.id
		case .number(let request): return request.id
		}
	}
}

struct P2PNameRequest: Hashable {
	let id: UUID // NameInput shouldn't care about this ID, it's for P2P only.
	let metadata: P2PMetadata // NameInput shouldn't care about this ID, it's for P2P only.
	let validCharacters: CharacterSet // NameInput needs this!
}

struct P2PQuoteRequest: Hashable {
	let id: UUID // QuoteInput shouldn't care about this ID, it's for P2P only.
	let metadata: P2PMetadata // QuoteInput shouldn't care about this ID, it's for P2P only.
	let minimumLength: Int // QuoteInput needs this!
}

struct P2PNumberRequest: Hashable {
	let id: UUID // NumberInput shouldn't care about this ID, it's for P2P only.
	let metadata: P2PMetadata // NumberInput shouldn't care about this ID, it's for P2P only.
	let validNumbers: ClosedRange<Int> // NumberInput needs this!
}

struct P2PMetadata: Hashable {
	// a bunch of P2P-specific fields that only concern the Flow reducer but not the children.
	// children views shouldn't have access to this information at all to allow
	// reusability of those views in other non-P2P contexts, hence Relay.
}

// MARK: Responses

struct P2PResponsePack: Hashable {
	var responses: [P2PResponse]
}

enum P2PResponse: Hashable {
	case name(P2PNameResponse)
	case quote(P2PQuoteResponse)
	case number(P2PNumberResponse)
}

struct P2PNameResponse: Hashable {
	let id: UUID // NameInput shouldn't care about this ID, it's for P2P only.
	let name: String // NameInput outputs this!
}

struct P2PQuoteResponse: Hashable {
	let id: UUID // QuoteInput shouldn't care about this ID, it's for P2P only.
	let quote: String // QuoteInput outputs this!
}

struct P2PNumberResponse: Hashable {
	let id: UUID // NumberInput shouldn't care about this ID, it's for P2P only.
	let number: Int // NumberInput outputs this!
}
