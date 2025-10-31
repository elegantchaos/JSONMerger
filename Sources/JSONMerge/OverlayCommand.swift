// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ArgumentParser
import Foundation

struct OverlayCommand: ParsableCommand {
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "overlay",
      abstract: "Apply multiple overlays."
    )
  }

  @Flag() var verbose: Bool = false
  @Option(help: "The output file for the merged JSON.") var output: String?
  @Option(help: "The overlays directory to apply.") var overlays: String?

  mutating func run() throws {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let overlaysURL =
      overlays.map { URL(fileURLWithPath: $0, relativeTo: cwd) }
      ?? cwd.appending(path: "Overlays")

    let outputURL =
      output.map { URL(fileURLWithPath: $0, relativeTo: cwd) } ?? cwd.appending(path: "Output")

    try? FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

    let overlays = try FileManager.default.contentsOfDirectory(
      at: overlaysURL, includingPropertiesForKeys: [])
    for overlayURL in overlays {
      try self.overlay(url: overlayURL, to: outputURL)
    }
  }

  func overlay(url: URL, to outputURL: URL) throws {

    let decoder = JSONDecoder()
    let configURL = url.appending(path: "config.json")
    let config = try decoder.decode(OverlayConfig.self, from: Data(contentsOf: configURL))

    let o = outputURL.appending(path: config.output)
    try? FileManager.default.createDirectory(
      at: o.deletingLastPathComponent(), withIntermediateDirectories: true)
    try "TBC".write(to: o, atomically: true, encoding: .utf8)
    print("overlaying \(url.path)")
  }
}

struct OverlayConfig: Codable {
  let inputs: [String]
  let output: String
}
