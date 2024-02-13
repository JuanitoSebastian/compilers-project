// swiftlint:disable function_body_length

import XCTest

@testable import swiftcompiler

// swiftlint:disable:next identifier_name
func L(_ line: Int) -> Location {
  return Location(file: nil, range: nil, line: line)
}

final class TokenizerTests: XCTestCase {
  func test_tokens_recognized_correctly() throws {
    let input = """
      if  3
      while true {
        var = (2 + 3 + false)
      }
      """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 15)
    XCTAssertEqual(
      tokenizer.tokens[0],
      Token(
        type: TokenType.identifier,
        value: "if",
        location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[1],
      Token(
        type: TokenType.integerLiteral,
        value: "3",
        location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[2],
      Token(
        type: TokenType.identifier,
        value: "while",
        location: L(1)))
    XCTAssertEqual(
      tokenizer.tokens[3],
      Token(
        type: TokenType.booleanLiteral,
        value: "true",
        location: L(1)))
    XCTAssertEqual(
      tokenizer.tokens[4],
      Token(
        type: TokenType.punctuation,
        value: "{",
        location: L(1)))
    XCTAssertEqual(
      tokenizer.tokens[5],
      Token(
        type: TokenType.identifier,
        value: "var",
        location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[6],
      Token(
        type: TokenType.op,
        value: "=",
        location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[7],
      Token(
        type: TokenType.punctuation,
        value: "(",
        location: L(2)))

    XCTAssertEqual(
      tokenizer.tokens[8],
      Token(
        type: TokenType.integerLiteral,
        value: "2",
        location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[9],
      Token(
        type: TokenType.op,
        value: "+",
        location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[10],
      Token(
        type: TokenType.integerLiteral,
        value: "3",
        location: L(2)))
    XCTAssertEqual(tokenizer.tokens[11], Token(type: TokenType.op, value: "+", location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[12],
      Token(
        type: TokenType.booleanLiteral,
        value: "false",
        location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[13],
      Token(
        type: TokenType.punctuation,
        value: ")",
        location: L(2)))
    XCTAssertEqual(
      tokenizer.tokens[14],
      Token(
        type: TokenType.punctuation,
        value: "}",
        location: L(3)))
  }

  func test_line_comments_are_ignored() throws {
    let input = """
      if  3
      // while
      for
      """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, 3)
    XCTAssertEqual(
      tokenizer.tokens[0],
      Token(
        type: TokenType.identifier,
        value: "if",
        location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[1],
      Token(
        type: TokenType.integerLiteral,
        value: "3",
        location: L(0)))
    XCTAssertEqual(
      tokenizer.tokens[2],
      Token(
        type: TokenType.identifier,
        value: "for",
        location: L(2)))

  }

  func test_integer_literals_tokenized_correctly() throws {
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
    tokenizer.tokens.enumerated().forEach({ (index, token) in
      XCTAssertEqual(token.value, correctStrings[index])
      XCTAssertEqual(token.type, correctTypes[index])
    })
  }

  func test_OperatorTokens_tokenized_correctly() throws {
    let input = """
      + - * / % = == != < > <= >=
      """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    let correctStrings = ["+", "-", "*", "/", "%", "=", "==", "!=", "<", ">", "<=", ">="]
    tokenizer.tokens.enumerated().forEach({ (index, token) in
      XCTAssertEqual(token.value, correctStrings[index])
      XCTAssertEqual(token.type, TokenType.op)
    })
  }

  func test_parse_and_check_token_position() throws {
    let input = "int hundred = 100"
    let expected = ["int", "hundred", "=", "100"]
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, expected.count)
    tokenizer.tokens.enumerated().forEach({ (index, token) in
      XCTAssertEqual(token.value, expected[index])
    })
  }

  func test_token_location_returns_appropariate_section_of_string() throws {
    let input = "if (a == 3) { b = 4 }"
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    for token in tokenizer.tokens {
      let range = token.location.range!
      XCTAssertEqual(token.value, String(input[range]))
    }
  }

  func test_parse_binary_logical_op_tokens() throws {
    let input = "and or"
    let expected = ["and", "or"]
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    XCTAssertEqual(tokenizer.tokens.count, expected.count)
    tokenizer.tokens.enumerated().forEach({ (index, token) in
      XCTAssertEqual(token.value, expected[index])
      XCTAssertEqual(token.type, TokenType.op)
    })
  }
}

// swiftlint:enable function_body_length
