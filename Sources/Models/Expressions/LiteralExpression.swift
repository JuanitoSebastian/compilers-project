struct LiteralExpression<Element>: Expression, Equatable, CustomStringConvertible
where Element: LiteralExpressionValue, Element: Equatable {
  let type: ExpressionType = .literal
  let value: Element

  static func == (lhs: LiteralExpression<Element>, rhs: LiteralExpression<Element>) -> Bool {
    return lhs.type == rhs.type && lhs.value == rhs.value
  }

  var description: String {
    return "\(value)"
  }
}

protocol LiteralExpressionValue {}
extension Int: LiteralExpressionValue {}
extension Bool: LiteralExpressionValue {}
