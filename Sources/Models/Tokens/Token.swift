struct Token: CustomStringConvertible, Equatable {
  let type: TokenType
  let value: String
  let location: Location

  var description: String {
    return "Token (\(type)): \(value)"
  }
}
