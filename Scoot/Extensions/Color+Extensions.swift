import SwiftUI

/*

 Implementation adapted from Zane Carter's gist:
 https://gist.github.com/zane-carter/fc2bf8f5f5ac45196b4c9b01d54aca80

 Also see:
 https://medium.com/geekculture/using-appstorage-with-swiftui-colors-and-some-nskeyedarchiver-magic-a38038383c5e

 */

extension Color {

    init(rawValue: String) {

        guard let data = Data(base64Encoded: rawValue),
              let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
            self = Color(NSColor.black)
            return
        }

        self = Color(color)

    }

    var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: true)
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }

}
