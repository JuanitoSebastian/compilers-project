enum ParserError: Error, Equatable {
  case unexpectedTokenValue(token: Token, expected: [String])
  case unexpectedTokenType(token: Token, expected: [TokenType])
  case noTokenFound(precedingToken: Token?)
  case failedToParseLiteralValue(token: Token, triedToParse: String)
  case ifExpressionMissingCondition(ifIdentifierToken: Token)
  case ifExpressionMissingThenExpression(ifIdentifierToken: Token)
  case missingSemicolon(token: Token)
  case varDeclarationMissingExpression(varIdentifierExpression: IdentifierExpression)
  case varDeclarationInvalid(token: Token? = nil)
  case varDeclarationUnknownType(varIdentifierExpression: IdentifierExpression)
  case whileExpressionMissingCondition
}
