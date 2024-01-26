struct IdentifierToken: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .identifier
  }

  var description: String {
    return "IdentifierToken(value: \(value), location: \(location))"
  }

  static func == (lhs: IdentifierToken, rhs: IdentifierToken) -> Bool {
    return lhs.value == rhs.value && lhs.location == rhs.location
  }
}
