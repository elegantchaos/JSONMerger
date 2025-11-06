// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct JSONFile {
  public var objects: JSONObjects
  public var url: URL?

  public init(data: Data, url: URL? = nil) throws {
    self.objects = try JSONObjects(data: data)
    self.url = url
  }

  public init(contentsOf url: URL) throws {
    try self.init(data: Data(contentsOf: url), url: url)
  }

  public init(_ string: String, url: URL? = nil) throws {
    try self.init(data: string.data(using: .utf8) ?? Data(), url: url)
  }

  public init(objects: JSONObjects, url: URL? = nil) {
    self.objects = objects
    self.url = url
  }

  public var formatted: String {
    return objects.formatted
  }
}
