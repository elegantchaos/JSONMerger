// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct JSONMerger {

  public struct Options {
    public static let `default` = Options()
  }

  public let options: Options

  public init(options: Options = .default) {
    self.options = options
  }

  func merge(objects: [JSONObjects]) throws -> JSONObjects {
    var merged = JSONObjects([:])

    for object in objects {
      merged.merge(with: object, options: options)
    }

    return merged
  }

  func merge(base: [String: Any], override: [String: Any]) throws -> [String: Any] {
    var merged = base

    for (key, value) in override {
      merged[key] = value
    }

    return merged
  }

  func merge(_ files: [JSONFile]) throws -> JSONFile {
    let objects = files.map(\.objects)
    let merged = try merge(objects: objects)

    return try! JSONFile(objects: merged)
  }
}
