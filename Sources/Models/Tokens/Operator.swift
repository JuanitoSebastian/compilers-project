struct Operator: Token, Equatable {
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .op
  }

  var description: String {
    return "Operator(stringRepresentation: \(stringRepresentation), location: \(location))"
  }
}
