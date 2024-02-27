struct LoadConst<Element>: Instruction, Equatable
where Element: LiteralExpressionValue, Element: Equatable {
  let value: Element
  let destination: IrVar
  let location: Location

  static func == (lhs: LoadConst<Element>, rhs: LoadConst<Element>) -> Bool {
    return lhs.value == rhs.value && lhs.destination == rhs.destination
      && lhs.location == rhs.location
  }

  var irVariables: [IrVar] {
    return [destination]
  }

  var description: String {
    let typeDescription = String(describing: Element.self)
    return "Load\(typeDescription)Const (\(value), \(destination))"
  }
}
