# Compilers project
This is the course project for the [Compilers](https://hy-compilers.github.io/spring-2024/) course at the University of Helsinki.

## Running & testing
Docker is needed for running the projecft. First, clone the git repository. Afterwards, you can run the project with:
```zsh
docker build -t swiftcompiler .
docker run swiftcompiler
```

Tests can be run with:
```zsh
docker build -t swiftcompiler-test -f test.Dockerfile .  
docker run swiftcompiler-test
```

Building assembly using gcc:
```zsh
docker-compose -f compose-dev.yaml run --rm gcc

```