struct Punctuation: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .punctuation
  }
  var description: String {
    return "Punctuation(value: \(value))"
  }

  static func == (lhs: Punctuation, rhs: Punctuation) -> Bool {
    return lhs.value == rhs.value && lhs.location == rhs.location
  }
}
