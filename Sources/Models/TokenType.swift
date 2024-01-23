enum TokenType: CaseIterable {
  case integerLiteral
  case lineComment
  case op
  case identifier
  case puncuation

  var regex: String {
    switch self {
    case .integerLiteral:
      return INTEGER_REGEX
    case .op:
      return OPERATOR_REGEX
    case .puncuation:
      return "^[(),]"
    case .identifier:
      return IDENTIFIER_REGEX
    case .lineComment:
      return LINE_COMMENT_REGEX
    }
  }
}

let INTEGER_REGEX = "^[0-9]+"
let IDENTIFIER_REGEX = "^[a-zA-Z][a-zA-Z0-9]*"
let OPERATOR_REGEX = "^[\\-+*/]$"
let LINE_COMMENT_REGEX = "^//.*\n"
