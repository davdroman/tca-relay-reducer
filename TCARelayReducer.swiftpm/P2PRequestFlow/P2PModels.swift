import Foundation

// MARK: Requests

struct P2PRequestPack: Hashable {
	var requests: [P2PRequest]
}

enum P2PRequest: Hashable {
	case name(P2PNameRequest)
	case quote(P2PQuoteRequest)
	case number(P2PNumberRequest)
}

struct P2PNameRequest: Hashable {
	var id: UUID // NameView shouldn't care about this ID, it's for P2P only.
	var metadata: P2PMetadata // NameView shouldn't care about this ID, it's for P2P only.
	var validCharacters: CharacterSet // NameView needs this!
}

struct P2PQuoteRequest: Hashable {
	var id: UUID // QuoteInput shouldn't care about this ID, it's for P2P only.
	var metadata: P2PMetadata // QuoteInput shouldn't care about this ID, it's for P2P only.
	var minimumLength: Int // QuoteInput needs this!
}

struct P2PNumberRequest: Hashable {
	var id: UUID // NumberInput shouldn't care about this ID, it's for P2P only.
	var metadata: P2PMetadata // NumberInput shouldn't care about this ID, it's for P2P only.
	var validNumbers: ClosedRange<Int> // NumberView needs this!
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
	var id: UUID // NameView shouldn't care about this ID, it's for P2P only.
	var name: String // NameView outputs this!
}

struct P2PQuoteResponse: Hashable {
	var id: UUID // QuoteView shouldn't care about this ID, it's for P2P only.
	var quote: String // QuoteView outputs this!
}

struct P2PNumberResponse: Hashable {
	var id: UUID // NumberView shouldn't care about this ID, it's for P2P only.
	var number: Int // NumberView outputs this!
}
