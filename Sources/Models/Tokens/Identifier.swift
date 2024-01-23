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
}
