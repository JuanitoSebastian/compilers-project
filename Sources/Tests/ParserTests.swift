import XCTest

@testable import swiftcompiler

final class ParserTests: XCTestCase {
  func test_parse_addition_with_ints() throws {
    let expr = try parse("1 + 2")
    let bOpE = BinaryOpExpression(
      left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_parse_addition_with_int_and_identifier() throws {
    let expr = try parse("1 + a")
    let bOpE = BinaryOpExpression(
      left: LiteralExpression(value: 1), op: "+", right: IdentifierExpression(value: "a")
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_parse_operation_with_multiple_numbers() throws {
    let expr = try parse("1 + 10 - 3")
    let bOpE = BinaryOpExpression(
      left: BinaryOpExpression(
        left: LiteralExpression(value: 1),
        op: "+",
        right: LiteralExpression(value: 10)
      ),
      op: "-",
      right: LiteralExpression(value: 3)
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_parse_operation_with_negative_int() throws {
    let expr = try parse("10 + (-10)")
    let bOpE = BinaryOpExpression(
      left: LiteralExpression(value: 10),
      op: "+",
      right: NotExpression(value: LiteralExpression(value: 10))
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_parse_multiplication() throws {
    let expr = try parse("2 - 10 * 2")
    let bOpE = BinaryOpExpression(
      left: LiteralExpression(value: 2),
      op: "-",
      right: BinaryOpExpression(
        left: LiteralExpression(value: 10),
        op: "*",
        right: LiteralExpression(value: 2)
      )
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_parse_parentesis() throws {
    let expr = try parse("(2 - 10) * 2")
    let bOpE = BinaryOpExpression(
      left: BinaryOpExpression(
        left: LiteralExpression(value: 2),
        op: "-",
        right: LiteralExpression(value: 10)
      ),
      op: "*",
      right: LiteralExpression(value: 2))
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_orphan_plus_sign_throws() throws {
    XCTAssertThrowsError(try parse("1 + 2 +")) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.noTokenFound(precedingToken: Token(type: .op, value: "+", location: L(0, 6))))
    }
  }

  func test_oprhan_multiply_sign_throws() throws {
    XCTAssertThrowsError(try parse("1 + 2 *")) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.noTokenFound(precedingToken: Token(type: .op, value: "*", location: L(0, 6))))
    }
  }

  func test_empty_parentheses_throws() throws {
    XCTAssertThrowsError(try parse("()")) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.unexpectedTokenType(
          token: Token(type: .punctuation, value: ")", location: L(0, 1)),
          expected: [TokenType.integerLiteral, TokenType.identifier]))
    }
  }

  func test_parse_if_statement() throws {
    let expr = try parse("if false then 2")
    let ifE = IfExpression(
      condition: LiteralExpression<Bool>(value: false),
      thenExpression: LiteralExpression<Int>(value: 2),
      elseExpression: nil
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: ifE)
    )
  }

  func test_parse_if_else_statement() throws {
    let expr = try parse("if 3 then 2 else true")
    let ifE = IfExpression(
      condition: LiteralExpression(value: 3),
      thenExpression: LiteralExpression<Int>(value: 2),
      elseExpression: LiteralExpression<Bool>(value: true)
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: ifE)
    )
  }

  func test_parse_if_expression_as_part_of_other_expression() throws {
    let expr = try parse("1 + if true then 2 else 3")
    let bOpE = BinaryOpExpression(
      left: LiteralExpression(value: 1),
      op: "+",
      right: IfExpression(
        condition: LiteralExpression<Bool>(value: true),
        thenExpression: LiteralExpression<Int>(value: 2),
        elseExpression: LiteralExpression<Int>(value: 3)
      )
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_parse_function_call() throws {
    let expr = try parse("foo(1, 2)")
    let fCEx = FunctionCallExpression(
      identifier: IdentifierExpression(value: "foo"),
      arguments: [LiteralExpression<Int>(value: 1), LiteralExpression<Int>(value: 2)]
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: fCEx)
    )
  }

  func test_parse_function_call_with_no_parameters() throws {
    let expr = try parse("foo()")
    let fCEx = FunctionCallExpression(identifier: IdentifierExpression(value: "foo"), arguments: [])
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: fCEx)
    )
  }
}

extension ParserTests {
  func test_parse_assignment_operator() throws {
    let expr = try parse("a = 1 + 2 - 3")
    let bOpE = BinaryOpExpression(
      left: IdentifierExpression(value: "a"),
      op: "=",
      right: BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
        op: "-",
        right: LiteralExpression(value: 3)
      )
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: bOpE)
    )
  }

  func test_parse_not_expression() throws {
    let expr = try parse("not true")
    let nExpr = NotExpression(value: LiteralExpression<Bool>(value: true))
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: nExpr)
    )
  }

  func test_parse_not_not_expression() throws {
    let expr = try parse("not not false")
    let litExpr = LiteralExpression(value: false)
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: litExpr)
    )
  }

  func test_parse_block_expression() throws {
    let input = """
      {
        a = 1 + 2 - 3;
        if 2 > 4 then {
          foo(a);
        } else {
          foo(1);
        }
      }
      """
    let expr = try parse(input)
    let blockExpression = BlockExpression(
      statements: [
        BinaryOpExpression(
          left: IdentifierExpression(value: "a"), op: "=",
          right: BinaryOpExpression(
            left: BinaryOpExpression(
              left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
            op: "-", right: LiteralExpression(value: 3)))
      ],
      resultExpression: IfExpression(
        condition: BinaryOpExpression(
          left: LiteralExpression(value: 2), op: ">", right: LiteralExpression(value: 4)),
        thenExpression: BlockExpression(
          statements: [
            FunctionCallExpression(
              identifier: IdentifierExpression(value: "foo"),
              arguments: [IdentifierExpression(value: "a")])
          ], resultExpression: nil),
        elseExpression: BlockExpression(
          statements: [
            FunctionCallExpression(
              identifier: IdentifierExpression(value: "foo"),
              arguments: [LiteralExpression(value: 1)])
          ], resultExpression: nil))
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: blockExpression)
    )
  }

  func test_parse_variable_declaration() throws {
    let expr = try parse("{ var a = 1 + 2 - 3; }")
    let varDecl = VarDeclarationExpression(
      variableIdentifier: IdentifierExpression(value: "a"),
      variableValue: BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
        op: "-", right: LiteralExpression(value: 3)),
      variableType: nil
    )
    XCTAssertEqual(
      expr,
      BlockExpression(
        statements: [],
        resultExpression: BlockExpression(statements: [varDecl], resultExpression: nil))
    )
  }

  func test_parse_variable_expression_with_type() throws {
    let input = """
      {
        var a: Int = 1 + 2 - 3;
        var b: Bool = true;
      }
      """
    let expr = try parse(input)
    let blockExpr = BlockExpression(
      statements: [
        VarDeclarationExpression(
          variableIdentifier: IdentifierExpression(value: "a"),
          variableValue: BinaryOpExpression(
            left: BinaryOpExpression(
              left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
            op: "-", right: LiteralExpression(value: 3)),
          variableType: .int),
        VarDeclarationExpression(
          variableIdentifier: IdentifierExpression(value: "b"),
          variableValue: LiteralExpression<Bool>(value: true),
          variableType: .bool)
      ], resultExpression: nil
    )
    XCTAssertEqual(
      expr,
      BlockExpression(
        statements: [], resultExpression: blockExpr)
    )
  }

  func test_parsing_invalid_blocks_throw_error() throws {
    let inputs = ["{ a b }", "{ if true then { a } b c }"]
    try inputs.forEach { XCTAssertThrowsError(try parse($0)) }
  }

  func test_parsing_valid_blocks_does_not_throw() throws {
    let inputs = [
      "{ { a } { b } }",
      "{ if true then { a } b }",
      "{ if true then { a }; b }",
      "{ if true then { a } b; c }",
      "{ if true then { a } else { b } 3 }",
      "x = { { f(a) } { b } }"
    ]

    try inputs.forEach { XCTAssertNoThrow(try parse($0)) }
  }

  func test_parsing_while_expression() throws {
    let expr = try parse("while true do { a = a + 1; }")
    let whileExpr = WhileExpression(
      condition: LiteralExpression<Bool>(value: true),
      body: BlockExpression(
        statements: [
          BinaryOpExpression(
            left: IdentifierExpression(value: "a"), op: "=",
            right: BinaryOpExpression(
              left: IdentifierExpression(value: "a"), op: "+", right: LiteralExpression(value: 1))
          )
        ], resultExpression: nil
      )
    )
    XCTAssertEqual(
      expr,
      BlockExpression(statements: [], resultExpression: whileExpr)
    )
  }
}

extension ParserTests {
  func tokenizeInput(_ input: String) throws -> [Token] {
    var tokenizer = Tokenizer(input: input)
    try tokenizer.tokenize()
    return tokenizer.tokens
  }

  func parse(_ input: String) throws -> BlockExpression {
    var parser = Parser(tokens: try tokenizeInput(input))
    return try parser.parse()
  }
}

struct ParserHelper<T: Expression> {
  // swiftlint:disable:next identifier_name
  let e: T

  init?(_ expression: (any Expression)?) {
    if let expression = expression as? T {
      self.e = expression
    } else {
      XCTFail("Expected \(T.self), got \(String(describing: expression))")
      return nil
    }
  }
}
