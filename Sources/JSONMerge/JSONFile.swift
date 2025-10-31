// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct JSONFile {
  public var data: Data
  public var url: URL?

  public init(data: Data, url: URL? = nil) {
    self.data = data
    self.url = url
  }

  public init(contentsOf url: URL) throws {
    self.data = try Data(contentsOf: url)
    self.url = url
  }

  public init(string: String, url: URL? = nil) {
    self.data = string.data(using: .utf8) ?? Data()
    self.url = url
  }

  public init(objects: JSONObjects, url: URL? = nil) throws {
    self.data = try JSONSerialization.data(
      withJSONObject: objects.data, options: [.prettyPrinted, .sortedKeys])
    self.url = url
  }

  public var objects: JSONObjects {
    do {
      return try JSONObjects(data: data)
    } catch {
      return JSONObjects([:])
    }
  }
}
