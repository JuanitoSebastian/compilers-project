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
    XCTAssertEqual(locals.stackSize, 24)
  }

  func test_locals_ir_var_locations() throws {
    let locals = Locals(irVariables: irVariables)
    let locationNums = [8, 16, 24]
    let locationStrings = ["-8(%rbp)", "-16(%rbp)", "-24(%rbp)"]
    try irVariables.enumerated().forEach { index, irVar in
      XCTAssertEqual(try locals.getStackLocation(for: irVar), locationNums[index])
      XCTAssertEqual(try locals.gestStackLocation(for: irVar), locationStrings[index])
    }
  }
}
