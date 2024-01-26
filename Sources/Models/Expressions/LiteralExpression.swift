struct LiteralExpression<Element>: Expression where Element: LitelExpressionValue {
  let type: ExpressionType = .literal
  let value: Element
}

protocol LitelExpressionValue {}
extension Int: LitelExpressionValue {}
extension Bool: LitelExpressionValue {}
