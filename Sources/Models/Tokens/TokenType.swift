enum TokenType: CaseIterable {
  case integerLiteral
  case lineComment
  case op
  case identifier
  case punctuation
  case newLine

  var regex: String {
    switch self {
    case .integerLiteral:
      return INTEGER_REGEX
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
}

let INTEGER_REGEX = "^[0-9]+"
let IDENTIFIER_REGEX = "^[a-zA-Z][a-zA-Z0-9]*"
let OPERATOR_REGEX = "^={1,2}|^[-+*/]$"
let LINE_COMMENT_REGEX = "^//.*\n"
let PUNCTUATION_REGEX = "^[(|)|{|}|[|]]"
let NEWLINE_REGEX = "^\n"
