struct NewLineToken: Token, Equatable {
  let type: TokenType = .newLine
  let stringRepresentation: String
  let location: Location

  var description: String {
    return "NewLineToken(\(stringRepresentation))"
  }

  static func == (lhs: NewLineToken, rhs: NewLineToken) -> Bool {
    return lhs.stringRepresentation == rhs.stringRepresentation && lhs.location == rhs.location
  }
}
