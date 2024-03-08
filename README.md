# Compilers project
This is the course project for the [Compilers](https://hy-compilers.github.io/spring-2024/) course at the University of Helsinki.

## Running & testing
The program can be run and tested by spawning a shell inside the docker-compose environment.
```bash
docker-compose run --rm swiftcompiler
```

Once inside, you can see the available commands by typing `swift run swiftcompiler -h`:
```
OVERVIEW: A Swift compiler

USAGE: swiftcompiler [<input-string>] [--input-file <input-file>] [--output-file-name <output-file-name>] [--ir] [--print]

ARGUMENTS:
  <input-string>          Input to compile

OPTIONS:
  -i, --input-file <input-file>
                          Path to input file
  -o, --output-file-name <output-file-name>
                          Output file name (default: output)
  --ir                    Output IR instead of assembly
  -p, --print             Print the output
  -h, --help              Show help information.
```

To run compile and run the example program included you can run the following. Programs are compiled to the build folder.
```bash
swift run swiftcompiler -i example.txt
./build/output
```

### Testing
Unit and end-to-end tests can be run with `swift test`. All tests are run in [gha](https://github.com/JuanitoSebastian/compilers-project/actions/workflows/swift.yml). The project features the following tests:
- [TokenizerTests](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Tests/TokenizerTests.swift): Unit tests parsing strings to [Tokens](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Models/Tokens/Token.swift).
- [ParserTests](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Tests/ParserTests.swift): Integration tests that parse a given input strings to Tokens and then [Expressions](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Models/Expressions/Expression.swift).
- [TypecheckerTests](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Tests/TypecheckerTests.swift): Integration tests that parse string to Tokens, Expressions and then [Typechecks](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Services/Typechecker.swift) the Expressions.
- [LocalsTests](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Tests/LocalsTests.swift): Unit tests that stack size and variables are calculated correctly in [Locals](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Services/Locals.swift).
- [SwiftCompilerTests](https://github.com/JuanitoSebastian/compilers-project/blob/main/Sources/Tests/SwiftCompilerTests.swift): End-to-end tests that call the program with a given input string and run the compiled program to check that the output is as expected.