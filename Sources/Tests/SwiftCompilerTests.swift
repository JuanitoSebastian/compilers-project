import XCTest

@testable import swiftcompiler

final class SwiftCompilerTests: XCTestCase {
  func test_e2e_basic_maths() throws {
    let inputCode = """
      var x = 20 * 5;
      var y = 4;
      var result = x / y + (-10);
      print_int(result);
      var z = 348928 % 125
      """
    var test = try XCTUnwrap(SwiftCompiler.parseAsRoot([inputCode, "-o", "test"]))
    try test.run()
    XCTAssertTrue(checkFileExists("build/test"))
    let output = try runProgramAndExpectOutput("./build/test")
    XCTAssertEqual(output, ["15", "53"])
  }

  func test_e2e_while_loop() throws {
    let inputCode = """
      var x = 0;
      while x < 10 do {
        print_int(x);
        x = x + 1;
      }
      """
    var test = try XCTUnwrap(SwiftCompiler.parseAsRoot([inputCode, "-o", "test"]))
    try test.run()
    XCTAssertTrue(checkFileExists("build/test"))
    let output = try runProgramAndExpectOutput("./build/test")
    XCTAssertEqual(output, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
  }

  func test_e2e_if_else() throws {
    let inputCode = """
      var x = 10;
      if x <= 10 then {
        print_int(1);
      } else {
        print_int(0);
      }
      print_int(28931)
      """
    var test = try XCTUnwrap(SwiftCompiler.parseAsRoot([inputCode, "-o", "test"]))
    try test.run()
    XCTAssertTrue(checkFileExists("build/test"))
    let output = try runProgramAndExpectOutput("./build/test")
    XCTAssertEqual(output, ["1", "28931"])
  }

  func test_e2e_more_maths() throws {
    let inputCode = """
      var a = 10;
      var b = 5;
      var c = 3;
      var d = 7;

      var result1 = a + b * c - d;
      print_int(result1);
      var result2 = (a - b) * (c + d);
      print_int(result2);
      var result3 = a % c;
      print_int(result3);
      """
    var test = try XCTUnwrap(SwiftCompiler.parseAsRoot([inputCode, "-o", "test"]))
    try test.run()
    XCTAssertTrue(checkFileExists("build/test"))
    let output = try runProgramAndExpectOutput("./build/test")
    XCTAssertEqual(output, ["18", "50", "1"])
  }
}

extension SwiftCompilerTests {
  private func checkFileExists(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  private func runProgramAndExpectOutput(_ program: String) throws -> [String] {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", program]
    task.executableURL = URL(fileURLWithPath: "/bin/bash")
    task.standardInput = nil

    try task.run()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)

    guard let output = output else { return [] }

    return output.split(separator: "\n").map(String.init)
  }
}
