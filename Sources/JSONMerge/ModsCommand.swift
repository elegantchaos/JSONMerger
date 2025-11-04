// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/11/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ArgumentParser
import Foundation

struct ModsCommand: ParsableCommand {
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "mods",
      abstract: "Apply multiple mod configurations."
    )
  }

  @Flag() var verbose: Bool = false
  @Option(help: "Path to a JSON file containing mod data.") var modsPath: String?
  @Option(help: "Path to the output .json file for RSV data.") var rsvOutputPath: String?
  @Option(help: "Path to the output .ini for OBody data.") var obodyOutputPath: String?

  mutating func run() throws {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let modsURL = modsPath.map { URL(fileURLWithPath: $0, relativeTo: cwd) }

    if let modURL = modsURL {
      let decoder = JSONDecoder()
      let data = try Data(contentsOf: modURL)
      let modCollection = try decoder.decode([String: ModRecord].self, from: data)
      process(mods: modCollection)
    }

    func process(mods: [String: ModRecord]) {
      var obodyFemaleIds: [String] = []
      var obodyMaleIds: [String] = []
      for (mod, info) in mods {
        if info.skipOBodyFemale == true || info.skipOBody == true {
          obodyFemaleIds.append(mod)
        }
        if info.skipOBodyMale == true || info.skipOBody == true {
          obodyMaleIds.append(mod)
        }
      }

      if let outputURL = obodyOutputPath.map({ URL(fileURLWithPath: $0, relativeTo: cwd) }) {
        processOBody(maleIDs: obodyMaleIds, femaleIDs: obodyFemaleIds, to: outputURL)
      }
    }

    func processOBody(maleIDs: [String], femaleIDs: [String], to url: URL) {
      let maleIdList =
        maleIDs
        .sorted()
        .map { "\n      \"\($0)\"" }
        .joined(separator: ",")

      let femaleIdList =
        femaleIDs
        .sorted()
        .map { "\n      \"\($0)\"" }
        .joined(separator: ",")

      let ini = """
        {
            "blacklistedNpcsPluginFemale" : [\(femaleIdList)
            ],
            "blacklistedNpcsPluginMale" : [\(maleIdList)
            ]
        }
        """

      do {
        try ini.write(to: url)
      } catch {
        print("Error writing OBody INI file: \(error)")
      }
    }
  }
}

struct ModRecord: Codable {
  /// Should we add the mod to the blacklist for OBody?
  let skipOBody: Bool?

  /// Should we add the mod to the blacklist for OBody female?
  let skipOBodyFemale: Bool?

  /// Should we add the mod to the blacklist for OBody male?
  let skipOBodyMale: Bool?

  /// Should we add the mod to the blacklist for RSV?
  let skipRSV: Bool?
}
