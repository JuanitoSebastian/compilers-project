let input = """
  if 2 > 3 then true else false
  """
var tokenizer = Tokenizer(input: input)
try tokenizer.tokenize()
var parser = Parser(tokens: tokenizer.tokens)
var typechecker = Typechecker()
var expression = try parser.parse().compactMap { $0 }
var typedExpressions = try expression.map { try typechecker.typecheck($0) }
var irGenerator = IrGenerator(expressions: typedExpressions)
try irGenerator.generate()
irGenerator.instructions.forEach { print($0) }
