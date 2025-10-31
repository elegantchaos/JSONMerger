import JSONMerge
import Matchable
import Testing

@Suite struct MergeTests {
  @Test func testMergeDictionaries() throws {
    let jsonA = try JSONFile(
      """
      {
        "name": "Alice",
        "age": 30,
        "city": "New York"
      }
      """
    )

    let jsonB = try JSONFile(
      """
      {
        "age": 31,
        "country": "USA"
      }
      """)

    let merger = JSONMerger()
    let merged = try! merger.merge([jsonA, jsonB])

    #expect(
      merged.formatted == """
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
    let jsonA = try JSONFile(
      """
      {
        "outer": {
          "name": "Alice",
          "age": 30,
          "city": "New York"
        }
      }
      """
    )

    let jsonB = try JSONFile(
      """
      {
        "other": "foo",
        "outer": {
        "age": 31,
        "country": "USA"
        }
      }
      """
    )

    let merger = JSONMerger()
    let merged = try! merger.merge([jsonA, jsonB])

    try merged.formatted.assertMatches(
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
    let jsonA = try JSONFile(
      """
      {
        "other" : "foo",
        "outer": {
          "inner": ["foo"]
        }
      }
      """
    )

    let jsonB = try JSONFile(
      """
      {
        "outer": {
        "inner": ["bar"],
        }
      }
      """
    )

    let merger = JSONMerger()
    let merged = try! merger.merge([jsonA, jsonB])

    try merged.formatted.assertMatches(
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
    let jsonA = try JSONFile(
      """
      {
        "other" : "foo",
        "outer": {
          "inner": ["foo", "bar"]
        }
      }
      """
    )

    let jsonB = try JSONFile(
      """
      {
        "outer": {
        "inner": ["bar", "baz"],
        }
      }
      """
    )

    let merger = JSONMerger(options: JSONMerger.Options(uniqueLists: true))
    let merged = try! merger.merge([jsonA, jsonB])

    try merged.formatted.assertMatches(
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
    let jsonA = try JSONFile(
      """
      {
        "other" : "foo",
        "outer": {
          "inner": ["foo", "bar"]
        }
      }
      """
    )

    let jsonB = try JSONFile(
      """
      {
        "outer": {
        "inner": [1, 2],
        }
      }
      """
    )

    let merger = JSONMerger()
    let merged = try! merger.merge([jsonA, jsonB])

    try merged.formatted.assertMatches(
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
