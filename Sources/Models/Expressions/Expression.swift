protocol Expression: Equatable, CustomStringConvertible {
  var expressionType: ExpressionType { get }
  var description: String { get }
  static func == (lhs: Self, rhs: Self) -> Bool
}
