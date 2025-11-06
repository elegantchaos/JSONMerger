// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/11/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
  func write(to url: URL) throws {
    try? FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try self.write(to: url, atomically: true, encoding: .utf8)
  }
}

extension URL {
  func copy(to destination: URL) throws {
    let fm = FileManager.default
    try? fm.createDirectory(
      at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? fm.removeItem(at: destination)
    try fm.copyItem(at: self, to: destination)
  }
}
