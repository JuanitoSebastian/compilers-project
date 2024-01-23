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
    while positionIndex < input.endIndex {
      if let token = match(
        input[positionIndex...], positionIndex: positionIndex)
      {
        if token.type != .lineComment { tokens.append(token) }
        positionIndex = input.index(positionIndex, offsetBy: token.stringRepresentation.count)
      } else {
        positionIndex = input.index(after: positionIndex)
      }
    }
  }

  func match(_ input: Substring, positionIndex: Substring.Index) -> Token? {
    for tokenType in TokenType.allCases {
      if let matcher = RegexMatcher(tokenType.regex, input: String(input)) {
        let range = Range<String.Index>(
          uncheckedBounds: (
            lower: positionIndex,
            upper: input.base.index(positionIndex, offsetBy: matcher.matchedString.count)
          ))
        switch tokenType {
        case .integerLiteral:
          return IntegerLiteral(
            stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range)
          )
        case .identifier:
          return Identifier(
            value: matcher.matchedString, stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range))
        case .lineComment:
          return LineComment(
            value: matcher.matchedString, stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range))
        case .op:
          return Operator(
            stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range))
        case .punctuation:
          return Punctuation(
            value: matcher.matchedString, stringRepresentation: matcher.matchedString,
            location: Location(file: file, position: range))
        }
      }
    }
    return nil
  }
}
