struct NewLine: Token, Equatable {
  let type: TokenType = .newLine
  let stringRepresentation: String
  let location: Location

  var description: String {
    return "NewLine(\(stringRepresentation))"
  }
}
