protocol Instruction: CustomStringConvertible, Equatable {
  var location: Location { get }
  var description: String { get }
  static func == (lhs: Self, rhs: Self) -> Bool
}
