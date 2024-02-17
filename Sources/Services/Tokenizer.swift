struct Tokenizer {
  let input: String
  let file: String?
  var tokens: [Token]

  init(input: String, file: String? = nil) {
    self.input = input
    self.file = file
    self.tokens = []
  }

  mutating func tokenize() throws {
    var positionIndex = input.startIndex
    var line = 0
    var position = 0
    while positionIndex < input.endIndex {
      if let token = try match(
        input[positionIndex...], positionIndex: positionIndex, line: line, position: position
      ) {
        if token.type != .lineComment && token.type != .newLine { tokens.append(token) }
        if token.type == .lineComment || token.type == .newLine {
          line += 1
          position = 0
        } else {
          position += token.value.count
        }
        positionIndex = input.index(positionIndex, offsetBy: token.value.count)
      } else {
        positionIndex = input.index(after: positionIndex)
        position += 1
      }
    }
  }

  func match(
    _ input: Substring, positionIndex: Substring.Index, line: Int, position: Int
  ) throws -> Token? {
    for tokenType in TokenType.allCases {
      if let matcher = RegexMatcher(tokenType.regex, input: String(input)) {
        let range = Range<String.Index>(
          uncheckedBounds: (
            lower: positionIndex,
            upper: input.base.index(positionIndex, offsetBy: try matcher.match.count)
          )
        )
        return Token(
          type: tokenType,
          value: try matcher.match,
          location: Location(file: file, range: range, line: line, position: position)
        )
      }
    }
    return nil
  }
}
