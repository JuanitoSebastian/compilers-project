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

  mutating func tokenize(){
    var positionIndex = input.startIndex
    while positionIndex < input.endIndex {
      if let token = match(
        input[positionIndex...], positionIndex: positionIndex)
      {
        tokens.append(token)
        positionIndex = input.index(positionIndex, offsetBy: token.value.count)
      } else {
        positionIndex = input.index(after: positionIndex)
      }
    }
  }

  func match(_ input: Substring, positionIndex: Substring.Index) -> Token? {
    if let matcher = RegexMatcher(INTEGER_REGEX, input: String(input)) {
      let range = Range<String.Index>(
        uncheckedBounds: (
          lower: positionIndex,
          upper: input.base.index(positionIndex, offsetBy: matcher.matchedString.count)
        ))
      return Token(
        value: matcher.matchedString, type: .integerLiteral,
        location: Location(file: file, position: range))
    }

    if let matcher = RegexMatcher(IDENTIFIER_REGEX, input: String(input)) {
      let range = Range<String.Index>(
        uncheckedBounds: (
          lower: positionIndex,
          upper: input.base.index(positionIndex, offsetBy: matcher.matchedString.count)
        ))
      return Token(
        value: matcher.matchedString, type: .identifier,
        location: Location(file: file, position: range))
    }
    return nil
  }
}
