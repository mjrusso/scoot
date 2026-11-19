import XCTest
import SwiftUI

class ColorStorageTests: XCTestCase {

    func testReadsExistingColorArchives() throws {
        let original = NSColor(srgbRed: 0.2, green: 0.4, blue: 0.6, alpha: 0.8)
        let data = try NSKeyedArchiver.archivedData(withRootObject: original, requiringSecureCoding: false)
        let color = Color(rawValue: data.base64EncodedString())
        let decoded = try XCTUnwrap(NSColor(color).usingColorSpace(.sRGB))

        XCTAssertEqual(decoded.redComponent, original.redComponent, accuracy: 0.001)
        XCTAssertEqual(decoded.greenComponent, original.greenComponent, accuracy: 0.001)
        XCTAssertEqual(decoded.blueComponent, original.blueComponent, accuracy: 0.001)
        XCTAssertEqual(decoded.alphaComponent, original.alphaComponent, accuracy: 0.001)

        let roundTrip = Color(rawValue: color.rawValue)
        XCTAssertEqual(NSColor(roundTrip), NSColor(color))
    }

    func testInvalidColorArchivesFallBackToBlack() {
        for rawValue in ["invalid base64", Data("invalid archive".utf8).base64EncodedString()] {
            let color = Color(rawValue: rawValue)
            XCTAssertEqual(NSColor(color), NSColor.black)
        }
    }
}
