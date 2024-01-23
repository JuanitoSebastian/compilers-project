protocol Token: CustomStringConvertible {
  var type: TokenType { get }
  var stringRepresentation: String { get }
  var location: Location { get }
  var description: String { get }
}

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

struct Identifier: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .identifier
  }

  var description: String {
    return "Identifier(value: \(value), location: \(location))"
  }
}

struct LineComment: Token, Equatable {
  let value: String
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .lineComment
  }

  var description: String {
    return "LineComment(value: \(value), location: \(location))"
  }
}

struct Operator: Token, Equatable {
  let stringRepresentation: String
  let location: Location

  var type: TokenType {
    return .op
  }

  var description: String {
    return "Operator(stringRepresentation: \(stringRepresentation), location: \(location))"
  }
}