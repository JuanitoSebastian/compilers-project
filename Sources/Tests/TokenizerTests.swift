import XCTest

@testable import swiftcompiler

final class TokenizerTests: XCTestCase {
  func testTokenizer() throws {
    let input = "if  3\nwhile"
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 3)
    XCTAssertEqual(
      tokenizer.tokens,
      [
        Token(
          value: "if", type: .identifier,
          location: Location(file: nil, position: nil)
        ),
        Token(
          value: "3", type: .integerLiteral,
          location: Location(file: nil, position: nil)
        ),
        Token(
          value: "while", type: .identifier,
          location: Location(file: nil, position: nil)
        )
      ])
  }
}
