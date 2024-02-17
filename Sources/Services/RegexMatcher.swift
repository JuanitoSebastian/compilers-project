import Foundation

struct RegexMatcher {
  let input: String
  let regex: NSRegularExpression
  private let result: NSTextCheckingResult

  init?(_ pattern: String, input: String) {
    do {
      self.input = input
      regex = try NSRegularExpression(pattern: pattern)
      if let textCheckingResult = regex.firstMatch(
        in: input, range: NSRange(input.startIndex..., in: input)
      ) {
        result = textCheckingResult
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }

  var match: String {
    get throws {
      return String(input[try range])
    }
  }

  var range: Range<String.Index> {
    get throws {
      guard let rangeToUse = Range(result.range, in: input) else {
        throw RegexMatcherError.invalidRangeForInput(input: input, range: result.range)
      }
      return rangeToUse
    }
  }
}
