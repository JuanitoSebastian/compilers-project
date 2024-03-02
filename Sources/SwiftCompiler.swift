import ArgumentParser

@main
struct SwiftCompiler: ParsableCommand {
  @Argument(help: "String to parse")
  var inputString: String?

  @Option(name: .shortAndLong, help: "Path to input file")
  var inputFile: String?

  @Option(name: .shortAndLong, help: "Output file name")
  var outputFileName: String = "output"

  @Flag(name: [.customLong("ir")], help: "Output IR instead of assembly")
  var compileIr: Bool = false

  static var configuration = CommandConfiguration(
    commandName: "swiftcompiler",
    abstract: "A Swift compiler"
  )

  mutating func run() {
    let fileHelper = FileHelper()
    do {
      try fileHelper.creatNeededDirectories()

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

      try writeToFile(asmOutputFileName, output: assemblyGenerator.asm)
      try handleCompiler({ try createObjectFile(asmOutputFileName, objectOutputFileName) }, description: "Compiling program")
      try handleCompiler({ try createObjectFile(stdLibAsmFileName, stdLibObjOutputFileName) }, description: "Compiling stdlib")
      try handleCompiler({ try runLinker(stdLibObjOutputFileName, objectOutputFileName, programOutputFileName) }, description: "Linker")
      

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

extension SwiftCompiler {

  var asmOutputFileName: String {
    return "build/temp/\(outputFileName).s"
  }

  var objectOutputFileName: String {
    return "build/temp/\(outputFileName).o"
  }

  var programOutputFileName: String {
    return "build/\(outputFileName)"
  }

  var stdLibAsmFileName: String {
    return "asm_utils/stdlib.s"
  }

  var stdLibObjOutputFileName: String {
    return "build/temp/stdlib.o"
  }

  func handleCompiler(_ compilerFunc: () throws -> String?, description: String) throws {
    let output = try compilerFunc()
    if let output = output {
      print("\(description): \(output)")
    }
  }
}
