struct LineComment: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .lineComment
  }

  var description: String {
    return "LineComment(value: \(value), location: \(location))"
  }

  static func == (lhs: LineComment, rhs: LineComment) -> Bool {
    return lhs.value == rhs.value && lhs.location == rhs.location
  }
}
