import XCTest
@testable import solari

class solariTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(solari().text, "Hello, World!")
    }


    static var allTests: [(String, (solariTests) -> () -> Void)] = [
        ("testExample", testExample),
    ]
}
