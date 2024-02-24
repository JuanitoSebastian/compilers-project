let builtInFuncTypes: [String: (params: [FunctionParameterType], returns: Type)] = [
  "+": ([.definiteType(.int), .definiteType(.int)], .int),
  "-": ([.definiteType(.int), .definiteType(.int)], .int),
  "*": ([.definiteType(.int), .definiteType(.int)], .int),
  "/": ([.definiteType(.int), .definiteType(.int)], .int),
  "%": ([.definiteType(.int), .definiteType(.int)], .int),
  "<": ([.definiteType(.int), .definiteType(.int)], .bool),
  "<=": ([.definiteType(.int), .definiteType(.int)], .bool),
  ">": ([.definiteType(.int), .definiteType(.int)], .bool),
  ">=": ([.definiteType(.int), .definiteType(.int)], .bool),
  "==": ([.equalType, .equalType], .bool),
  "!=": ([.equalType, .equalType], .bool),
  "and": ([.definiteType(.bool), .definiteType(.bool)], .bool),
  "or": ([.definiteType(.bool), .definiteType(.bool)], .bool),
  "print_int": ([.definiteType(.int)], .unit),
  "print_bool": ([.definiteType(.bool)], .unit),
  "read_int": ([], .int)
]
