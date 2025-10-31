import Foundation

public struct JSONObjects {
  public init(_ data: [String: Any]) {
    self.data = data
  }

  public init(data: Data) throws {
    let object = try JSONSerialization.jsonObject(with: data, options: [])
    guard let dictionary = object as? [String: Any] else {
      throw NSError(
        domain: "JSONObjects", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Data is not a JSON dictionary"])
    }
    self.data = dictionary
  }

  public var data: [String: Any]

  public mutating func merge(with other: JSONObjects, options: JSONMerger.Options, path: [String]) {
    for (key, value) in other.data {
      if let existing = data[key] {
        data[key] = merge(existing, with: value, options: options, path: path + [key])
      } else {
        data[key] = value
      }
    }
  }

  func merge(_ original: Any, with other: Any, options: JSONMerger.Options, path: [String]) -> Any {
    return other
  }

  public var formatted: String {
    do {
      let jsonData = try JSONSerialization.data(
        withJSONObject: data,
        options: [.prettyPrinted, .sortedKeys])
      return String(data: jsonData, encoding: .utf8) ?? "{}"
    } catch {
      return "{}"
    }
  }
}
