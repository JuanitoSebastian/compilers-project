struct LiteralExpression<Element>: Expression, Equatable where Element: LiteralExpressionValue, Element: Equatable {
  let type: ExpressionType = .literal
  let value: Element

  static func == (lhs: LiteralExpression<Element>, rhs: LiteralExpression<Element>) -> Bool {
    return lhs.type == rhs.type && lhs.value == rhs.value
  }
}

protocol LiteralExpressionValue {}
extension Int: LiteralExpressionValue {}
extension Bool: LiteralExpressionValue {}
