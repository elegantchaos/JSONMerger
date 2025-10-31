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

    for stage in config.stages {
      if let copyConfig = stage.copy {
        try copy(copyConfig, at: url, to: outputURL)
      }

      if let moveConfig = stage.move {
        try move(moveConfig, at: url, to: outputURL)
      }

      if let mergeConfig = stage.merge {
        try merge(mergeConfig, at: url, to: outputURL)
      }
    }
  }

  func move(_ config: GroupConfig, at inputRoot: URL, to outputRoot: URL) throws {
    for input in config.from {
      let inputURL = inputRoot.appending(path: input)
      let outputURL = outputRoot.appending(path: config.to).appending(
        path: inputURL.lastPathComponent)
      try inputURL.copy(to: outputURL)
    }
  }

  func copy(_ config: CopyConfig, at root: URL, to outputURL: URL) throws {
    let inputURL = root.appending(path: config.from)
    let destination = outputURL.appending(path: config.to)
    try inputURL.copy(to: destination)
  }

  func merge(_ config: GroupConfig, at root: URL, to outputURL: URL) throws {
    let inputs = config.from.compactMap {
      try? JSONFile(contentsOf: root.appending(path: "\($0).json"))
    }
    let merger = JSONMerger(options: .init(uniqueLists: true, verbose: verbose))
    let merged = try merger.merge(inputs)
    let mergedURL = outputURL.appending(path: config.to)
    try merged.formatted.write(to: mergedURL)
  }
}

extension String {
  func write(to url: URL) throws {
    try? FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try self.write(to: url, atomically: true, encoding: .utf8)
  }
}

extension URL {
  func copy(to destination: URL) throws {
    let fm = FileManager.default
    try? fm.createDirectory(
      at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? fm.removeItem(at: destination)
    try fm.copyItem(at: self, to: destination)
  }
}

struct GroupConfig: Codable {
  let from: [String]
  let to: String
}

struct OverlayConfig: Codable {
  let stages: [OverlayStage]
}

struct CopyConfig: Codable {
  let from: String
  let to: String
}

struct OverlayStage: Codable {
  let copy: CopyConfig?
  let move: GroupConfig?
  let merge: GroupConfig?
}
