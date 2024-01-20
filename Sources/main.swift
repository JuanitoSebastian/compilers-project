let input = "if  3\nwhile"
var tokenizer = Tokenizer(input: input)
tokenizer.tokenize()

for token in tokenizer.tokens {
  print(token)
}
