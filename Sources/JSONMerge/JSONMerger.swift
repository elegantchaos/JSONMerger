// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct JSONMerger {

  public struct Options: Sendable {
    public static let `default` = Options()
  }

  public let options: Options

  public init(options: Options = .default) {
    self.options = options
  }

  public func merge(objects: [JSONObjects]) throws -> JSONObjects {
    var merged = JSONObjects([:])

    for object in objects {
      merged.merge(with: object, options: options)
    }

    return merged
  }

  public func merge(_ files: [JSONFile]) throws -> JSONFile {
    let objects = files.map(\.objects)
    let merged = try merge(objects: objects)

    return try! JSONFile(objects: merged)
  }
}
