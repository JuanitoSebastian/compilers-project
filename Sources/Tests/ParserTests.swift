import XCTest

@testable import swiftcompiler

final class ParserTests: XCTestCase {
  func test_a_parse_binary_op_with_ints() throws {
    var tokenizer = Tokenizer(input: "1 + 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = parser.parseExpression()
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

  func test_b_parse_binary_op_with_int_and_identifier() throws {
    var tokenizer = Tokenizer(input: "1 + a")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = parser.parseExpression()
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

  func test_c_parse_binary_op_with_nested_binary_op() throws {
    var tokenizer = Tokenizer(input: "10 + a - 3")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = parser.parseExpression()
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
}
