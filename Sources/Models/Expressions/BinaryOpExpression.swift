struct BinaryOpExpression: Equatable, Expression {
  let type: ExpressionType = .binaryOp
  let left: any Expression
  let op: String
  let right: any Expression

  static func == (lhs: BinaryOpExpression, rhs: BinaryOpExpression) -> Bool {
    return areExpressionsEqual(lhs.left, rhs.left)
      && lhs.op == rhs.op
      && areExpressionsEqual(lhs.right, rhs.right)
  }
}
