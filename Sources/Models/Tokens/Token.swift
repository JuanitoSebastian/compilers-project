protocol Token: CustomStringConvertible {
  var type: TokenType { get }
  var stringRepresentation: String { get }
  var location: Location { get }
  var description: String { get }
}
