import SwiftUI

/*

 Implementation adapted from Zane Carter's gist:
 https://gist.github.com/zane-carter/fc2bf8f5f5ac45196b4c9b01d54aca80

 Also see:
 https://medium.com/geekculture/using-appstorage-with-swiftui-colors-and-some-nskeyedarchiver-magic-a38038383c5e

 */

extension Color: RawRepresentable {

    public init?(rawValue: String) {

        let defaultColor = NSColor.black

        guard let data = Data(base64Encoded: rawValue) else {
            self = Color(defaultColor)
            return
        }

        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSColor ?? defaultColor
            self = Color(color)
        } catch {
            self = Color(defaultColor)
        }

    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }

}
