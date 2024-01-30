let input = "10 + a -"
var tokenizer = Tokenizer(input: input)
tokenizer.tokenize()
var parser = Parser(tokens: tokenizer.tokens)
var expression = try parser.parse()!

print(expression)
