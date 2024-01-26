struct LiteralExpression<Element> where Element: LitelExpressionRawValue {
  let value: Element
}

protocol LitelExpressionRawValue { }
extension Int: LitelExpressionRawValue { }
extension Bool: LitelExpressionRawValue { }
