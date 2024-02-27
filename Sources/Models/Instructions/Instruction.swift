protocol Instruction: CustomStringConvertible, Equatable {
  var location: Location { get }
  var description: String { get }
  var irVariables: [IrVar] { get }
  static func == (lhs: Self, rhs: Self) -> Bool
}
