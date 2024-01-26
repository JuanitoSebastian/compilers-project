// swiftlint:disable function_body_length

import XCTest

@testable import swiftcompiler

// swiftlint:disable:next identifier_name
func L(_ line: Int) -> Location {
  return Location(file: nil, position: nil, line: line)
}

final class TokenizerTests: XCTestCase {
  func test_a_tokens_recognized_correctly() throws {
    let input = """
    if  3
    while {
      var = (2 + 3)
    }
    """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 12)
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
    XCTAssertEqual(tokenizer.tokens[3] as? Punctuation,
      Punctuation(
        value: "{", stringRepresentation: "{", location: L(1)))
    XCTAssertEqual(
      tokenizer.tokens[4] as? Identifier,
        Identifier(
          value: "var", stringRepresentation: "var", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[5] as? Operator,
        Operator(stringRepresentation: "=", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[6] as? Punctuation,
        Punctuation(
          value: "(", stringRepresentation: "(", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[7] as? IntegerLiteral,
        IntegerLiteral(
          value: 2, stringRepresentation: "2", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[8] as? Operator,
        Operator(stringRepresentation: "+", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[9] as? IntegerLiteral,
        IntegerLiteral(
          value: 3, stringRepresentation: "3", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[10] as? Punctuation,
        Punctuation(
          value: ")", stringRepresentation: ")", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[11] as? Punctuation,
        Punctuation(
          value: "}", stringRepresentation: "}", location: L(3)))
  }

  func test_b_line_comments_are_ignored() throws {
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

  func test_c_integer_literals_tokenized_correctly() throws {
    let input = """
    1 2 400958 -1
    648
    """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    let correctStrings = ["1", "2", "400958", "-", "1", "648"]
    let correctTypes = [
      TokenType.integerLiteral,
      TokenType.integerLiteral,
      TokenType.integerLiteral,
      TokenType.op,
      TokenType.integerLiteral,
      TokenType.integerLiteral
    ]
    tokenizer.tokens.enumerated().forEach( { (index, token) in
      XCTAssertEqual(token.stringRepresentation, correctStrings[index])
      XCTAssertEqual(token.type, correctTypes[index])
    })
  }

  func test_d_operators_tokenized_correctly() throws {
    let input = """
    + - * / % = == != < > <= >=
    """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    let correctStrings = ["+", "-", "*", "/", "%", "=", "==", "!=", "<", ">", "<=", ">="]
    tokenizer.tokens.enumerated().forEach( { (index, token) in
      XCTAssertEqual(token.stringRepresentation, correctStrings[index])
      XCTAssertEqual(token.type, TokenType.op)
    })
  }

  func test_e_parse_and_check_token_position() throws {
    let input = "int hundred = 100"
    let expected = ["int", "hundred", "=", "100"]
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

// swiftlint:enable function_body_length
