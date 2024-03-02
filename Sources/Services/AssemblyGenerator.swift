import Foundation

struct AssemblyGenerator {
  let intrinsicsHandler = IntrinsicsHandler()
  var asmInstructions: [String] = []
  let instructions: [(any Instruction)]
  let locals: Locals

  var asm: String {
    return asmInstructions.joined(separator: "\n")
  }

  init(instructions: [(any Instruction)]) {
    self.instructions = instructions
    self.locals = Locals(irVariables: getIrVarsFromInstructions(instructions))
  }

  mutating func generate() throws {
    startFile()
    try instructions.forEach { try handleInstruction($0) }
    endFile()
  }
}

extension AssemblyGenerator {
  private mutating func handleInstruction(_ instruction: any Instruction) throws {
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
    case let call as Call:
      try handleCall(call)
    default:
      fatalError("Not implemented: \(type(of: instruction.self))")
    }
  }

  private mutating func emit(_ asmToAppend: String) {
    asmInstructions.append(asmToAppend)
  }

  private mutating func emit(_ asmToAppend: [String]) {
    asmInstructions.append(contentsOf: asmToAppend)
  }

  private mutating func handleJumpInstruction(_ jump: Jump) {
    emit("jmp .L\(jump.label.label)")
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

  private mutating func handleCall(_ call: Call) throws {
    if intrinsicsOps.contains(call.function.description) {
      let intrinsicsArgs = IntrinsicsArgs(
        argsRefs: try call.arguments.map { try locals.gestStackLocation(for: $0) },
        resultRegister: try locals.gestStackLocation(for: call.destination)
      )
      let intrinsicAsm = try intrinsicsHandler.handleIntrinsic(
        call.function.description, intrinsicsArgs)
      emit(intrinsicAsm)
      return
    }

    if call.function.description == "print_int" {
      let argLocation: String = try locals.gestStackLocation(for: call.arguments[0])
      emit("movq \(argLocation), %rdi")
      emit("call print_int")
      return
    }

    if call.function.description == "print_bool" {
      let argLocation: String = try locals.gestStackLocation(for: call.arguments[0])
      emit("movq \(argLocation), %rdi")
      emit("call print_bool")
      return
    }

    if call.function.description == "read_int" {
      let resultLocation: String = try locals.gestStackLocation(for: call.destination)
      emit("call read_int")
      emit("movq %rax, \(resultLocation)")
      return
    }
  }

  private mutating func startFile() {
    emit(".global main")
    emit(".type main, @function")
    emit(".extern print_int")
    emit(".section .text")
    emit("")
    emit("main:")
    emit("pushq %rbp")
    emit("movq %rsp, %rbp")
    emit("subq $\(locals.stackSize), %rsp")
  }

  private mutating func endFile() {
    emit("")
    emit(".Lend:")
    emit("movq $0, %rax")
    emit("movq %rbp, %rsp")
    emit("popq %rbp")
    emit("ret")
    emit("")
  }
}
