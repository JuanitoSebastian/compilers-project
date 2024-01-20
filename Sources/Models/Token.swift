struct Token: CustomStringConvertible {
  let value: String
  let type: TokenType
  let location: Location

  var description: String {
    return "Token(value: \(value), type: \(type), location: \(location))"
  }
}
