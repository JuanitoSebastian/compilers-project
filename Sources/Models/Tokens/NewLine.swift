struct NewLine: Token, Equatable {
  let type: TokenType = .newLine
  let stringRepresentation: String
  let location: Location

  var description: String {
    return "NewLine(\(stringRepresentation))"
  }

  static func == (lhs: NewLine, rhs: NewLine) -> Bool {
    return lhs.stringRepresentation == rhs.stringRepresentation && lhs.location == rhs.location
  }
}
