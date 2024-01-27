struct BinaryOpExpression<T1, T2>: Equatable, Expression where T1: Expression, T2: Expression {
  let type: ExpressionType = .binaryOp
  let left: T1
  let op: String
  let right: T2

  static func == (lhs: BinaryOpExpression, rhs: BinaryOpExpression) -> Bool {
    return lhs.type == rhs.type && lhs.left == rhs.left && lhs.op == rhs.op && lhs.right == rhs.right
  }
}
