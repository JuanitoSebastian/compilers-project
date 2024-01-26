import XCTest
import SwiftSyntax
import SwiftSyntaxMacros

@testable import swiftcompiler

// swiftlint:disable:next identifier_name
func L(_ line: Int) -> Location {
  return Location(file: nil, position: nil, line: line)
}

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
          value: "if", stringRepresentation: "if", location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[1] as? IntegerLiteral,
        IntegerLiteral(
          value: 3, stringRepresentation: "3", location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[2] as? Identifier,
        Identifier(
          value: "while", stringRepresentation: "while", location: L(1)))
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
          value: "if", stringRepresentation: "if", location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[1] as? IntegerLiteral,
        IntegerLiteral(
          value: 3, stringRepresentation: "3", location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[2] as? Identifier,
        Identifier(
          value: "for", stringRepresentation: "for", location: L(2)))
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
          value: "(", stringRepresentation: "(", location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[3] as? Punctuation,
        Punctuation(
          value: ")", stringRepresentation: ")", location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[4] as? Punctuation,
        Punctuation(
          value: "{", stringRepresentation: "{", location: L(1)))
    XCTAssertEqual(
      tokenizer.tokens[5] as? IntegerLiteral,
        IntegerLiteral(
          value: 2, stringRepresentation: "2", location: L(1)))
    XCTAssertEqual(
      tokenizer.tokens[6] as? Punctuation,
        Punctuation(
          value: "}", stringRepresentation: "}", location: L(1)))
  }

  func test_d_parse_and_check_token_position() throws {
    let input = "int hundred = 100"
    let expected = ["int", "hundred", "=", "100"]
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, expected.count)
    tokenizer.tokens.enumerated().forEach( { (index, token) in
      XCTAssertEqual(token.stringRepresentation, expected[index])
    })
  }

  func test_e_parse_if() throws {
    let input = "if (a == 3) { b = 4 }"
    let expected = ["if", "(", "a", "==", "3", ")", "{", "b", "=", "4", "}"]
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, expected.count)
    tokenizer.tokens.enumerated().forEach( { (index, token) in
      XCTAssertEqual(token.stringRepresentation, expected[index])
    })
  }

  func test_f_token_location_returns_appropariate_section_of_string() throws {
    let input = "if (a == 3) { b = 4 }"
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    for token in tokenizer.tokens {
      let range = token.location.position!
      XCTAssertEqual(token.stringRepresentation, String(input[range]))
    }
  }
}
