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

  mutating func run() throws {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let overlayURL = cwd.appending(path: "Overlays")
    let outputURL =
      output.map { URL(fileURLWithPath: $0, relativeTo: cwd) } ?? cwd.appending(path: "Output")

    try? FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

    let overlays = try FileManager.default.contentsOfDirectory(
      at: overlayURL, includingPropertiesForKeys: [])
    for overlayURL in overlays {
      try self.overlay(url: overlayURL, to: outputURL)
    }
  }

  func overlay(url: URL, to outputURL: URL) throws {
    try? FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

    try "TBC".write(to: outputURL, atomically: true, encoding: .utf8)
    print("overlaying \(url.path)")
  }
}
