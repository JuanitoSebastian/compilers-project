struct IntegerLiteral: Token, Equatable {
  let value: Int
  let stringRepresentation: String
  let location: Location

  init(value: Int, stringRepresentation: String, location: Location) {
    self.value = value
    self.stringRepresentation = stringRepresentation
    self.location = location
  }

  init(stringRepresentation: String, location: Location) {
    let parsedToInt = Int(stringRepresentation)
    if let parsedToInt = parsedToInt {
      self.init(value: parsedToInt, stringRepresentation: stringRepresentation, location: location)
    } else {
      fatalError("Could not parse \(stringRepresentation) to Int")
    }
  }

  var type: TokenType {
    return .integerLiteral
  }

  var description: String {
    return "IntegerLiteral(value: \(value), location: \(location))"
  }
}
