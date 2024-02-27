import XCTest

@testable import swiftcompiler

final class LocalsTests: XCTestCase {
  let irVariables = [
    IrVar(name: "x0"),
    IrVar(name: "x1"),
    IrVar(name: "print_int")
  ]

  func test_locals_inits() {
    let locals = Locals(irVariables: irVariables)
    XCTAssertEqual(locals.stackUsed, 24)
  }

  func test_locals_ir_var_locations() throws {
    let locals = Locals(irVariables: irVariables)
    let locationNums = [0, 8, 16]
    let locationStrings = ["-0(%rbp)", "-8(%rbp)", "-16(%rbp)"]
    try irVariables.enumerated().forEach { index, irVar in
      XCTAssertEqual(try locals.getStackLocation(for: irVar), locationNums[index])
      XCTAssertEqual(try locals.gestStackLocation(for: irVar), locationStrings[index])
    }
  }
}
