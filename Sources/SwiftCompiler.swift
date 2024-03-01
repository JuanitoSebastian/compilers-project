import ArgumentParser

@main
struct SwiftCompiler: ParsableCommand {
  @Argument(help: "String to parse")
  var inputString: String?

  @Option(name: .shortAndLong, help: "Path to input file")
  var inputFile: String?

  @Option(name: .shortAndLong, help: "Path to output file")
  var outputFile: String?

  static var configuration = CommandConfiguration(
    commandName: "swiftcompiler",
    abstract: "A Swift compiler"
  )

  mutating func run() {
    do {
      let input = try getProvidedInput()
      var tokenizer = Tokenizer(input: input)
      try tokenizer.tokenize()
      var parser = Parser(tokens: tokenizer.tokens)
      var typechecker = Typechecker()
      let expression = try parser.parse()
      let typedExpression = try typechecker.typecheck(expression)
      var irGenerator = try IrGenerator(expression: typedExpression)
      try irGenerator.generate()
      var assemblyGenerator = AssemblyGenerator(instructions: irGenerator.instructions)
      try assemblyGenerator.generate()
      let outputString = assemblyGenerator.asm.joined(separator: "\n")

      guard let outputFile = outputFile else {
        print(outputString)
        return
      }

      try writeToFile(outputFile, output: outputString)

    } catch {
      print(error)
    }
  }

  private func getProvidedInput() throws -> String {
    if let inputFile = inputFile {
      return try String(contentsOfFile: inputFile)
    } else if let inputString = inputString {
      return inputString
    } else {
      throw SwiftCompilerError.noInputProvided
    }
  }

  private func writeToFile(_ fileName: String, output: String) throws {
    try output.write(toFile: fileName, atomically: true, encoding: .utf8)
  }
}
