import XCTest

@testable import swiftcompiler

final class ParserTests: XCTestCase {
  func test_a_parse_binary_op() throws {
    var tokenizer = Tokenizer(input: "1 + 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let expression = parser.parseExpression()
    guard
      let binaryOpExpression = expression
        as? BinaryOpExpression<LiteralExpression<Int>, LiteralExpression<Int>>
    else {
      XCTFail("Expected BinaryOpExpression, got \(String(describing: expression))")
      return
    }
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)))
  }
}
