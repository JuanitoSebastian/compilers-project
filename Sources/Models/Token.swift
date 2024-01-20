struct Token: CustomStringConvertible, Equatable {
  let value: String
  let type: TokenType
  let location: Location

  var description: String {
    return "Token(value: \(value), type: \(type), location: \(location))"
  }

  static func == (lhs: Token, rhs: Token) -> Bool {
    return lhs.value == rhs.value && lhs.type == rhs.type && lhs.location == rhs.location
  }
}
