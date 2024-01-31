protocol Expression: Equatable, CustomStringConvertible {
  var type: ExpressionType { get }
  var description: String { get }
  static func == (lhs: Self, rhs: Self) -> Bool
}
