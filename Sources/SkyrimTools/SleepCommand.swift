// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/11/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ArgumentParser
import DictionaryMerger
import Foundation

struct SleepCommand: LoggableCommand {
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "sleep",
      abstract: "Export sleep information for the armour we know about."
    )
  }

  @Argument(help: "The JSON files to merge.")
  var files: [String]

  @Flag() var verbose: Bool = false
  @Flag() var uniqueLists: Bool = false

  mutating func run() throws {
    let options = DictionaryMerger.Options(
      uniqueLists: uniqueLists,
      verbose: verbose
    )

    let merger = JSONMerger(options: options)

    let files = self.files.compactMap { try? JSONFile(contentsOf: URL(fileURLWithPath: $0)) }

    switch files.count {
    case 0:
      log("No valid JSON files found.", path: [])
    case 1:
      print(files[0].formatted)
    default:
      let merged = try merger.merge(files)
      print(merged.formatted)
    }
  }

}
