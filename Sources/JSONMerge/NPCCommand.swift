// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/11/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ArgumentParser
import Foundation

struct NPCCommand: ParsableCommand {
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "npcs",
      abstract: "Apply multiple NPC configurations."
    )
  }

  @Flag() var verbose: Bool = false
  @Option(help: "Path to a JSON file containing NPC data.") var npcsPath: String?

  mutating func run() throws {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let npcsURL =
      npcsPath.map { URL(fileURLWithPath: $0, relativeTo: cwd) }

    if let npcURL = npcsURL {
      let decoder = JSONDecoder()
      let data = try Data(contentsOf: npcURL)
      let npcCollection = try decoder.decode([String: NPCRecord].self, from: data)
      process(npcs: npcCollection)
    }

    func process(npcs: [String: NPCRecord]) {
      for (npcID, npc) in npcs {
        if verbose {
          print("Processing NPC: \(npc.name ?? npcID)")
        }
      }
    }
  }
}

struct NPCRecord: Codable {
  /// The formID of the NPC.
  let formID: String?

  /// The esp/esl file the NPC belongs to.
  let mod: String?

  /// The display name of the NPC.
  let name: String?

  /// Should we add the NPC to the blacklist for OBody?
  let skipOBody: Bool?

  /// Should we add the NPC to the blacklist for RSV?
  let skipRSV: Bool?
}
