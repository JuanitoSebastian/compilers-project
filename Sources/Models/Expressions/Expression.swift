protocol Expression: Equatable, CustomStringConvertible {
  var expressionType: ExpressionType { get }
  var description: String { get }
  var location: Location? { get }
  static func == (lhs: Self, rhs: Self) -> Bool
}
