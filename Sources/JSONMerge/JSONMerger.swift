// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import DictionaryMerger
import Foundation

nonisolated(unsafe) var stderr = StandardError()

public struct JSONMerger {
  public let options: DictionaryMerger.Options

  public init(options: DictionaryMerger.Options = .default) {
    self.options = options
  }

  public func merge(objects: [JSONObjects]) throws -> JSONObjects {
    let merger = DictionaryMerger(options: options)
    let merged = try merger.merge(objects.map(\.data))
    return JSONObjects(merged)
  }

  public func merge(_ files: [JSONFile]) throws -> JSONFile {
    let objects = files.map(\.objects)
    let merged = try merge(objects: objects)

    return JSONFile(objects: merged)
  }
}

struct StandardError: TextOutputStream, Sendable {
  private static let handle = FileHandle.standardError

  public func write(_ string: String) {
    Self.handle.write(Data(string.utf8))
  }
}
