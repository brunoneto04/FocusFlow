import XCTest
@testable import FocusFlowSharedTests

fileprivate extension FocusFlowSharedTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__FocusFlowSharedTests = [
        ("testPackageCompiles", testPackageCompiles)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __FocusFlowSharedTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FocusFlowSharedTests.__allTests__FocusFlowSharedTests)
    ]
}