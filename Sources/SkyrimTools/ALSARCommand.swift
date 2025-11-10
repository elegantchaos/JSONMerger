// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/11/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ArgumentParser
import Foundation

struct AlsarCommand: LoggableCommand, GameCommand {
  static var configuration: CommandConfiguration {
    CommandConfiguration(
      commandName: "alsar",
      abstract: "Generate ALSAR data."
    )
  }

  @Flag() var verbose: Bool = false
  @Flag() var pull: Bool = false
  @Option(help: "Path to a the alsar.json config file.") var configPath: String?
  @Option(help: "Path to the game data.") var gamePath: String?

  mutating func run() throws {
    guard let configURL = configPath?.relativeURL else {
      log("No config path provided; skipping.")
      return
    }

    if pull {
      try pullSettings(configURL: configURL)
    } else {
      try generateSettings()
    }
    log("Done.")
  }

  func generateSettings() throws {
    log("Generating ALSAR settings...")
  }

  func pullSettings(configURL: URL) throws {
    log("Extracting ALSAR settings...")
    var armos = try extractARMOData()
    let armas = try extractARMAData()

    for (name, armo) in armos {
      let pair = armas[armo.arma]
      if pair == nil {
        log("Warning: No ARMA found for \(armo.arma) referenced by ARMO \(name)")
      } else if armo.dlc != pair?.dlc {
        log("Warning: DLC mismatch for ARMA \(armo.arma) referenced by ARMO \(name)")
      }

      armos[name] = armo
    }

    let config = ARMOConfig(armos: armos, armas: armas)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(config)
    try data.write(to: configURL)
    log("Wrote ALSAR config to \(configURL.path)")
  }

  func extractARMOData() throws -> [String: ARMOEntry] {
    let armoURL = skseURL.appending(path: "zzLSARSetting_ARMO.ini")
    let lines = try String(contentsOf: armoURL, encoding: .utf8)
      .components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

    var armos: [String: ARMOEntry] = [:]

    for line in lines {
      let fields = line.split(separator: "\t")
      if fields.count >= 5 {
        let name = String(fields[4])
        if name != "ARMO_NAME" {  // skip header
          let entry = ARMOEntry(
            formID: Int(fields[0], radix: 16) ?? 0,
            enabled: true,
            loose: fields[1] == "1",
            dlc: Int(fields[2]) ?? 0,
            arma: String(fields[3]),
            armo: name
          )
          armos[name] = entry
        }
      }
    }

    return armos
  }

  func extractARMAData() throws -> [String: ARMAPair] {
    let armaURL = skseURL.appending(path: "zzLSARSetting_ARMA.ini")
    let lines = try String(contentsOf: armaURL, encoding: .utf8)
      .components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

    var looseArmas: [String: ARMAEntry] = [:]
    var fittedArmas: [String: ARMAEntry] = [:]

    for line in lines {
      if line.isEmpty || line.starts(with: "#") {
        continue
      }

      let fields = line.split(separator: "\t")
      let category = ARMACategory.fromCode(String(fields[2]))
      if fields.count == 11 {
        let name = String(fields[0])
        let options = ARMAOptions(
          skirt: fields[4] == "1",
          panty: fields[5] == "1",
          bra: fields[6] == "1",
          greaves: fields[7] == "1"
        )
        let entry = ARMAEntry(
          category: category,
          formID: Int(fields[1], radix: 16) ?? 0,
          options: options,
          priority: Int(fields[8]) ?? 0,
          dlc: Int(fields[9]) ?? 0,
          editorID: String(fields[10])
        )

        let isLoose = fields[3] == "L"
        if isLoose {
          looseArmas[name] = entry
        } else {
          fittedArmas[name] = entry
        }
      }

    }

    let looseKeys = Set(looseArmas.keys)
    let fittedKeys = Set(fittedArmas.keys)
    let mismatchedKeys = looseKeys.symmetricDifference(fittedKeys)
    if mismatchedKeys.count > 0 {
      for key in mismatchedKeys {
        log("Warning: ARMA \(key) has only loose or fitted entry, not both.")
      }
    }

    let commonKeys = looseKeys.intersection(fittedKeys)
    var pairs: [String: ARMAPair] = [:]
    for key in commonKeys {
      if let loose = looseArmas[key], let fitted = fittedArmas[key] {
        if loose.dlc != fitted.dlc {
          log("Warning: DLC mismatch between loose and fitted ARMA for \(key)")
        }
        if loose.category != fitted.category {
          log("Warning: Category mismatch between loose and fitted ARMA for \(key)")
        }
        if loose.priority != fitted.priority {
          log("Warning: Priority mismatch between loose and fitted ARMA for \(key)")
        }
        if loose.options.skirt != fitted.options.skirt
          || loose.options.panty != fitted.options.panty || loose.options.bra != fitted.options.bra
          || loose.options.greaves != fitted.options.greaves
        {
          log("Warning: Options mismatch between loose and fitted ARMA for \(key)")
        }

        let looseCompact = ARMACompact(
          formID: loose.formID,
          options: loose.options,
          editorID: loose.editorID
        )
        let fittedCompact = ARMACompact(
          formID: fitted.formID,
          options: fitted.options,
          editorID: fitted.editorID
        )

        pairs[key] = ARMAPair(
          category: loose.category,
          dlc: loose.dlc,
          priority: loose.priority,
          loose: looseCompact,
          fitted: fittedCompact
        )
      }
    }
    return pairs
  }
}

struct ARMOConfig: Codable {
  let armos: [String: ARMOEntry]
  let armas: [String: ARMAPair]
}
struct ARMOEntry: Codable {
  let formID: Int
  let enabled: Bool
  let loose: Bool
  let dlc: Int
  let arma: String
  let armo: String
}

enum ARMACategory: String, Codable {
  case cloth
  case light
  case heavy
  case other

  static func fromCode(_ code: String) -> Self {
    switch code {
    case "C":
      return .cloth
    case "L":
      return .light
    case "H":
      return .heavy
    default:
      return .other
    }
  }
}

struct ARMAPair: Codable {
  let category: ARMACategory
  let dlc: Int
  let priority: Int
  let loose: ARMACompact
  let fitted: ARMACompact
}

struct ARMAEntry: Codable {
  let category: ARMACategory
  let formID: Int
  let options: ARMAOptions
  let priority: Int
  let dlc: Int
  let editorID: String
}

struct ARMACompact: Codable {
  let formID: Int
  let options: ARMAOptions
  let editorID: String
}

struct ARMAOptions: Codable {
  let skirt: Bool
  let panty: Bool
  let bra: Bool
  let greaves: Bool
}
