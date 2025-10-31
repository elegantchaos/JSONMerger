// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct JSONMerge: ParsableCommand {
    mutating func run() throws {
        let merger = JSONMerger()
        let merged = try merger.merge([])
        print("Merged JSON: \(merged)")
    }
}
