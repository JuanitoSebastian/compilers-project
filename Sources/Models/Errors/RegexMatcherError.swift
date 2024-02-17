import Foundation

enum RegexMatcherError: Error {
  case invalidRangeForInput(input: String, range: NSRange)
}
