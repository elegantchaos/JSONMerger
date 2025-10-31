// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct JSONMerger {

  public struct Options: Sendable {
    public let uniqueLists: Bool

    public init(uniqueLists: Bool = false) {
      self.uniqueLists = uniqueLists
    }

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
    if options.uniqueLists {
      if let s1 = original as? [String], let s2 = other as? [String] {
        return mergeUnique(list: s1, with: s2, path: path)
      } else if let n1 = original as? [Int], let n2 = other as? [Int] {
        return mergeUnique(list: n1, with: n2, path: path)
      } else if let d1 = original as? [Double], let d2 = other as? [Double] {
        return mergeUnique(list: d1, with: d2, path: path)
      }
    }

    return original + other
  }

  func mergeUnique<T: Hashable>(list original: [T], with other: [T], path: [String]) -> [T] {
    var seen = Set(original)
    var combined = original
    for item in other {
      if !seen.contains(item) {
        seen.insert(item)
        combined.append(item)
      }
    }
    return combined
  }
}
