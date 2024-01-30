import XCTest

@testable import swiftcompiler

final class ParserTests: XCTestCase {
  func test_a_parse_addition_with_ints() throws {
    var tokenizer = Tokenizer(input: "1 + 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let binaryOpExpression = expression
        as? BinaryOpExpression
    else {
      XCTFail("Expected BinaryOpExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)))
  }

  func test_b_parse_addition_with_int_and_identifier() throws {
    var tokenizer = Tokenizer(input: "1 + a")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let binaryOpExpression = expression
        as? BinaryOpExpression
    else {
      XCTFail("Expected BinaryOpExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+", right: IdentifierExpression(value: "a")))
  }

  func test_c_parse_operation_with_multiple_numbers() throws {
    var tokenizer = Tokenizer(input: "10 + a - 3")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let binaryOpExpression = expression
        as? BinaryOpExpression
    else {
      XCTFail("Expected BinaryOpExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 10), op: "+", right: IdentifierExpression(value: "a")),
        op: "-",
        right: LiteralExpression(value: 3)))
  }

  func test_d_parse_multiplication() throws {
    var tokenizer = Tokenizer(input: "2 - 10 * 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let binaryOpExpression = expression
        as? BinaryOpExpression
    else {
      XCTFail("Expected BinaryOpExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 2),
        op: "-",
        right: BinaryOpExpression(
          left: LiteralExpression(value: 10), op: "*", right: LiteralExpression(value: 2))))
  }

  func test_e_parse_parentesis() throws {
    var tokenizer = Tokenizer(input: "(2 - 10) * 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let binaryOpExpression = expression
        as? BinaryOpExpression
    else {
      XCTFail("Expected BinaryOpExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 2), op: "-", right: LiteralExpression(value: 10)),
        op: "*",
        right: LiteralExpression(value: 2)))
  }

  func test_f_orphan_plus_sign_throws() throws {
    var tokenizer = Tokenizer(input: "1 + 2 +")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.noTokenFound(
          precedingToken: Token(type: .op, value: "+", location: L(0))))
    }
  }

  func test_g_oprhan_multiply_sign_throws() throws {
    var tokenizer = Tokenizer(input: "1 + 2 *")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.noTokenFound(
          precedingToken: Token(type: .op, value: "*", location: L(0))))
    }
  }

  func test_h_empty_parentheses_throws() throws {
    var tokenizer = Tokenizer(input: "()")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.unexpectedTokenType(
          token: Token(
            type: .punctuation, value: ")", location: L(0)),
          expected: [TokenType.integerLiteral, TokenType.identifier]))
    }
  }

  func test_i_parse_if_statement() throws {
    var tokenizer = Tokenizer(input: "if 3 then 2 ")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let ifExpression = expression
        as? IfExpression
    else {
      XCTFail("Expected IfExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      ifExpression,
      IfExpression(
        condition: LiteralExpression(value: 3),
        thenExpression: LiteralExpression<Int>(value: 2),
        elseExpression: nil))
  }

  func test_j_parse_if_else_statement() throws {
    var tokenizer = Tokenizer(input: "if 3 then 2 else 1")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let ifExpression = expression
        as? IfExpression
    else {
      XCTFail("Expected IfExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      ifExpression,
      IfExpression(
        condition: LiteralExpression(value: 3),
        thenExpression: LiteralExpression<Int>(value: 2),
        elseExpression: LiteralExpression<Int>(value: 1)))
  }

  func test_k_parse_function_call() throws {
    var tokenizer = Tokenizer(input: "foo(1, 2)")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let functionCallExpression = expression
        as? FunctionCallExpression
    else {
      XCTFail("Expected FunctionCallExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      functionCallExpression,
      FunctionCallExpression(
        identifier: IdentifierExpression(value: "foo"),
        arguments: [
          LiteralExpression<Int>(value: 1),
          LiteralExpression<Int>(value: 2)
        ]))
  }

  func test_l_parse_function_call_with_no_parameters() throws {
    var tokenizer = Tokenizer(input: "foo()")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = try parser.parse()
    guard
      let functionCallExpression = expression
        as? FunctionCallExpression
    else {
      XCTFail("Expected FunctionCallExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      functionCallExpression,
      FunctionCallExpression(
        identifier: IdentifierExpression(value: "foo"),
        arguments: []))
  }
}
