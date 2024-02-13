struct SymTab<T> {
  private var table: [String: T]

  init(_ initialValues: [String: T] = [:]) {
    table = initialValues
  }

  mutating func insert(_ value: T, for key: String) {
    table[key] = value
  }

  func lookup(_ key: String) -> T? {
    return table[key]
  }
}
