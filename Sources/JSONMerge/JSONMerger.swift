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
      merged = merge(base: merged, with: object, path: [])
    }

    return merged
  }

  public func merge(_ files: [JSONFile]) throws -> JSONFile {
    let objects = files.map(\.objects)
    let merged = try merge(objects: objects)

    return JSONFile(objects: merged)
  }

  public func merge(
    base: JSONObjects, with other: JSONObjects, path: [String]
  ) -> JSONObjects {
    let merged = merge(dictionary: base.data, with: other.data, path: path)
    return JSONObjects(merged)
  }

  func merge(_ original: Any, with other: Any, path: [String]) -> Any {
    if let d1 = original as? [String: Any], let d2 = other as? [String: Any] {
      return merge(dictionary: d1, with: d2, path: path)
    } else if let l1 = original as? [Any], let l2 = other as? [Any] {
      return merge(list: l1, with: l2, path: path)
    } else {
      return other
    }
  }

  func merge(dictionary original: [String: Any], with other: [String: Any], path: [String])
    -> [String: Any]
  {
    var merged = original
    for (key, value) in other {
      let newPath = path + [key]
      if let existing = merged[key] {
        merged[key] = merge(existing, with: value, path: newPath)
      } else {
        merged[key] = value
      }
    }
    return merged
  }

  func merge(list original: [Any], with other: [Any], path: [String]) -> [Any] {
    var merged = original
    merged.append(contentsOf: other)
    return merged
  }
}
