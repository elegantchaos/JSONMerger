import JSONMerge
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
}
