struct IntrinsicsHandler {
  func handleIntrinsic(_ op: String, _ args: IntrinsicsArgs) throws -> [String] {
    switch op {
    case "+":
      return plus(args)
    case "-":
      return minus(args)
    case "*":
      return multiply(args)
    case "/":
      return divide(args)
    case "%":
      return remainder(args)
    case "==":
      return equals(args)
    case "!=":
      return notEquals(args)
    case "<":
      return lessThan(args)
    case "<=":
      return lessThanOrEqual(args)
    case ">":
      return greaterThan(args)
    case ">=":
      return greaterThanOrEqual(args)
    case "unary_-":
      return unaryMinus(args)
    case "unary_not":
      return unaryNot(args)
    default:
      throw AssemblyGeneratorError.unknownIntrinsicsOperator(op)
    }
  }

  func unaryMinus(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    result.append("movq \(args.argsRefs[0]), %rax")
    result.append("negq %rax")
    if args.resultRegister != "%rax" {
      result.append("movq %rax, \(args.resultRegister)")
    }
    return result
  }

  func unaryNot(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    result.append("movq \(args.argsRefs[0]), \(args.resultRegister)")
    result.append("xorq $1, \(args.resultRegister)")
    return result
  }

  func plus(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    result.append("movq \(args.argsRefs[0]), %rax")
    result.append("addq \(args.argsRefs[1]), %rax")
    if args.resultRegister != "%rax" {
      result.append("movq %rax, \(args.resultRegister)")
    }
    return result
  }

  func minus(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    result.append("movq \(args.argsRefs[0]), %rax")
    result.append("subq \(args.argsRefs[1]), %rax")
    if args.resultRegister != "%rax" {
      result.append("movq %rax, \(args.resultRegister)")
    }
    return result
  }

  func multiply(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    result.append("movq \(args.argsRefs[0]), %rax")
    result.append("imulq \(args.argsRefs[1]), %rax")
    if args.resultRegister != "%rax" {
      result.append("movq %rax, \(args.resultRegister)")
    }
    return result
  }

  func divide(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    result.append("movq \(args.argsRefs[0]), %rax")
    result.append("cqto")
    result.append("idivq \(args.argsRefs[1])")
    if args.resultRegister != "%rax" {
      result.append("movq %rax, \(args.resultRegister)")
    }
    return result
  }

  func remainder(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    result.append("movq \(args.argsRefs[0]), %rax")
    result.append("cqto")
    result.append("idivq \(args.argsRefs[1])")
    if args.resultRegister != "%rdx" {
      result.append("movq %rdx, \(args.resultRegister)")
    }
    return result
  }

  func equals(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    intComparison(args, "sete", &result)
    return result
  }

  func notEquals(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    intComparison(args, "setne", &result)
    return result
  }

  func lessThan(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    intComparison(args, "setl", &result)
    return result
  }

  func lessThanOrEqual(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    intComparison(args, "setle", &result)
    return result
  }

  func greaterThan(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    intComparison(args, "setg", &result)
    return result
  }

  func greaterThanOrEqual(_ args: IntrinsicsArgs) -> [String] {
    var result: [String] = []
    intComparison(args, "setge", &result)
    return result
  }

  func intComparison(_ args: IntrinsicsArgs, _ setccInsn: String, _ result: inout [String]) {
    result.append("xor %rax, %rax")
    result.append("movq \(args.argsRefs[0]), %rdx")
    result.append("cmpq \(args.argsRefs[1]), %rdx")
    result.append("\(setccInsn) %al")
    if args.resultRegister != "%rax" {
      result.append("movq %rax, \(args.resultRegister)")
    }
  }
}

let intrinsicsOps = [
  "==", "!=", "<", "<=", ">", ">=", "+", "-", "*", "/", "%", "unary_not",
  "unary_-"
]
