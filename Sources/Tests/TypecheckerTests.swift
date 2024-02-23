import XCTest

@testable import swiftcompiler

// swiftlint:disable force_cast force_try

final class TypechkerTests: XCTestCase {

  func test_typecheck_literal_expression_int() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("1 + 2 - 3")
    let typedExpression = try typechecker.typecheck(expression.resultExpression!)
    XCTAssertEqual(typedExpression.type, Type.int)
  }

  func test_typecheck_literal_expression_bool() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("1 + 2 - 3 > 4")
    let typedExpression = try typechecker.typecheck(expression.resultExpression!)
    XCTAssertEqual(typedExpression.type, Type.bool)
  }

  func test_typecheck_var_declaration_expression() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("{ var x: Int = 1; }").resultExpression as! BlockExpression
    let varExpression = expression.statements[0] as! VarDeclarationExpression
    let varExpressionTyped = try typechecker.typecheck(varExpression) as! VarDeclarationExpression
    XCTAssertEqual(varExpressionTyped.type, Type.unit)
    XCTAssertEqual(varExpressionTyped.variableValue.type, Type.int)
    XCTAssertEqual(varExpressionTyped.variableIdentifier.type, Type.int)
  }

  func test_typecheck_invalid_var_declaration_expression_throws() throws {
    var typechecker = Typechecker()
    let expression =
      try! toExpression("{ var x: Int = true; }").resultExpression as! BlockExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression.statements[0])) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: [.int], got: [.bool], location: L(0, 2))
      )
    }
  }

  func test_typecheck_assign_new_value() throws {
    var typechecker = Typechecker()
    let expression = try toExpression("{ var x: Int = 1; x = 2; }")
    XCTAssertNoThrow(try typechecker.typecheck(expression))
  }

  func test_typecheck_invalid_assignment_type_throws() throws {
    var typechecker = Typechecker()
    let expression =
      try! toExpression("{ var x: Int = 1; x = true; }").resultExpression as! BlockExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: [.int], got: [.bool], location: L(0, 18))
      )
    }
  }

  func test_typecheck_reference_to_undefined_identifier_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("{ x = 2; }").resultExpression as! BlockExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.referenceToUndefinedIdentifier(identifier: "x", location: L(0, 2))
      )
    }
  }

  func test_typecheck_if_expression() throws {
    var typechecker = Typechecker()
    let expression =
      try toExpression("if 4 > 2 then { 1 } else { 2 }").resultExpression as! IfExpression
    let typedExpression = try typechecker.typecheck(expression)
    XCTAssertEqual(typedExpression.type, Type.int)
  }

  func test_typecheck_if_expression_invalid_condition_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("if 4 * 2 then { 1 }").resultExpression as! IfExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: [.bool], got: [.int], location: L(0, 3))
      )
    }
  }

  func test_typecheck_if_expression_unequal_then_and_else_types_throws() throws {
    var typechecker = Typechecker()
    let expression =
      try! toExpression("if 4 > 2 then { 1 } else { true }").resultExpression as! IfExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: [.int], got: [.bool], location: L(0, 25))
      )
    }
  }

  func test_typecheck_while_expression() throws {
    var typechecker = Typechecker()
    let expression =
      try toExpression("while 4 > 2 do { var x = 2; }").resultExpression as! WhileExpression
    let typedExpression = try typechecker.typecheck(expression)
    XCTAssertEqual(typedExpression.type, Type.unit)
  }

  func test_typecheck_while_expression_invalid_condition_throws() throws {
    var typechecker = Typechecker()
    let expression =
      try! toExpression("while 4 * 2 do { var x = 2; }").resultExpression as! WhileExpression
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(expected: [.bool], got: [.int], location: L(0, 6))
      )
    }
  }

  func test_typecheck_not_expression() throws {
    var typechecker = Typechecker()
    let boolExpression = try toExpression("not true").resultExpression as! NotExpression
    let intExpression = try toExpression("not not not 1").resultExpression as! NotExpression
    let blockExpression =
      try toExpression("not { var x = 2; x }").resultExpression as! NotExpression
    let boolExpressionTyped = try typechecker.typecheck(boolExpression)
    let intExpressionTyped = try typechecker.typecheck(intExpression)
    let blockExpressionTyped = try typechecker.typecheck(blockExpression)
    XCTAssertEqual(boolExpressionTyped.type, Type.bool)
    XCTAssertEqual(intExpressionTyped.type, Type.int)
    XCTAssertEqual(blockExpressionTyped.type, Type.int)
  }

  func test_typecheck_invalid_not_expression_throws() throws {
    var typechecker = Typechecker()
    XCTAssertThrowsError(try typechecker.typecheck(toExpression("not { var x = 2; }"))) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.inaproppriateType(
          expected: [Type.bool, Type.int], got: [Type.unit], location: L(0, 4)
        )
      )
    }
  }

  func test_typecheck_function_call_expression() throws {
    var typechecker = Typechecker()
    let printIntExpression = try toExpression("print_int(1)")
    var typedExpression = try typechecker.typecheck(printIntExpression)
    XCTAssertEqual(typedExpression.type, Type.unit)
    let printBoolExpression = try toExpression("print_bool(true)")
    typedExpression = try typechecker.typecheck(printBoolExpression)
    XCTAssertEqual(typedExpression.type, Type.unit)
    let readIntExpression = try toExpression("read_int()")
    typedExpression = try typechecker.typecheck(readIntExpression)
    XCTAssertEqual(typedExpression.type, Type.int)
  }

  func test_typecheck_unkown_function_call_expression_throws() throws {
    var typechecker = Typechecker()
    XCTAssertThrowsError(try typechecker.typecheck(toExpression("print(1)"))) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.referenceToUndefinedIdentifier(identifier: "print", location: L(0, 0))
      )
    }
  }

  func test_typecheck_wrong_number_of_args_in_function_call_throws() throws {
    var typechecker = Typechecker()
    XCTAssertThrowsError(try typechecker.typecheck(toExpression("print_int(1, 2)"))) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.wrongNumberOfArguments(expected: 1, got: 2, location: L(0, 0))
      )
    }
  }

  func test_typecheck_variable_already_declared_throws() throws {
    var typechecker = Typechecker()
    let expression = try! toExpression("{ var x: Int = 1; var x: Int = 2; }")
    XCTAssertThrowsError(try typechecker.typecheck(expression)) { error in
      XCTAssertEqual(
        error as? TypecheckerError,
        TypecheckerError.identifierAlreadyDeclared(identifier: "x", location: L(0, 18))
      )
    }
  }

  func test_typecheck_variables_with_same_name_in_different_scopes() throws {
    var typechecker = Typechecker()
    let expression =
      try toExpression("if 2 > 3 then { var a: Int = 2 } else { var a: Int = 2 }")
    XCTAssertNoThrow(try typechecker.typecheck(expression))
  }
}

extension TypechkerTests {
  private func toExpression(_ expressionString: String) throws -> BlockExpression {
    var tokenizer = Tokenizer(input: expressionString)
    try tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    return try parser.parse()
  }
}

// swiftlint:enable force_cast force_try
