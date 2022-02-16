import Foundation

extension Bundle {

    var displayName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    var copyright: String? {
        object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
    }

    public var version: String {
        let versionNumber = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let buildNumber = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        return "\(versionNumber) (\(buildNumber))"
    }

}
