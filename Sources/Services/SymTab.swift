struct SymTab<T> {
  private var table: [String: T]

  init(_ initialValues: [String: T] = [:]) {
    table = initialValues
  }

  mutating func insert(_ value: T, for key: String) {
    table[key] = value
  }

  mutating func insert<S: CustomStringConvertible>(_ value: T, for key: S) {
    insert(value, for: key.description)
  }

  func lookup(_ key: String) -> T? {
    return table[key]
  }

  func lookup<S: CustomStringConvertible>(_ key: S) -> T? {
    return lookup(key.description)
  }
}
