import Foundation

struct RegexMatcher {
  let input: String
  let regex: NSRegularExpression
  let checkResult: NSTextCheckingResult

  init?(_ pattern: String, input: String) {
    do {
      self.input = input
      regex = try NSRegularExpression(pattern: pattern)
      if let result = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) {
        checkResult = result
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }

  var matchedString: String {
    guard let rangeToUse = Range(checkResult.range, in: input) else {
      return ""
    }
    return String(input[rangeToUse])
  }

  var range: Range<String.Index> {
    guard let rangeToUse = Range(checkResult.range, in: input) else {
      return input.startIndex..<input.startIndex
    }
    return rangeToUse
  }
}

let INTEGER_REGEX = "^[0-9]+"
let IDENTIFIER_REGEX = "^[a-zA-Z][a-zA-Z0-9]*"
let OPERATOR_REGEX = "^[-+*/]"
