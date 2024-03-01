let SLOT_SIZE = 8

struct Locals {
  private var varStackLocations: [IrVar: Int] = [:]
  private(set) var stackSize: Int = 0

  init(irVariables: [IrVar]) {
    stackSize = irVariables.reduce(0) { slot, irVar in
      let nextSlot = slot + SLOT_SIZE
      varStackLocations[irVar] = nextSlot
      return nextSlot
    }
  }

  func getStackLocation(for irVar: IrVar) throws -> Int {
    guard let irVarLoction = varStackLocations[irVar] else {
      throw LocalsError.irVarNotFound(irVar)
    }
    return irVarLoction
  }

  func gestStackLocation(for irVar: IrVar) throws -> String {
    let stackLoactionNum = try getStackLocation(for: irVar)
    return "-\(stackLoactionNum)(%rbp)"
  }
}
