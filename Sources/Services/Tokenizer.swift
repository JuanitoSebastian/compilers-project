import Foundation

struct Tokenizer {
  let input: String
  let file: String?
  var tokens: [Token]

  init(input: String, file: String? = nil) {
    self.input = input
    self.file = file
    self.tokens = []
  }

  mutating func tokenize() {
    var positionIndex = input.startIndex
    var line = 0
    while positionIndex < input.endIndex {
      if let token = match(
        input[positionIndex...], positionIndex: positionIndex, line: line)
      {
        if token.type != .lineComment && token.type != .newLine { tokens.append(token) }
        if token.type == .lineComment || token.type == .newLine { line += 1 }
        positionIndex = input.index(positionIndex, offsetBy: token.stringRepresentation.count)
      } else {
        positionIndex = input.index(after: positionIndex)
      }
    }
  }

  func match(_ input: Substring, positionIndex: Substring.Index, line: Int) -> Token? {
    for tokenType in TokenType.allCases {
      if let matcher = RegexMatcher(tokenType.regex, input: String(input)) {
        let range = Range<String.Index>(
          uncheckedBounds: (
            lower: positionIndex,
            upper: input.base.index(positionIndex, offsetBy: matcher.matchedString.count)
          ))
        switch tokenType {
        case .integerLiteral:
          return IntegerLiteralToken(
            stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range, line: line)
          )
        case .identifier:
          return IdentifierToken(
            value: matcher.matchedString, stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range, line: line))
        case .lineComment:
          return LineCommentToken(
            value: matcher.matchedString, stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range, line: line))
        case .op:
          return OperatorToken(
            stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range, line: line))
        case .punctuation:
          return PunctuationToken(
            value: matcher.matchedString, stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range, line: line))
        case .newLine:
          return NewLineToken(
            stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range, line: line))
        }
      }
    }
    return nil
  }
}
