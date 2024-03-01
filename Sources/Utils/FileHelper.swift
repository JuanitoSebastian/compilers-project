import Foundation

struct FileHelper {

  func creatNeededDirectories() throws {
    try createDirIfNotExists("build")
    try createDirIfNotExists("build/temp")
  }

  private func createDirIfNotExists(_ dir: String) throws {
    if !FileManager.default.fileExists(atPath: dir) {
      try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
    }
  }
}