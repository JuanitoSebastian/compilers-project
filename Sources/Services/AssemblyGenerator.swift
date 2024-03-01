import Foundation

struct AssemblyGenerator {
  var asm: [String] = []
  let instructions: [(any Instruction)]
  let locals: Locals

  init(instructions: [(any Instruction)]) {
    self.instructions = instructions
    self.locals = Locals(irVariables: getIrVarsFromInstructions(instructions))
  }

  mutating func generate() throws {
    for instruction in instructions {
      switch instruction {
      case let label as Label:
        handleLabel(label)
      case let jump as Jump:
        handleJumpInstruction(jump)
      case let loadInt as LoadConst<Int>:
        try handleLoadInt(loadInt)
      case let loadBool as LoadConst<Bool>:
        try handleLoadBool(loadBool)
      case let copy as Copy:
        try handleCopy(copy)
      case let condJump as CondJump:
        try handleConditionalJump(condJump)
      default:
        fatalError("Not implemented: \(type(of: instruction.self))")
      }
    }

    endFile()
  }
}

extension AssemblyGenerator {
  private mutating func emit(_ asmToAppend: String) {
    asm.append(asmToAppend)
  }

  private mutating func handleJumpInstruction(_ jump: Jump) {
    emit("jmp .L\(jump.label)")
  }

  private mutating func handleLabel(_ label: Label) {
    emit("")
    emit(".L\(label.label):")
  }

  private mutating func handleLoadInt(_ loadInt: LoadConst<Int>) throws {
    let value = loadInt.value
    let loadDest: String = try locals.gestStackLocation(for: loadInt.destination)
    if pow(-2, 31)..<pow(2, 31) ~= (Decimal(value)) {
      emit("movq $\(value), \(loadDest)")
    } else {
      emit("movabsq $\(value), %rax")
      emit("movq %rax, \(loadDest))")
    }
  }

  private mutating func handleLoadBool(_ loadBool: LoadConst<Bool>) throws {
    let value = loadBool.value ? 1 : 0
    let loadDest: String = try locals.gestStackLocation(for: loadBool.destination)
    emit("movq $\(value), \(loadDest)")
  }

  private mutating func handleCopy(_ copy: Copy) throws {
    let sourceLocation: String = try locals.gestStackLocation(for: copy.source)
    let destLocation: String = try locals.gestStackLocation(for: copy.destination)
    emit("movq \(sourceLocation), %rax")
    emit("movq %rax, \(destLocation)")
  }

  private mutating func handleConditionalJump(_ condJump: CondJump) throws {
    let conditionLocation: String = try locals.gestStackLocation(for: condJump.condition)
    emit("cmpq $0, \(conditionLocation)")
    emit("jne .L\(condJump.thenLabel.label)")
    emit("jmp .L\(condJump.elseLabel.label)")
  }

  private mutating func endFile() {
    emit("")
    emit(".Lend")
    emit("movq $0, %rax")
    emit("movq %rbp, %rsp")
    emit("popq %rbp")
    emit("ret")
  }
}
