let input = """
    f(a);
    x = y;
    f(x)
  """
var tokenizer = Tokenizer(input: input)
tokenizer.tokenize()
var parser = Parser(tokens: tokenizer.tokens)
var expression = try parser.parse()

print(expression)
