import Foundation

func createObjectFile(_ asmFile: String, _ objectFile: String) throws -> String? {
  let commandToRun = "as -o \(objectFile) \(asmFile)"
  let task = Process()
  let pipe = Pipe()

  task.standardOutput = pipe
  task.standardError = pipe
  task.arguments = ["-c", commandToRun]
  task.executableURL = URL(fileURLWithPath: "/bin/bash")
  task.standardInput = nil

  try task.run()

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)!
  return output == "" ? nil : output
}

func runLinker(_ stdlibObjFile: String, _ programObjFile: String, _ outputFile: String) throws -> String? {
  let commandToRun = "ld -o \(outputFile) \(stdlibObjFile) \(programObjFile)"
  let task = Process()
  let pipe = Pipe()

  task.standardOutput = pipe
  task.standardError = pipe
  task.arguments = ["-c", commandToRun]
  task.executableURL = URL(fileURLWithPath: "/bin/bash")
  task.standardInput = nil

  try task.run()

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)!
  return output == "" ? nil : output
}
