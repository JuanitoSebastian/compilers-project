let builtInFuncTypes: [String: (params: [Type], returns: Type)] = [
  "+": ([.int, .int], .int),
  "-": ([.int, .int], .int),
  "*": ([.int, .int], .int),
  "/": ([.int, .int], .int),
  "%": ([.int, .int], .int),
  "<": ([.int, .int], .bool),
  "<=": ([.int, .int], .bool),
  ">": ([.int, .int], .bool),
  ">=": ([.int, .int], .bool),
  "and": ([.bool, .bool], .bool),
  "or": ([.bool, .bool], .bool),
  "print_int": ([.int], .unit),
  "print_bool": ([.bool], .unit),
  "read_int": ([], .int)
]
