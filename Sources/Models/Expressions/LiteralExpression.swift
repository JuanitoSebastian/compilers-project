struct LiteralExpression<Element>: Expression, Equatable, CustomStringConvertible
where Element: LiteralExpressionValue, Element: Equatable {
  let expressionType: ExpressionType = .literal
  let value: Element
  let location: Location?

  init(value: Element, location: Location? = nil) {
    self.value = value
    self.location = location
  }

  static func == (lhs: LiteralExpression<Element>, rhs: LiteralExpression<Element>) -> Bool {
    return lhs.expressionType == rhs.expressionType && lhs.value == rhs.value
  }

  var description: String {
    return "\(value)"
  }
}

protocol LiteralExpressionValue {
  init?(_ value: String)
}
extension Int: LiteralExpressionValue {}
extension Bool: LiteralExpressionValue {}
