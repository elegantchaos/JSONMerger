// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ArgumentParser
import Foundation

@main
struct JSONMerge: ParsableCommand {
  @Argument(help: "The JSON files to merge.")
  var files: [String]

  mutating func run() throws {
    let merger = JSONMerger()
    let files = self.files.compactMap { try? JSONFile(contentsOf: URL(fileURLWithPath: $0)) }
    let merged = try merger.merge(files)
    print(merged.formatted)
  }
}
