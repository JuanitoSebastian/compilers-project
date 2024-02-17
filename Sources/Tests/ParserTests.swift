import XCTest

@testable import swiftcompiler

final class ParserTests: XCTestCase {
  func test_parse_addition_with_ints() throws {
    var parser = Parser(tokens: try tokenizeInput("1 + 2"))
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)))
  }

  func test_parse_addition_with_int_and_identifier() throws {
    var parser = Parser(tokens: try tokenizeInput("1 + a"))
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+", right: IdentifierExpression(value: "a")))
  }

  func test_parse_operation_with_multiple_numbers() throws {
    var parser = Parser(tokens: try tokenizeInput("10 + a - 3"))
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 10), op: "+", right: IdentifierExpression(value: "a")),
        op: "-", right: LiteralExpression(value: 3)))
  }

  func test_parse_multiplication() throws {
    var parser = Parser(tokens: try tokenizeInput("2 - 10 * 2"))
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 2), op: "-",
        right: BinaryOpExpression(
          left: LiteralExpression(value: 10), op: "*", right: LiteralExpression(value: 2))))
  }

  func test_parse_parentesis() throws {
    var parser = Parser(tokens: try tokenizeInput("(2 - 10) * 2"))
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 2), op: "-", right: LiteralExpression(value: 10)), op: "*",
        right: LiteralExpression(value: 2)))
  }

  func test_orphan_plus_sign_throws() throws {
    var parser = Parser(tokens: try tokenizeInput("1 + 2 +"))
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.noTokenFound(precedingToken: Token(type: .op, value: "+", location: L(0, 6))))
    }
  }

  func test_oprhan_multiply_sign_throws() throws {
    var parser = Parser(tokens: try tokenizeInput("1 + 2 *"))
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.noTokenFound(precedingToken: Token(type: .op, value: "*", location: L(0, 6))))
    }
  }

  func test_empty_parentheses_throws() throws {
    var parser = Parser(tokens: try tokenizeInput("()"))
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.unexpectedTokenType(
          token: Token(type: .punctuation, value: ")", location: L(0, 1)),
          expected: [TokenType.integerLiteral, TokenType.identifier]))
    }
  }

  func test_parse_if_statement() throws {
    var parser = Parser(tokens: try tokenizeInput("if false then 2 "))
    let ifExpression = ParserHelper<IfExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      ifExpression,
      IfExpression(
        condition: LiteralExpression<Bool>(value: false),
        thenExpression: LiteralExpression<Int>(value: 2), elseExpression: nil))
  }

  func test_parse_if_else_statement() throws {
    var parser = Parser(tokens: try tokenizeInput("if 3 then 2 else true"))
    let ifExpression = ParserHelper<IfExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      ifExpression,
      IfExpression(
        condition: LiteralExpression(value: 3), thenExpression: LiteralExpression<Int>(value: 2),
        elseExpression: LiteralExpression<Bool>(value: true)))
  }

  func test_parse_if_expression_as_part_of_other_expression() throws {
    var parser = Parser(tokens: try tokenizeInput("1 + if true then 2 else 3"))
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+",
        right: IfExpression(
          condition: LiteralExpression<Bool>(value: true),
          thenExpression: LiteralExpression<Int>(value: 2),
          elseExpression: LiteralExpression<Int>(value: 3))))
  }

  func test_parse_function_call() throws {
    var parser = Parser(tokens: try tokenizeInput("foo(1, 2)"))
    let functionCallExpression = ParserHelper<FunctionCallExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      functionCallExpression,
      FunctionCallExpression(
        identifier: IdentifierExpression(value: "foo"),
        arguments: [LiteralExpression<Int>(value: 1), LiteralExpression<Int>(value: 2)]))
  }

  func test_parse_function_call_with_no_parameters() throws {
    var parser = Parser(tokens: try tokenizeInput("foo()"))
    let functionCallExpression = ParserHelper<FunctionCallExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      functionCallExpression,
      FunctionCallExpression(identifier: IdentifierExpression(value: "foo"), arguments: []))
  }
}

extension ParserTests {
  func test_parse_assignment_operator() throws {
    var parser = Parser(tokens: try tokenizeInput("a = 1 + 2 - 3"))
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: IdentifierExpression(value: "a"), op: "=",
        right: BinaryOpExpression(
          left: BinaryOpExpression(
            left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
          op: "-", right: LiteralExpression(value: 3))))
  }

  func test_parse_not_expression() throws {
    var parser = Parser(tokens: try tokenizeInput("not 5"))
    let noExpression = ParserHelper<NotExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(noExpression, NotExpression(value: LiteralExpression<Int>(value: 5)))
  }

  func test_parse_not_not_expression() throws {
    var parser = Parser(tokens: try tokenizeInput("not not 5"))
    let intLiteralExpression = ParserHelper<LiteralExpression<Int>>(try parser.parse()[0])!.e
    XCTAssertEqual(intLiteralExpression, LiteralExpression<Int>(value: 5))
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
    var parser = Parser(tokens: try tokenizeInput(input))
    let blockExpression = ParserHelper<BlockExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      blockExpression,
      BlockExpression(
        statements: [
          BinaryOpExpression(
            left: IdentifierExpression(value: "a"), op: "=",
            right: BinaryOpExpression(
              left: BinaryOpExpression(
                left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
              op: "-", right: LiteralExpression(value: 3))),
          IfExpression(
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
        ], resultExpression: nil))
  }

  func test_parse_variable_declaration() throws {
    var parser = Parser(tokens: try tokenizeInput("{ var a = 1 + 2 - 3; }"))
    let blockExpressionWithVarDeclaration = ParserHelper<BlockExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      blockExpressionWithVarDeclaration,
      BlockExpression(
        statements: [
          VarDeclarationExpression(
            variableIdentifier: IdentifierExpression(value: "a"),
            variableValue: BinaryOpExpression(
              left: BinaryOpExpression(
                left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
              op: "-", right: LiteralExpression(value: 3)),
            variableType: nil)
        ], resultExpression: nil))
  }

  func test_parse_variable_expression_with_type() throws {
    let input = """
      {
        var a: Int = 1 + 2 - 3;
        var b: Bool = true;
      }
      """
    var parser = Parser(tokens: try tokenizeInput(input))
    let varDeclarationExpression = ParserHelper<BlockExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      varDeclarationExpression,
      BlockExpression(
        statements: [
          VarDeclarationExpression(
            variableIdentifier: IdentifierExpression(value: "a"),
            variableValue: BinaryOpExpression(
              left: BinaryOpExpression(
                left: LiteralExpression<Int>(value: 1), op: "+",
                right: LiteralExpression<Int>(value: 2)), op: "-",
              right: LiteralExpression(value: 3)),
            variableType: .int),
          VarDeclarationExpression(
            variableIdentifier: IdentifierExpression(value: "b"),
            variableValue: LiteralExpression<Bool>(value: true),
            variableType: .bool)
        ], resultExpression: nil))
  }

  func test_parsing_invalid_blocks_throw_error() throws {
    let inputs = ["{ a b }", "{ if true then { a } b c }"]
    for input in inputs {
      var parser = Parser(tokens: try tokenizeInput(input))
      XCTAssertThrowsError(try parser.parse())
    }
  }

  func test_parsing_valid_blocks_does_not_throw() throws {
    let inputs = [
      "{ { a } { b } }", "{ if true then { a } b }", "{ if true then { a }; b }",
      "{ if true then { a } b; c }", "{ if true then { a } else { b } 3 }",
      "x = { { f(a) } { b } }"
    ]
    for input in inputs {
      var parser = Parser(tokens: try tokenizeInput(input))
      XCTAssertNoThrow(try parser.parse())
    }
  }

  func test_parsing_while_expression() throws {
    var parser = Parser(tokens: try tokenizeInput("while true do { a = a + 1; }"))
    let whileExpression = ParserHelper<WhileExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      whileExpression,
      WhileExpression(
        condition: LiteralExpression(value: true),
        body: BlockExpression(
          statements: [
            BinaryOpExpression(
              left: IdentifierExpression(value: "a"), op: "=",
              right: BinaryOpExpression(
                left: IdentifierExpression(value: "a"), op: "+", right: LiteralExpression(value: 1))
            )
          ], resultExpression: nil)))
  }
}

extension ParserTests {
  func tokenizeInput(_ input: String) throws -> [Token] {
    var tokenizer = Tokenizer(input: input)
    try tokenizer.tokenize()
    return tokenizer.tokens
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
