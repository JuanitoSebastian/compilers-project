# Compilers project
This is the course project for the [Compilers](https://hy-compilers.github.io/spring-2024/) course at the University of Helsinki.

## Running & testing
The program can be run and tested by spawning a shell inside the docker-compose environment.
```zsh
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

Unit and end-to-end tests can be run with `swift test`. All tests are run in [gha](https://github.com/JuanitoSebastian/compilers-project/actions/workflows/swift.yml).