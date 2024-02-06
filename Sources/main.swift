let input = """
  {
    a = 1 + 2 - 3;
    if 2 > 4 then {
      foo(a);
    } else {
      foo(1);
    }
  }
  """
var tokenizer = Tokenizer(input: input)
tokenizer.tokenize()
var parser = Parser(tokens: tokenizer.tokens)
var expression = try parser.parse()

print(expression)
