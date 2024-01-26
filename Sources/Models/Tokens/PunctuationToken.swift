struct PunctuationToken: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .punctuation
  }
  var description: String {
    return "PunctuationToken(value: \(value))"
  }

  static func == (lhs: PunctuationToken, rhs: PunctuationToken) -> Bool {
    return lhs.value == rhs.value && lhs.location == rhs.location
  }
}
