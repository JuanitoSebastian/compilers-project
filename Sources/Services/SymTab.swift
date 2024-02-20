struct SymTab<T> {
  private var tables: [[String: T]]

  init(_ initialValues: [String: T] = [:]) {
    tables = [initialValues]
  }

  mutating func push(_ table: [String: T] = [:]) {
    tables.append(table)
  }

  mutating func pop() throws -> [String: T] {
    guard tables.count > 1 else {
      throw SymTabError.popLastTable
    }
    let lastTable = tables.removeLast()
    return lastTable
  }

  mutating func insert(_ value: T, for key: String) throws {
    guard var table = tables.popLast() else {
      throw SymTabError.noTableToInsert
    }
    table[key] = value
    tables.append(table)
  }

  mutating func insert<S: CustomStringConvertible>(_ value: T, for key: S) throws {
    try insert(value, for: key.description)
  }

  func lookup(_ key: String) -> T? {
    for table in tables.reversed() {
      if let value = table[key] {
        return value
      }
    }
    return nil
  }

  func lookup<S: CustomStringConvertible>(_ key: S) -> T? {
    return lookup(key.description)
  }
}
