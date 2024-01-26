struct BinaryOpExpression: Expression {
  let type: ExpressionType = .binaryOp
  let left: Expression
  let op: String
  let right: Expression
}
