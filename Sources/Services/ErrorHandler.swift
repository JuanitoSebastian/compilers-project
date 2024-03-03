import ColorizeSwift

struct ErrorHandler: Decodable {

  func handleError(_ error: Error) {
    switch error {
    case let error as AssemblyGeneratorError:
      let (message, location) = handleAssemblyGeneratorError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as IrGeneratorError:
      let (message, location) = handleIrGeneratorError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as TypecheckerError:
      let (message, location) = handleTypecheckerError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as LocalsError:
      let (message, location) = handleLocalsError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as LocationError:
      let (message, location) = handleLocationError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as ParserError:
      let (message, location) = handleParserError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as RegexMatcherError:
      let (message, location) = handleRegexMatcherError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as SwiftCompilerError:
      let (message, location) = handleSwiftCompilerError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    case let error as SymTabError:
      let (message, location) = handleSymTabError(error)
      print("\(getLocationDescription(location)) \("error".red()) \(message)")
    default:
      print(error)
    }
  }

  private func handleAssemblyGeneratorError(_ error: AssemblyGeneratorError) -> (
    message: String, location: Location?
  ) {
    switch error {
    case .unknownIntrinsicsOperator(let op):
      return ("Found unknown intrinsics operator: \(op.bold())", nil)
    }
  }

  func handleIrGeneratorError(_ error: IrGeneratorError) -> (message: String, location: Location?) {
    switch error {
    case .unsupportedExpression(let expression):
      return ("Unsupported expression: \(expression)", expression.location)
    case .referenceToUndefinedFunction(let function):
      return ("Reference to undefined function: \(function.bold())", nil)
    case .referenceToUndefinedVar(let identifier):
      return ("Reference to undefined variable: \(identifier.value.bold())", identifier.location)
    case .missingType(let expression):
      return ("Missing type for expression: \(expression)", expression.location)
    case .missingLocation(let expression):
      return ("Missing location for expression: \(expression)", expression.location)
    case .duplicateVarDeclaration(let varDec):
      let location = varDec.location
      let message = "Duplicate variable declaration: \(varDec.variableIdentifier.value)"
      return (message, location)
    }
  }

  private func handleTypecheckerError(_ error: TypecheckerError) -> (
    message: String, location: Location?
  ) {
    switch error {
    case .unknownExpressionType(let type, let location):
      return ("Unknown expression type: \(type.bold())", location)
    case .inaproppriateUnaryOp(let expected, let got, let location):
      let message = "Inappropriate unary operator, expected: \(expected), got: \(got)"
      return (message, location)
    case .wrongNumberOfArguments(let expected, let got, let location):
      let message = "Wrong number of arguments, expected: \(expected), got: \(got)"
      return (message, location)
    case .referenceToUndefinedIdentifier(let identifier, let location):
      return ("Reference to undefined identifier: \(identifier.bold())", location)
    case .unsupportedOperator(let op, let location):
      return ("Found unsupported operator: \(op.bold())", location)
    case .inaproppriateFunctionParameterType(let expected, let got, let location):
      let gottenTypes = got.compactMap { $0?.name }.joined(separator: ", ")
      let expectedTypes = expected.compactMap { getFunctionParameterTypeDescription($0) }.joined(
        separator: ", ")
      let message =
        "Inappropriate function parameter type, expected: \(expectedTypes), got: \(gottenTypes)"
      return (message, location)
    case .inaproppriateType(let expected, let got, let location):
      let gottenTypes = got.compactMap { $0?.name }.joined(separator: ", ")
      let expectedTypes = expected.compactMap { $0?.name }.joined(separator: ", ")
      let message = "Inappropriate type, expected: \(expectedTypes), got: \(gottenTypes)"
      return (message, location)
    case .identifierAlreadyDeclared(let identifier, let location):
      return ("Identifier \(identifier.bold()) already declared", location)
    }
  }

  private func handleLocalsError(_ error: LocalsError) -> (message: String, location: Location?) {
    switch error {
    case .irVarNotFound(let irVar):
      return ("IR variable not found: \(irVar)", nil)
    }
  }

  private func handleLocationError(_ error: LocationError) -> (message: String, location: Location?)
  {
    switch error {
    case .combineFromDifferentFiles(let lhs, let rhs):
      return ("Trying to combine location from two files: \(lhs ?? "nil") and \(rhs ?? "nil")", nil)
    }
  }

  private func handleParserError(_ error: ParserError) -> (message: String, location: Location?) {
    switch error {
    case .unexpectedTokenValue(let token, let expected):
      let message = "Unexpected token value: \(token.value.bold()), expected: \(expected)"
      return (message, token.location)
    case .unexpectedTokenType(let token, let expected):
      let expectedTypes = expected.map { $0.description }.joined(separator: ", ")
      let message = "Unexpected token type: \(token.type), expected: \(expectedTypes)"
      return (message, token.location)
    case .noTokenFound(let precedingToken):
      if let precedingToken = precedingToken {
        return ("No token found after: \(precedingToken.value)", precedingToken.location)
      }
      return ("No token found", nil)
    case .failedToParseLiteralValue(let token, let triedToParse):
      return ("Failed to parse literal value: \(triedToParse)", token.location)
    case .ifExpressionMissingCondition(let ifIdentifierToken):
      return ("If expression missing condition", ifIdentifierToken.location)
    case .ifExpressionMissingThenExpression(let ifIdentifierToken):
      return ("If expression missing then expression", ifIdentifierToken.location)
    case .missingSemicolon(let token):
      return ("Missing semicolon", token.location)
    case .varDeclarationMissingExpression(let varIdentifierExpression):
      return ("Variable declaration missing value", varIdentifierExpression.location)
    case .varDeclarationInvalid(let token):
      return ("Variable declaration invalid", token?.location)
    case .varDeclarationUnknownType(let varIdentifierExpression):
      return ("Variable declaration unknown type", varIdentifierExpression.location)
    case .whileExpressionMissingCondition:
      return ("While expression missing condition", nil)
    }
  }

  private func handleRegexMatcherError(_ error: RegexMatcherError) -> (
    message: String, location: Location?
  ) {
    switch error {
    case .invalidRangeForInput(let input, let range):
      return ("Invalid range for input: \(input), range: \(range)", nil)
    }
  }

  private func handleSwiftCompilerError(_ error: SwiftCompilerError) -> (
    message: String, location: Location?
  ) {
    switch error {
    case .noInputProvided:
      return ("No input was provided", nil)
    }
  }

  private func handleSymTabError(_ error: SymTabError) -> (message: String, location: Location?) {
    switch error {
    case .noTableToInsert:
      return ("No table in SymTab to insert value to", nil)
    case .popLastTable:
      return ("Trying to pop last table from SymTab", nil)
    }
  }

  private func getLocationDescription(_ location: Location?) -> String {
    guard let location = location else {
      return ""
    }

    if let file = location.file {
      return "\(file):\(location.line):\(location.position):"
    }

    return "\(location.line):\(location.position):"
  }

  private func getFunctionParameterTypeDescription(_ type: FunctionParameterType?) -> String {
    switch type {
    case .equalType:
      return "equal type"
    case .definiteType(let type):
      return "(\(type?.name ?? "nil")"
    case .none:
      return "nil"
    }
  }
}
