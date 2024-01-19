struct Tokenizer {
  let INTEGER_REGEX = #/[0-9]+/#
  let IDENTIFIER_REGEX = #/[a-zA-Z][a-zA-Z0-9]*#/

  func tokenize(_ input: String) -> [Token] {
    let tokens: [Token] = []
    // Iterate substrings of input 
    for position in input.indices {
      let partToMatch = input[position..<input.endIndex]
      let token = match(partToMatch)
    }

    return tokens
  }

  func match(_ input: Substring) -> Token? {
    
    return nil
  }
}
