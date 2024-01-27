struct Token: CustomStringConvertible, Equatable {
  let type: TokenType
  let value: String
  let location: Location

  var description: String {
    return "Token (\(type)): \(value)"
  }

  static func == (lhs: Token, rhs: Token) -> Bool {
    return lhs.type == rhs.type && lhs.value == rhs.value && lhs.location == rhs.location
  }
}
