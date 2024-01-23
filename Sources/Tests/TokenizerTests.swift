import XCTest

@testable import swiftcompiler

final class TokenizerTests: XCTestCase {
  func test_a_basic_parsing() throws {
    let input = "if  3\nwhile"
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 3)
    XCTAssertEqual(
      tokenizer.tokens[0] as? Identifier,
        Identifier(
          value: "if", stringRepresentation: "if", location: Location(file: nil, position: nil)))
    XCTAssertEqual(
      tokenizer.tokens[1] as? IntegerLiteral,
        IntegerLiteral(
          value: 3, stringRepresentation: "3", location: Location(file: nil, position: nil)))
    XCTAssertEqual(
      tokenizer.tokens[2] as? Identifier,
        Identifier(
          value: "while", stringRepresentation: "while", location: Location(file: nil, position: nil)))
  }

  func test_b_basic_parsin_with_line_comment() throws {
    let input = "if  3\n// while\nfor"
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 3)
    XCTAssertEqual(
      tokenizer.tokens[0] as? Identifier,
        Identifier(
          value: "if", stringRepresentation: "if", location: Location(file: nil, position: nil)))
    XCTAssertEqual(
      tokenizer.tokens[1] as? IntegerLiteral,
        IntegerLiteral(
          value: 3, stringRepresentation: "3", location: Location(file: nil, position: nil)))
    XCTAssertEqual(
      tokenizer.tokens[2] as? Identifier,
        Identifier(
          value: "for", stringRepresentation: "for", location: Location(file: nil, position: nil)))
  }
}
