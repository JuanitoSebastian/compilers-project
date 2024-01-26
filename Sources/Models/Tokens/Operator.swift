struct Operator: Token, Equatable {
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .op
  }

  var description: String {
    return "Operator(stringRepresentation: \(stringRepresentation), location: \(location))"
  }

  static func == (lhs: Operator, rhs: Operator) -> Bool {
    return lhs.stringRepresentation == rhs.stringRepresentation && lhs.location == rhs.location
  }
}
