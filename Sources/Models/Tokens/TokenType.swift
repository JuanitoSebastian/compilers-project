enum TokenType: CaseIterable, CustomStringConvertible {
  case integerLiteral
  case booleanLiteral
  case lineComment
  case op
  case identifier
  case punctuation
  case newLine

  var regex: String {
    switch self {
    case .integerLiteral:
      return INTEGER_REGEX
    case .booleanLiteral:
      return BOOLEAN_REGEX
    case .op:
      return OPERATOR_REGEX
    case .punctuation:
      return PUNCTUATION_REGEX
    case .identifier:
      return IDENTIFIER_REGEX
    case .lineComment:
      return LINE_COMMENT_REGEX
    case .newLine:
      return NEWLINE_REGEX
    }
  }

  var description: String {
    switch self {
    case .integerLiteral:
      return "integer literal"
    case .booleanLiteral:
      return "boolean literal"
    case .op:
      return "operator"
    case .punctuation:
      return "punctuation"
    case .identifier:
      return "identifier"
    case .lineComment:
      return "line comment"
    case .newLine:
      return "new line"
    }
  }
}

let INTEGER_REGEX = "^[0-9]+"
let BOOLEAN_REGEX = "^true|^false"
let IDENTIFIER_REGEX = "^[a-zA-Z][a-zA-Z0-9]*"
let OPERATOR_REGEX = "^={1,2}|^<=|^>=|^!=|^[-+*/%<>]|^and|^or"
let LINE_COMMENT_REGEX = "^//.*\n"
let PUNCTUATION_REGEX = "^[(|)|{|}|[|]|;]"
let NEWLINE_REGEX = "^\n"
