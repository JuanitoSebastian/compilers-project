struct Identifier: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .identifier
  }

  var description: String {
    return "Identifier(value: \(value), location: \(location))"
  }

  static func == (lhs: Identifier, rhs: Identifier) -> Bool {
    return lhs.value == rhs.value && lhs.location == rhs.location
  }
}
