import XCTest

@testable import swiftcompiler

// swiftlint:disable force_cast force_try

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

  func test_typecheck_var_declaration_expression() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("{ var x: Int = 1; }") as! BlockExpression
    let varExpression = expression.statements[0] as! VarDeclarationExpression
    let varExpressionType = try typechecker.typecheck(varExpression)
    let valueType = try typechecker.typecheck(varExpression.variableValue)
    let identifierType = try typechecker.typecheck(varExpression.variableIdentifier)
    XCTAssertEqual(varExpressionType, Type.unit)
    XCTAssertEqual(valueType, Type.int)
    XCTAssertEqual(identifierType, Type.int)
  }

  func test_typecheck_invalid_var_declaration_expression_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("{ var x: Int = true; }") as! BlockExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression.statements[0])) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: .int, got: [.bool])
      )
    }
  }

  func test_typecheck_assign_new_value() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("{ var x: Int = 1; x = 2; }") as! BlockExpression
    XCTAssertNoThrow(try typechecker.typecheck(expression))
  }

  func test_typecheck_invalid_assignment_type_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("{ var x: Int = 1; x = true; }") as! BlockExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: .int, got: [.bool])
      )
    }
  }

  func test_typecheck_reference_to_undefined_identifier_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("{ x = 2; }") as! BlockExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.referenceToUndefinedIdentifier(identifier: "x")
      )
    }
  }

  func test_typecheck_if_expression() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("if 4 > 2 then { 1 } else { 2 }") as! IfExpression
    let type = try typechecker.typecheck(expression)
    XCTAssertEqual(type, Type.int)
  }

  func test_typecheck_if_expression_invalid_condition_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("if 4 * 2 then { 1 }") as! IfExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: .bool, got: [.int])
      )
    }
  }

  func test_typecheck_if_expression_unequal_then_and_else_types_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("if 4 > 2 then { 1 } else { true }") as! IfExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: .int, got: [.bool])
      )
    }

  }
}

extension TypechkerTests {
  private func toExpression(_ expressionString: String) throws -> (any Expression) {
    var tokenizer = Tokenizer(input: expressionString)
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    return try! parser.parse()[0]!
  }
}

// swiftlint:enable force_cast force_try
