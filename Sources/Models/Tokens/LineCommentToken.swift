struct LineCommentToken: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .lineComment
  }

  var description: String {
    return "LineCommentToken(value: \(value), location: \(location))"
  }

  static func == (lhs: LineCommentToken, rhs: LineCommentToken) -> Bool {
    return lhs.value == rhs.value && lhs.location == rhs.location
  }
}
