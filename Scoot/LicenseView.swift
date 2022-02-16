import SwiftUI

struct LicenseView: View {

    var body: some View {
        ScrollView {
            VStack {
                Text(loadLicenseText())
                    .font(.system(.body, design: .monospaced))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(minWidth: 680, minHeight: 520)
    }

    func loadLicenseText() -> String {
        guard let path = Bundle.main.path(forResource: "LICENSE", ofType: "") else {
            return ""
        }
        return (try? String(contentsOfFile: path)) ?? ""
    }

}

struct LicenseView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseView()
    }
}
