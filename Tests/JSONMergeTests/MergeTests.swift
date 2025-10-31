import JSONMerge
import Testing

@Suite struct MergeTests {
  @Test func testMergeDictionaries() {
    let jsonA = JSONFile(
      """
      {
        "name": "Alice",
        "age": 30,
        "city": "New York"
      }
      """
    )

    let jsonB = JSONFile(
      """
      {
        "age": 31,
        "country": "USA"
      }
      """)

    let merger = JSONMerger()

    let mergedData = try! merger.merge([jsonA.data, jsonB.data])
  }
}
