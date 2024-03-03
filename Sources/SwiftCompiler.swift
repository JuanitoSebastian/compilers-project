import ArgumentParser
import ColorizeSwift

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

  @Flag(name: [.customLong("print"), .customShort("p")], help: "Print the output")
  var printOutput: Bool = false

  static var configuration = CommandConfiguration(
    commandName: "swiftcompiler",
    abstract: "A Swift compiler"
  )

  mutating func run() {
    let errorHandler = ErrorHandler()
    let fileHelper = FileHelper()

    do {
      try fileHelper.creatNeededDirectories()

      let outputToWrite = try compileGivenInput()

      if printOutput {
        print(outputToWrite)
      }

      try writeToFile(compilationOutputFileName, output: outputToWrite)

      if compileIr {
        return
      }

      try handleCompiler(
        { try createObjectFile(compilationOutputFileName, objectOutputFileName) },
        description: "Compiling program"
      )
      try handleCompiler(
        { try createObjectFile(stdLibAsmFileName, stdLibObjOutputFileName) },
        description: "Compiling stdlib"
      )
      try handleCompiler(
        { try runLinker(stdLibObjOutputFileName, objectOutputFileName, programExecutableFileName) },
        description: "Linker"
      )

      print("Compiled to: \(programExecutableFileName.bold())")
    } catch {
      errorHandler.handleError(error)
    }
  }

  private func getProvidedInput() throws -> String {
    if let inputFile = inputFile {
      print("Reading input from file: \(inputFile.bold())")
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

  var compilationOutputFileName: String {
    let fileExt = compileIr ? "ir" : "s"
    return "build/temp/\(outputFileName).\(fileExt)"
  }

  var objectOutputFileName: String {
    return "build/temp/\(outputFileName).o"
  }

  var programExecutableFileName: String {
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

  func compileGivenInput() throws -> String {
    let input = try getProvidedInput()
    var tokenizer = Tokenizer(input: input, file: inputFile)
    try tokenizer.tokenize()
    var parser = Parser(tokens: tokenizer.tokens)
    var typechecker = Typechecker()
    let expression = try parser.parse()
    let typedExpression = try typechecker.typecheck(expression)
    var irGenerator = try IrGenerator(expression: typedExpression)
    try irGenerator.generate()

    if compileIr {
      return irGenerator.ir
    }

    var assemblyGenerator = AssemblyGenerator(instructions: irGenerator.instructions)
    try assemblyGenerator.generate()
    return assemblyGenerator.asm
  }
}
