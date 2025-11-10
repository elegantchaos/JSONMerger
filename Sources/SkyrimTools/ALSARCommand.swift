// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/11/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ArgumentParser
import Foundation

struct AlsarCommand: LoggableCommand {
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "alsar",
      abstract: "Generate ALSAR data."
    )
  }

  @Flag() var verbose: Bool = false
  @Option(help: "Path to a folder containing mod data files.") var modsPath: String?
  @Option(help: "Path to the game data.") var dataPath: String?

  mutating func run() throws {
    log("Processing mods...")
    log("Done.")
  }

}
