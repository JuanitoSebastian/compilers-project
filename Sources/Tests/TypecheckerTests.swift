import XCTest

@testable import swiftcompiler

final class TypechkerTests: XCTestCase {

  func test_typecheck_literal_expression_int() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("1 + 2 - 3")
    let type = try typechecker.typecheck(expression)
    XCTAssertEqual(type, Type.int)
  }

  func test_typecheck_literal_expression_bool() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("1 + 2 - 3 > 4")
    let type = try typechecker.typecheck(expression)
    XCTAssertEqual(type, Type.bool)
  }
}

extension TypechkerTests {
  private func toExpression(_ expressionString: String) throws -> (any Expression) {
    var tokenizer = Tokenizer(input: expressionString)
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    // swiftlint:disable:next force_try
    return try! parser.parse()[0]!
  }
}
