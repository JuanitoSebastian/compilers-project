let input = """
  var n: Bool = not true;
  print_bool(n);
  """
var tokenizer = Tokenizer(input: input)
try tokenizer.tokenize()
var parser = Parser(tokens: tokenizer.tokens)
var typechecker = Typechecker()
var expression = try parser.parse()
var typedExpressions = try typechecker.typecheck(expression)
var irGenerator = try IrGenerator(expressions: [typedExpressions])
try irGenerator.generate()
irGenerator.instructions.forEach { print($0) }
