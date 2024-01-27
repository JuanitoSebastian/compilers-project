struct BinaryOpExpression: Equatable, Expression {
  let type: ExpressionType = .binaryOp
  let left: any Expression
  let op: String
  let right: any Expression

  static func == (lhs: BinaryOpExpression, rhs: BinaryOpExpression) -> Bool {
    var leftSame = false
    var rightSame = false
    if lhs.left.type == rhs.left.type && lhs.op == rhs.op && lhs.right.type == rhs.right.type {
      switch lhs.left.type {
      case .literal:
        leftSame = (lhs.left as? LiteralExpression<Int>) == (rhs.left as? LiteralExpression<Int>)
      case .identifier:
        leftSame = (lhs.left as? IdentifierExpression) == (rhs.left as? IdentifierExpression)
      case .binaryOp:
        leftSame = (lhs.left as? BinaryOpExpression) == (rhs.left as? BinaryOpExpression)
      }
      switch lhs.right.type {
      case .literal:
        rightSame = (lhs.right as? LiteralExpression<Int>) == (rhs.right as? LiteralExpression<Int>)
      case .identifier:
        rightSame = (lhs.right as? IdentifierExpression) == (rhs.right as? IdentifierExpression)
      case .binaryOp:
        rightSame = (lhs.right as? BinaryOpExpression) == (rhs.right as? BinaryOpExpression)
      }
      return leftSame && rightSame
    }
    return false
  }
}
