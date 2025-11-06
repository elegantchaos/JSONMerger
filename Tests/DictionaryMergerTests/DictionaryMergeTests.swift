import DictionaryMerger
import Matchable
import Testing

@Suite struct DictionaryMergeTests {
  @Test func testMergeDictionaries() throws {
    let itemA: DictionaryMerger.Item = [
      "name": "Alice",
      "age": 30,
      "city": "New York",
    ]

    let itemB: DictionaryMerger.Item = [
      "age": 31,
      "country": "USA",
    ]

    let merger = DictionaryMerger()
    let merged = try! merger.merge([itemA, itemB])

    #expect(
      merged.asJSON == """
        {
          "age" : 31,
          "city" : "New York",
          "country" : "USA",
          "name" : "Alice"
        }
        """
    )
  }

  @Test func testMergeNestedDictionaries() throws {
    let itemA: DictionaryMerger.Item = [
      "outer": [
        "name": "Alice",
        "age": 30,
        "city": "New York",
      ]
    ]

    let itemB: DictionaryMerger.Item = [
      "other": "foo",
      "outer": [
        "age": 31,
        "country": "USA",
      ],
    ]

    let merger = DictionaryMerger()
    let merged = try! merger.merge([itemA, itemB])

    try merged.asJSON.assertMatches(
      """
      {
        "other" : "foo",
        "outer" : {
          "age" : 31,
          "city" : "New York",
          "country" : "USA",
          "name" : "Alice"
        }
      }
      """
    )
  }

  @Test func testMergeNestedLists() throws {
    let itemA: DictionaryMerger.Item = [
      "other": "foo",
      "outer": [
        "inner": ["foo"]
      ],
    ]

    let itemB: DictionaryMerger.Item = [
      "outer": [
        "inner": ["bar"]
      ]
    ]

    let merger = DictionaryMerger()
    let merged = try! merger.merge([itemA, itemB])

    try merged.asJSON.assertMatches(
      """
      {
        "other" : "foo",
        "outer" : {
          "inner" : [
            "foo",
            "bar"
          ]
        }
      }
      """
    )
  }

  @Test func testMergeNestedListsUniquing() throws {
    let itemA: DictionaryMerger.Item = [
      "other": "foo",
      "outer": [
        "inner": ["foo", "bar"]
      ],
    ]

    let itemB: DictionaryMerger.Item = [
      "outer": [
        "inner": ["bar", "baz"]
      ]
    ]

    let merger = DictionaryMerger(options: DictionaryMerger.Options(uniqueLists: true))
    let merged = try! merger.merge([itemA, itemB])

    try merged.asJSON.assertMatches(
      """
      {
        "other" : "foo",
        "outer" : {
          "inner" : [
            "foo",
            "bar",
            "baz"
          ]
        }
      }
      """
    )
  }

  @Test func testMergeListsDifferentTypes() throws {
    let itemA: DictionaryMerger.Item = [
      "other": "foo",
      "outer": [
        "inner": ["foo", "bar"]
      ],
    ]

    let itemB: DictionaryMerger.Item = [
      "outer": [
        "inner": [1, 2]
      ]
    ]

    let merger = DictionaryMerger()
    let merged = try! merger.merge([itemA, itemB])

    try merged.asJSON.assertMatches(
      """
      {
        "other" : "foo",
        "outer" : {
          "inner" : [
            "foo",
            "bar",
            1,
            2
          ]
        }
      }
      """
    )
  }
}
