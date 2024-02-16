struct BinaryOpExpression: Equatable, Expression, CustomStringConvertible {
  let expressionType: ExpressionType = .binaryOp
  let left: any Expression
  let op: String
  let right: any Expression
  let location: Location?
  var type: Type?

  init(
    left: any Expression, op: String, right: any Expression, location: Location? = nil
  ) {
    self.left = left
    self.op = op
    self.right = right
    self.location = location
  }

  static func == (lhs: BinaryOpExpression, rhs: BinaryOpExpression) -> Bool {
    return areExpressionsEqual(lhs.left, rhs.left)
      && lhs.op == rhs.op
      && areExpressionsEqual(lhs.right, rhs.right)
  }

  var description: String {
    return "BinaryOpExpression: (\(left) \(op) \(right))"
  }
}
