struct OperatorToken: Token, Equatable {
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .op
  }

  var description: String {
    return "OperatorToken(stringRepresentation: \(stringRepresentation), location: \(location))"
  }

  static func == (lhs: OperatorToken, rhs: OperatorToken) -> Bool {
    return lhs.stringRepresentation == rhs.stringRepresentation && lhs.location == rhs.location
  }
}
