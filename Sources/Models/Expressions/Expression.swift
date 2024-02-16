protocol Expression: Equatable, CustomStringConvertible {
  var expressionType: ExpressionType { get }
  var description: String { get }
  var location: Location? { get }
  var type: Type? { get set }
  static func == (lhs: Self, rhs: Self) -> Bool
}
