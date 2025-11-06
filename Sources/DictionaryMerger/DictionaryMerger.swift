// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

nonisolated(unsafe) var stderr = StandardError()

public struct DictionaryMerger {
  public typealias Item = [String: Any]

  public struct Options: Sendable {
    public let uniqueLists: Bool
    public let verbose: Bool

    public init(uniqueLists: Bool = false, verbose: Bool = false) {
      self.uniqueLists = uniqueLists
      self.verbose = verbose
    }

    public static let `default` = Options()
  }

  public let options: Options

  public init(options: Options = .default) {
    self.options = options
  }

  public func merge(_ dictionaries: [Item]) throws -> Item {
    var merged = Item()

    for dictionary in dictionaries {
      merged = merge(dictionary: merged, with: dictionary, path: [])
    }

    return merged
  }

  func merge(_ original: Any, with other: Any, path: [String]) -> Any {
    if let d1 = original as? Item, let d2 = other as? Item {
      return merge(dictionary: d1, with: d2, path: path)
    } else if let l1 = original as? [Any], let l2 = other as? [Any] {
      return merge(list: l1, with: l2, path: path)
    } else {
      return other
    }
  }

  func merge(dictionary original: Item, with other: Item, path: [String])
    -> Item
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

    log("merged dictionaries", path: path)
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

    log("merged lists", path: path)
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

    log("uniqued \(T.self) lists", path: path)
    return combined
  }

  func log(_ message: String, path: [String]) {
    if options.verbose {
      if path.isEmpty {
        print(message, to: &stderr)
      } else {
        let pathString = path.joined(separator: ".")
        print("\(message) [\(pathString)]", to: &stderr)
      }
    }
  }
}

struct StandardError: TextOutputStream, Sendable {
  private static let handle = FileHandle.standardError

  public func write(_ string: String) {
    Self.handle.write(Data(string.utf8))
  }
}

extension DictionaryMerger.Item {
  public var asJSON: String {
    guard JSONSerialization.isValidJSONObject(self) else {
      return "<invalid JSON>"
    }

    let data = try! JSONSerialization.data(
      withJSONObject: self, options: [.prettyPrinted, .sortedKeys])
    return String(data: data, encoding: .utf8)!
  }
}
