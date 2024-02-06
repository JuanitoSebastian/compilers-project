import XCTest

@testable import swiftcompiler

final class ParserTests: XCTestCase {
  func test_parse_addition_with_ints() throws {
    var tokenizer = Tokenizer(input: "1 + 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)))
  }

  func test_parse_addition_with_int_and_identifier() throws {
    var tokenizer = Tokenizer(input: "1 + a")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1), op: "+", right: IdentifierExpression(value: "a")))
  }

  func test_parse_operation_with_multiple_numbers() throws {
    var tokenizer = Tokenizer(input: "10 + a - 3")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 10), op: "+", right: IdentifierExpression(value: "a")),
        op: "-",
        right: LiteralExpression(value: 3)))
  }

  func test_parse_multiplication() throws {
    var tokenizer = Tokenizer(input: "2 - 10 * 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 2),
        op: "-",
        right: BinaryOpExpression(
          left: LiteralExpression(value: 10), op: "*", right: LiteralExpression(value: 2))))
  }

  func test_parse_parentesis() throws {
    var tokenizer = Tokenizer(input: "(2 - 10) * 2")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: BinaryOpExpression(
          left: LiteralExpression(value: 2), op: "-", right: LiteralExpression(value: 10)),
        op: "*",
        right: LiteralExpression(value: 2)))
  }

  func test_orphan_plus_sign_throws() throws {
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

  func test_oprhan_multiply_sign_throws() throws {
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

  func test_empty_parentheses_throws() throws {
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

  func test_parse_if_statement() throws {
    var tokenizer = Tokenizer(input: "if false then 2 ")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let ifExpression = ParserHelper<IfExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      ifExpression,
      IfExpression(
        condition: LiteralExpression<Bool>(value: false),
        thenExpression: LiteralExpression<Int>(value: 2),
        elseExpression: nil))
  }

  func test_parse_if_else_statement() throws {
    var tokenizer = Tokenizer(input: "if 3 then 2 else true")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let ifExpression = ParserHelper<IfExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      ifExpression,
      IfExpression(
        condition: LiteralExpression(value: 3),
        thenExpression: LiteralExpression<Int>(value: 2),
        elseExpression: LiteralExpression<Bool>(value: true)))
  }

  func test_parse_if_expression_as_part_of_other_expression() throws {
    var tokenizer = Tokenizer(input: "1 + if true then 2 else 3")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: LiteralExpression(value: 1),
        op: "+",
        right: IfExpression(
          condition: LiteralExpression<Bool>(value: true),
          thenExpression: LiteralExpression<Int>(value: 2),
          elseExpression: LiteralExpression<Int>(value: 3)))
    )
  }

  func test_parse_function_call() throws {
    var tokenizer = Tokenizer(input: "foo(1, 2)")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let functionCallExpression = ParserHelper<FunctionCallExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      functionCallExpression,
      FunctionCallExpression(
        identifier: IdentifierExpression(value: "foo"),
        arguments: [
          LiteralExpression<Int>(value: 1),
          LiteralExpression<Int>(value: 2)
        ]))
  }

  func test_parse_function_call_with_no_parameters() throws {
    var tokenizer = Tokenizer(input: "foo()")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let functionCallExpression = ParserHelper<FunctionCallExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      functionCallExpression,
      FunctionCallExpression(
        identifier: IdentifierExpression(value: "foo"),
        arguments: []))
  }
}

extension ParserTests {
  func test_parse_assignment_operator() throws {
    var tokenizer = Tokenizer(input: "a = 1 + 2 - 3")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let binaryOpExpression = ParserHelper<BinaryOpExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      binaryOpExpression,
      BinaryOpExpression(
        left: IdentifierExpression(value: "a"),
        op: "=",
        right: BinaryOpExpression(
          left: BinaryOpExpression(
            left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
          op: "-",
          right: LiteralExpression(value: 3))))
  }

  func test_parse_not_expression() throws {
    var tokenizer = Tokenizer(input: "not 5")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let noExpression = ParserHelper<NotExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(noExpression, NotExpression(value: LiteralExpression<Int>(value: 5)))
  }

  func test_parse_not_not_expression() throws {
    var tokenizer = Tokenizer(input: "not not 5")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let intLiteralExpression = ParserHelper<LiteralExpression<Int>>(try parser.parse()[0])!.e
    XCTAssertEqual(
      intLiteralExpression,
      LiteralExpression<Int>(value: 5))
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
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let blockExpression = ParserHelper<BlockExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      blockExpression,
      BlockExpression(
        statements: [
          BinaryOpExpression(
            left: IdentifierExpression(value: "a"),
            op: "=",
            right: BinaryOpExpression(
              left: BinaryOpExpression(
                left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
              op: "-",
              right: LiteralExpression(value: 3))),
          IfExpression(
            condition: BinaryOpExpression(
              left: LiteralExpression(value: 2), op: ">", right: LiteralExpression(value: 4)),
            thenExpression: BlockExpression(
              statements: [
                FunctionCallExpression(
                  identifier: IdentifierExpression(value: "foo"),
                  arguments: [IdentifierExpression(value: "a")])
              ],
              resultExpression: nil),
            elseExpression: BlockExpression(
              statements: [
                FunctionCallExpression(
                  identifier: IdentifierExpression(value: "foo"),
                  arguments: [LiteralExpression(value: 1)])
              ],
              resultExpression: nil)
          )
        ],
        resultExpression: nil))
  }

  func test_parse_variable_declaration_in_block() throws {
    var tokenizer = Tokenizer(input: "{ var a = 1 + 2 - 3; }")
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    let blockExpressionWithVarDeclaration = ParserHelper<BlockExpression>(try parser.parse()[0])!.e
    XCTAssertEqual(
      blockExpressionWithVarDeclaration,
      BlockExpression(
        statements: [
          VarDeclarationExpression(
            declaration: BinaryOpExpression(
              left: IdentifierExpression(value: "a"),
              op: "=",
              right: BinaryOpExpression(
                left: BinaryOpExpression(
                  left: LiteralExpression(value: 1), op: "+", right: LiteralExpression(value: 2)),
                op: "-",
                right: LiteralExpression(value: 3))
            )
          )
        ], resultExpression: nil))
  }

  func test_parser_throws_when_var_declaration_outside_block() throws {
    let input = """
      {
        foo(1, 2);
      }
      var a = 1 + 2 - 3;
      """
    var tokenizer = Tokenizer(input: input)
    tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual(
        error as? ParserError,
        ParserError.varDeclarationOutsideBlock())
    }
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
