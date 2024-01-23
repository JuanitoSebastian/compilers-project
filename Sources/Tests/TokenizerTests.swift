import XCTest

// swiftlint:disable:next identifier_name
let L = Location(file: nil, position: nil)

@testable import swiftcompiler

final class TokenizerTests: XCTestCase {
  func test_a_parsing_with_identifiers_and_integers() throws {
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

  func test_b_parsing_with_line_comment() throws {
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

  func test_c_parsing_with_punctuation() throws {
    let input = """
    if  3 ( )
    { 2 }
    """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 7)
    XCTAssertEqual(
      tokenizer.tokens[2] as? Punctuation,
        Punctuation(
          value: "(", stringRepresentation: "(", location: L))
    XCTAssertEqual(
      tokenizer.tokens[3] as? Punctuation,
        Punctuation(
          value: ")", stringRepresentation: ")", location: L))
    XCTAssertEqual(
      tokenizer.tokens[4] as? Punctuation,
        Punctuation(
          value: "{", stringRepresentation: "{", location: L))
    XCTAssertEqual(
      tokenizer.tokens[5] as? IntegerLiteral,
        IntegerLiteral(
          value: 2, stringRepresentation: "2", location: L))
    XCTAssertEqual(
      tokenizer.tokens[6] as? Punctuation,
        Punctuation(
          value: "}", stringRepresentation: "}", location: L))
  }
}
