let input = """
  var a: Int = 1
  """
var tokenizer = Tokenizer(input: input)
try tokenizer.tokenize()
var parser = Parser(tokens: tokenizer.tokens)
var typechecker = Typechecker()
var expression = try parser.parse()
  .compactMap { $0 }
var unTypedExpression = expression[0]
var typedExpression = try typechecker.typecheck(unTypedExpression)
var irGenerator = IrGenerator(expressions: [typedExpression])
try irGenerator.generate()
print(irGenerator.instructions)
