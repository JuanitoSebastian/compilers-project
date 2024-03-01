# Compilers project
This is the course project for the [Compilers](https://hy-compilers.github.io/spring-2024/) course at the University of Helsinki.

## Running & testing
The program can be run and tested by spawning a shell inside the docker-compose environment.
```zsh
docker-compose -f compose-dev.yaml run --rm gcc
```

Once inside, you can see the available commands by typing `swift run swiftcompiler -h` or run unit tests with `swift test`.
