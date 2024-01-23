import XCTest

// swiftlint:disable:next identifier_name
let L = Location(file: nil, position: nil)

@testable import swiftcompiler

final class TokenizerTests: XCTestCase {
  func test_a_basic_parsing() throws {
    let input = """
    if  3
    while
    """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 3)
    XCTAssertEqual(
      tokenizer.tokens[0] as? Identifier,
        Identifier(
          value: "if", stringRepresentation: "if", location: L))
    XCTAssertEqual(
      tokenizer.tokens[1] as? IntegerLiteral,
        IntegerLiteral(
          value: 3, stringRepresentation: "3", location: L))
    XCTAssertEqual(
      tokenizer.tokens[2] as? Identifier,
        Identifier(
          value: "while", stringRepresentation: "while", location: L))
  }

  func test_b_basic_parsin_with_line_comment() throws {
    let input = """
    if  3
    // while
    for
    """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 3)
    XCTAssertEqual(
      tokenizer.tokens[0] as? Identifier,
        Identifier(
          value: "if", stringRepresentation: "if", location: L))
    XCTAssertEqual(
      tokenizer.tokens[1] as? IntegerLiteral,
        IntegerLiteral(
          value: 3, stringRepresentation: "3", location: L))
    XCTAssertEqual(
      tokenizer.tokens[2] as? Identifier,
        Identifier(
          value: "for", stringRepresentation: "for", location: L))
  }
}
