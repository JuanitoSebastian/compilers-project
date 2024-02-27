let input = """
  var a = false or true
  """
var tokenizer = Tokenizer(input: input)
try tokenizer.tokenize()
var parser = Parser(tokens: tokenizer.tokens)
var typechecker = Typechecker()
var expression = try parser.parse()
var typedExpression = try typechecker.typecheck(expression)
var irGenerator = try IrGenerator(expression: typedExpression)
try irGenerator.generate()
irGenerator.instructions.forEach { print($0) }
let irVariables = getIrVarsFromInstructions(irGenerator.instructions)
irVariables.forEach { print($0) }
