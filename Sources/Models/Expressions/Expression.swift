protocol Expression: Equatable {
  var type: ExpressionType { get }
  static func == (lhs: Self, rhs: Self) -> Bool
}
